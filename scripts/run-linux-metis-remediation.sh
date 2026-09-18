#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/linux-reference-env.sh"
base="$reference_root/.work/legal-remediation"
exe="$base/linux-build/palace/palace-x86_64.bin"
output="$base/linux"
test -x "$exe"
test ! -e "$output"
mkdir -p "$output"
for case_name in electrostatic magnetostatic driven eigenmode; do
  source_case="$reference_root/.work/gate3/linux/$case_name"
  directory="$output/$case_name"
  mkdir -p "$directory"
  cp "$source_case/config.json" "$directory/config.json"
  cp -R "$source_case/mesh" "$directory/mesh"
  (cd "$directory" && "$exe" config.json > run.log 2>&1)
  echo "Linux remediation $case_name completed"
done
