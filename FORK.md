# bqw371/sidemdm — the motofreedom DPC fork

This is a fork of [`lukeponio/sidemdm`](https://github.com/lukeponio/sidemdm)
(MIT), rebranded as the Device Policy Controller used by the
[`motofreedom`](https://github.com/bqw371/motofreedom) toolkit's `activate`
phase.

## What changed from upstream

- Android package name: `com.example.personalprofile` →
  `com.bqw371.motofreedom.dpc`.
- Gradle `namespace` + `applicationId` updated to match.
- `DEFAULT_COMPONENT` in `tools/generate_qr.py` points at the new
  `com.bqw371.motofreedom.dpc/.AdminReceiver`.
- Devcontainer + `build-apk.yml` workflow added for Codespaces/CI builds
  (see `.devcontainer/` and `.github/workflows/`).

## What did NOT change

- The `ProvisioningPolicy.chooseMode` contract: still COPE-only, still
  refuses `FULLY_MANAGED_DEVICE` (FR-04). This is the entire reason we
  trust the DPC; keeping it bit-identical to upstream's audited behaviour
  is the point.
- `RemoveProfileController.wipeData`: still calls `wipeData(0, …)` on the
  work-profile DPM, still fail-closed on any exception.
- `AndroidManifest.xml`: no INTERNET permission (NFR-05, LAN-06).
- `device_admin.xml`: `<wipe-data/>` and nothing else.

## Why fork instead of using upstream directly

Three reasons:

1. **Package name hygiene.** Shipping an APK under
   `com.example.personalprofile` is namespace-squatting on
   `com.example.*` (reserved for examples) and could conflict with any
   other install of upstream. `com.bqw371.motofreedom.dpc` is ours.
2. **Supply-chain control.** motofreedom's design doc pins this APK by
   SHA-256 in `profile.activation_bypass.apk_sha256`. The SHA has to be
   computable from a build we control; depending on upstream's release
   schedule is a hostage situation.
3. **Keystore ownership.** The release build is eventually signed with
   motofreedom's keystore so that reinstalls don't require re-enrolment.

## Changes we have NOT made but might

- **Signing config** — until a motofreedom-owned keystore exists, release
  builds use the debug key. CI publishes a `*.apk` artifact on each push;
  for production we'll add a `signingConfigs.release` block pointing at a
  GitHub-Actions-secret-sourced keystore. See `docs/release.md` from
  upstream for the ceremony.
- **Branding strings** — `strings.xml` app_name is still "Work Profile"
  (matches upstream). That's fine; the on-phone user never sees this app
  by its own name — the DPC is only visible via the Work tab.

## License

MIT, inherited from upstream. See `LICENSE`.
