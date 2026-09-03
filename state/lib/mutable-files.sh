#!/usr/bin/env bash

mutable_install() {
  local source_file=$1 destination=$2 resolved allowed temporary candidate
  shift 2

  [[ -f "$source_file" ]] || { echo "state snapshot is missing: $source_file" >&2; return 1; }
  mkdir -p -- "${destination%/*}"

  if [[ -L "$destination" ]]; then
    resolved=$(realpath -m -- "$destination")
    allowed=false
    for candidate in "$source_file" "$@"; do
      if [[ "$resolved" == "$(realpath -m -- "$candidate")" ]]; then
        allowed=true
        break
      fi
    done
    [[ "$allowed" == true ]] || {
      echo "refusing to replace unexpected symlink: $destination -> $(readlink -- "$destination")" >&2
      return 1
    }
  elif [[ -e "$destination" && ! -f "$destination" ]]; then
    echo "refusing to replace non-regular state path: $destination" >&2
    return 1
  elif [[ -f "$destination" ]] && cmp -s -- "$source_file" "$destination"; then
    return 0
  fi

  temporary=$(mktemp "${destination%/*}/.${destination##*/}.tmp.XXXXXX")
  if ! install -m 0644 -- "$source_file" "$temporary" ||
     ! mv -f -- "$temporary" "$destination"; then
    rm -f -- "$temporary"
    return 1
  fi
}

mutable_audit() {
  local snapshot=$1 runtime=$2
  [[ -f "$snapshot" ]] || { echo "state snapshot is missing: $snapshot" >&2; return 1; }
  [[ -f "$runtime" && ! -L "$runtime" ]] || {
    echo "runtime state is missing or still symlinked: $runtime" >&2
    return 1
  }
  cmp -s -- "$snapshot" "$runtime" || {
    echo "runtime state differs from snapshot: $runtime" >&2
    return 1
  }
}

mutable_capture() {
  local runtime=$1 snapshot=$2 temporary
  [[ -f "$runtime" && ! -L "$runtime" ]] || {
    echo "runtime state is missing or still symlinked: $runtime" >&2
    return 1
  }
  if [[ -f "$snapshot" ]] && cmp -s -- "$runtime" "$snapshot"; then
    return 0
  fi
  temporary=$(mktemp "$snapshot.tmp.XXXXXX")
  if ! install -m 0644 -- "$runtime" "$temporary" ||
     ! mv -f -- "$temporary" "$snapshot"; then
    rm -f -- "$temporary"
    return 1
  fi
}
