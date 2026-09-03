import hashlib
import importlib.machinery
import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
import unittest
from unittest import mock
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CLI = ROOT / "dotfiles"


def load_controller():
    loader = importlib.machinery.SourceFileLoader("dotfiles_controller", str(CLI))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


CONTROLLER = load_controller()


def run_cli(*arguments: str, target: str | None = None) -> subprocess.CompletedProcess[str]:
    environment = os.environ.copy()
    if target is not None:
        environment["DOTFILES_TARGET"] = target
    return subprocess.run(
        [str(CLI), *arguments],
        cwd=ROOT,
        env=environment,
        capture_output=True,
        text=True,
    )


def run_handler(name: str, action: str, home: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ.copy()
    environment["HOME"] = home
    environment.pop("XDG_CONFIG_HOME", None)
    return subprocess.run(
        [str(ROOT / "state" / name / action)],
        cwd=ROOT,
        env=environment,
        capture_output=True,
        text=True,
    )


class DotfilesIntegrationTest(unittest.TestCase):
    def setUp(self) -> None:
        if shutil.which("stow") is None:
            self.skipTest("GNU Stow is not installed")

    def test_audit_accepts_the_profile_in_an_isolated_home(self) -> None:
        with tempfile.TemporaryDirectory() as target:
            result = run_cli("audit", "--profile", "workstation", "--skip-lock", target=target)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("SUMMARY profile=workstation", result.stdout)
        self.assertIn("state audits skipped", result.stdout)

    def test_real_stow_deploy_is_idempotent(self) -> None:
        with tempfile.TemporaryDirectory() as target:
            arguments = (
                "apply",
                "--profile",
                "workstation",
                "--skip-packages",
                "--skip-system",
                "--skip-state",
            )
            first = run_cli(*arguments, target=target)
            second = run_cli(*arguments, target=target)
            preview = run_cli(*arguments, "--dry-run", target=target)
            self.assertEqual(first.returncode, 0, first.stdout + first.stderr)
            self.assertEqual(second.returncode, 0, second.stdout + second.stderr)
            self.assertEqual(preview.returncode, 0, preview.stdout + preview.stderr)
            self.assertTrue((Path(target) / ".zshenv").is_symlink())
            self.assertFalse((Path(target) / ".config/mimeapps.list").exists())
            self.assertFalse((Path(target) / ".config/pavucontrol.ini").exists())
            self.assertFalse((Path(target) / ".config/user-dirs.dirs").exists())
            self.assertFalse((Path(target) / ".config/user-dirs.locale").exists())
            self.assertFalse((Path(target) / ".config/niri/config.kdl").exists())
            self.assertTrue((Path(target) / ".config/niri/portable.kdl").is_symlink())
            self.assertFalse((Path(target) / ".config/OpenRGB").exists())
            self.assertIn("--simulate", preview.stdout)

    def test_mimeapps_apply_replaces_the_legacy_stow_link(self) -> None:
        snapshot = ROOT / "state/mimeapps/mimeapps.list"
        legacy_snapshot = ROOT / "gnome-desktop/.config/mimeapps.list"
        with tempfile.TemporaryDirectory() as home:
            config = Path(home) / ".config"
            config.mkdir()
            destination = config / "mimeapps.list"
            destination.symlink_to(legacy_snapshot)
            result = run_handler("mimeapps", "apply", home)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertTrue(destination.is_file())
            self.assertFalse(destination.is_symlink())
            self.assertEqual(destination.read_bytes(), snapshot.read_bytes())

    def test_mutable_desktop_state_replaces_legacy_stow_links(self) -> None:
        with tempfile.TemporaryDirectory() as home:
            config = Path(home) / ".config"
            config.mkdir()
            legacy = ROOT / "gnome-desktop/.config"
            for name in ("pavucontrol.ini", "user-dirs.dirs", "user-dirs.locale"):
                (config / name).symlink_to(legacy / name)

            for handler in ("pavucontrol", "user-dirs"):
                result = run_handler(handler, "apply", home)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                audit = run_handler(handler, "audit", home)
                self.assertEqual(audit.returncode, 0, audit.stdout + audit.stderr)

            for name, handler in (
                ("pavucontrol.ini", "pavucontrol"),
                ("user-dirs.dirs", "user-dirs"),
                ("user-dirs.locale", "user-dirs"),
            ):
                destination = config / name
                self.assertTrue(destination.is_file())
                self.assertFalse(destination.is_symlink())
                expected = ROOT / "state" / handler / name
                self.assertEqual(destination.read_bytes(), expected.read_bytes())
            self.assertTrue((Path(home) / "Desktop").is_dir())

    def test_niri_state_uses_a_regular_entrypoint_and_stowed_portable_policy(self) -> None:
        with tempfile.TemporaryDirectory() as home:
            apply = run_cli(
                "apply",
                "--profile",
                "workstation",
                "--skip-packages",
                "--skip-system",
                "--skip-state",
                target=home,
            )
            self.assertEqual(apply.returncode, 0, apply.stdout + apply.stderr)
            config = Path(home) / ".config/niri/config.kdl"
            config.symlink_to(ROOT / "niri/.config/niri/config.kdl")
            result = run_handler("niri", "apply", home)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            audit = run_handler("niri", "audit", home)
            self.assertEqual(audit.returncode, 0, audit.stdout + audit.stderr)
            self.assertTrue(config.is_file())
            self.assertFalse(config.is_symlink())
            self.assertEqual(config.read_bytes(), (ROOT / "state/niri/config.kdl").read_bytes())

    def test_openrgb_state_replaces_legacy_stow_links(self) -> None:
        with tempfile.TemporaryDirectory() as home:
            destination_dir = Path(home) / ".config/OpenRGB"
            destination_dir.mkdir(parents=True)
            snapshots = ROOT / "state/openrgb/files"
            legacy = ROOT / "hardware/.config/OpenRGB"
            for snapshot in snapshots.iterdir():
                (destination_dir / snapshot.name).symlink_to(legacy / snapshot.name)
            result = run_handler("openrgb", "apply", home)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            audit = run_handler("openrgb", "audit", home)
            self.assertEqual(audit.returncode, 0, audit.stdout + audit.stderr)
            for snapshot in snapshots.iterdir():
                destination = destination_dir / snapshot.name
                self.assertTrue(destination.is_file())
                self.assertFalse(destination.is_symlink())
                self.assertEqual(destination.read_bytes(), snapshot.read_bytes())

    def test_btop_does_not_rewrite_its_stowed_configuration(self) -> None:
        config = (ROOT / "terminal/.config/btop/btop.conf").read_text()
        self.assertIn("save_config_on_exit = false", config)

    def test_preflight_rejects_a_regular_file_conflict(self) -> None:
        with tempfile.TemporaryDirectory() as target:
            conflict = Path(target) / ".zshenv"
            conflict.write_text("do not replace\n")
            result = run_cli(
                "apply",
                "--profile",
                "workstation",
                "--dry-run",
                "--skip-packages",
                "--skip-system",
                "--skip-state",
                target=target,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(conflict.read_text(), "do not replace\n")
            self.assertIn("Stow conflict", result.stderr)

    def test_lock_preview_is_valid_json(self) -> None:
        result = run_cli("lock", "--profile", "workstation", "--dry-run")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        data = json.loads(result.stdout)
        self.assertEqual(data["schema_version"], 1)
        self.assertEqual(data["profile"], "workstation")
        self.assertEqual(len(data["stow_tree_sha256"]), 64)
        self.assertEqual(len(data["state_tree_sha256"]), 64)

    def test_lock_audit_checks_content_hashes(self) -> None:
        current = {
            "schema_version": 1,
            "profile": "workstation",
            "installed_desired": {"stow": "1"},
            "missing_desired": [],
            "explicit_unmanaged": {},
            "aur_sources": [],
            "cargo_sources": [],
            "git_sources": [],
            "tools": {},
            "stow_tree_sha256": "new",
            "state_tree_sha256": "state",
            "system_template_sha256": {},
        }
        locked = {**current, "stow_tree_sha256": "old"}
        with tempfile.TemporaryDirectory() as directory:
            temporary_root = Path(directory)
            (temporary_root / "locks").mkdir()
            (temporary_root / "locks/workstation.json").write_text(json.dumps(locked))
            warnings: list[str] = []
            with (
                mock.patch.object(CONTROLLER, "ROOT", temporary_root),
                mock.patch.object(CONTROLLER, "lock_data", return_value=current),
            ):
                CONTROLLER.audit_lock("workstation", {}, {"stow": "1"}, warnings)
        self.assertIn("lock drift: Stow tree hash", warnings)

    def test_git_remote_comparison_ignores_dot_git_suffix(self) -> None:
        self.assertEqual(
            CONTROLLER.normalized_git_remote("https://github.com/example/repo.git/"),
            CONTROLLER.normalized_git_remote("https://github.com/example/repo"),
        )

    def test_export_help_does_not_modify_snapshot(self) -> None:
        paths = [ROOT / "gnome" / "extensions.txt", *sorted((ROOT / "gnome" / "dconf").glob("*.ini"))]
        before = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
        result = subprocess.run(
            [str(ROOT / "scripts" / "export-gnome"), "--help"],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        after = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, after)


if __name__ == "__main__":
    unittest.main()
