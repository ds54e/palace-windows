# Redistribution review

The original infrastructure and probe code in this repository use Apache-2.0. This does not relicense Palace, numerical libraries, compiler runtimes, Microsoft/Intel binaries, examples, or copied patches.

Before bundling any component, record its exact source/version, artifact hash, whether it is self-built or vendor-supplied, applicable license/redistribution text, required notices, source/patch obligations, runtime dependency closure, and reviewer conclusion. Source licensing and vendor binary redistribution are separate checks. Availability of source does not establish support for application-local deployment.

Do not assume an official installer permits arbitrary DLL extraction and repackaging. Do not copy DLLs from System32 or developer installations without a documented distribution route. Keep complete source provenance for extracted prior-art patches; do not use an unattributed rewrite to evade license obligations.

Do not distribute toolkits, credentials, private simulation geometry, raw user-host logs, or cached proprietary files. Keep the repository private while unresolved third-party assets are reviewed. Automated checks may flag missing records but cannot replace the review.

Maintain a runtime inventory with these fields once actual payloads exist:

```text
relative_path | sha256 | component | version_or_commit | origin
build_recipe | license_id | redistribution_evidence | notices | review_status
```

For release readiness, include the build scripts/patches needed to explain the artifact, license and notice files, supported features, signature status, and reproducible checksums. Do not declare all dependencies permissively licensed until each selected version has been checked.
