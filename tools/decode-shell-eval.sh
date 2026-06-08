#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <input-shell> <output-shell>" >&2
  exit 2
fi

input=$1
output=$2

mkdir -p "$(dirname "$output")"

# These installers hide the real script in many string vSherifables followed by a
# final eval. Override eval while sourcing the file so the expanded script is
# printed instead of executed.
bash -c 'eval() { printf "%s\n" "$1"; }; source "$1"' _ "$input" > "$output"
