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
            self.assertIn("--simulate", preview.stdout)

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
