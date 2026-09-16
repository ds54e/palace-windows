#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/linux-reference-env.sh"
exe="$reference_root/.work/linux-reference/build/palace/palace-x86_64.bin"
test -x "$exe"
for case_name in electrostatic magnetostatic driven eigenmode; do
  directory="$reference_root/.work/gate3/linux/$case_name"
  (cd "$directory" && "$exe" config.json > run.log 2>&1)
  echo "Linux $case_name completed"
done
