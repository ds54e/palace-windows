# v1.0.0 public publication checklist

This checklist publishes the already frozen candidate. It must not rebuild or recompress the ZIP.

## Preconditions

- Work on clean, synchronized `main`.
- Confirm `docs/STATE.json` says `READY_FOR_PUBLIC_RELEASE_CLEAN_TEST_DEFERRED`.
- Confirm the exact frozen source ZIP hashes to `09e3a7c4355a03318f30202556f1bcc26aa7f98fd7c3de8cd341342b1c9112d2`.
- Confirm no release/tag named `v1.0.0` already exists.
- Do not claim Gate 0 or Gate 5 passed.

## Local publication sequence

Use the existing authenticated GitHub CLI. Keep the release private until the asset and tag have been verified, then change repository visibility as the final publication step.

```powershell
$repo = 'ds54e/palace-windows'
$src = 'E:\projects\palace-windows\.work\package\palace-windows-1.0.0-metis-remediation-review1-internal.zip'
$asset = 'E:\projects\palace-windows\.work\package\palace-windows-1.0.0-win64.zip'
$expected = '09e3a7c4355a03318f30202556f1bcc26aa7f98fd7c3de8cd341342b1c9112d2'

if (Test-Path -LiteralPath $asset) { throw "Public asset path already exists: $asset" }
$srcHash = (Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToLowerInvariant()
if ($srcHash -ne $expected) { throw "Frozen ZIP hash mismatch: $srcHash" }

Copy-Item -LiteralPath $src -Destination $asset
$assetHash = (Get-FileHash -LiteralPath $asset -Algorithm SHA256).Hash.ToLowerInvariant()
if ($assetHash -ne $expected) { throw "Copied asset hash mismatch: $assetHash" }

$sumFile = Join-Path (Split-Path -Parent $asset) 'SHA256SUMS.txt'
"$expected  palace-windows-1.0.0-win64.zip" | Set-Content -LiteralPath $sumFile -Encoding ascii

$releaseCommit = (git rev-parse HEAD).Trim()
if (-not $releaseCommit) { throw 'Could not resolve release commit' }

gh release create v1.0.0 $asset $sumFile --repo $repo --target $releaseCommit --title 'Palace Windows v1.0.0' --notes-file docs/RELEASE_NOTES_v1.0.0.md

gh release view v1.0.0 --repo $repo

gh repo edit $repo --visibility public --accept-visibility-change-consequences

gh repo view $repo --json nameWithOwner,visibility,url
```

After visibility becomes public, verify the release page and asset download from an unauthenticated browser if convenient. Do not replace the asset in place after publication; create a new release version if payload bytes ever change.

## Post-publication record

Commit a small metadata-only update to `docs/STATE.json` containing:

- `project_status: PUBLIC_RELEASED_CLEAN_TEST_DEFERRED`;
- exact v1.0.0 tag commit;
- release URL;
- repository visibility `public`;
- public asset name and SHA-256;
- clean-host validation still `deferred_unverified`.

Do not move the v1.0.0 tag to that later metadata commit.
