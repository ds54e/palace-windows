#!/usr/bin/env bash
# Invoke allowlisted native PowerShell scripts from WSL without changing policy.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
case "${1:-}" in
  doctor) script=doctor.ps1 ;;
  build-gate0) script=build-gate0.ps1 ;;
  run-gate0) script=run-gate0.ps1 ;;
  *) echo 'Usage: bash tools/windows.sh {doctor|build-gate0|run-gate0} [PowerShell arguments]' >&2; exit 2 ;;
esac
shift
command -v wslpath >/dev/null || { echo 'wslpath is required; run this bridge in WSL.' >&2; exit 2; }
command -v powershell.exe >/dev/null || { echo 'Windows PowerShell/WSL interop is unavailable.' >&2; exit 2; }
win_script=$(wslpath -w "$root/scripts/$script")
# Additional file paths are intentionally not rewritten. Supply Windows paths.
exec powershell.exe -NoLogo -NoProfile -NonInteractive -File "$win_script" "$@"
