# Windows / winget packaging

Manifests for submitting OpenAir to the [Windows Package Manager (winget)](https://learn.microsoft.com/windows/package-manager/)
community repository, [`microsoft/winget-pkgs`](https://github.com/microsoft/winget-pkgs).

| File | Purpose |
| --- | --- |
| `OpenAir-Podcast.OpenAir.yaml` | Version manifest. |
| `OpenAir-Podcast.OpenAir.locale.en-US.yaml` | Default-locale metadata. |
| `OpenAir-Podcast.OpenAir.installer.yaml` | Installer (portable zip) manifest. |

The Windows release asset is a self-contained zip
(`openair-<tag>-windows-x64.zip`) containing `OpenAir.exe`, its DLLs, `data/`
and `lib/`. winget installs it as a portable package and creates an `openair`
command alias.

## Automatic submission (preferred)

`.github/workflows/build_all_platforms.yml` has a `winget` job that uses
[`winget-releaser`](https://github.com/vedantmgoyal9/winget-releaser) to generate
the manifests and open the `microsoft/winget-pkgs` pull request.

1. Create a classic GitHub PAT with `public_repo` scope from an account that has
   forked `microsoft/winget-pkgs`.
2. Add it to the repo as the `WINGET_TOKEN` secret.
3. Publish the GitHub release (the CI creates it as a **draft**), then re-run the
   `winget` job from the Actions tab.

Without `WINGET_TOKEN` the job is skipped.

## Manual submission

1. Download the Windows zip and compute its hash:
   `sha256sum openair-<tag>-windows-x64.zip`
2. Put the hash into `InstallerSha256` and update `PackageVersion` /
   `InstallerUrl` in the installer manifest.
3. Validate and submit with [`wingetcreate`](https://github.com/microsoft/winget-create):
   ```powershell
   wingetcreate validate packaging/winget
   wingetcreate submit packaging/winget
   ```

## Code signing

Unsigned Windows builds trigger SmartScreen warnings. To sign, provide a
code-signing certificate and set these repo secrets (see the `build_windows`
job):

| Secret | Value |
| --- | --- |
| `WINDOWS_CERTIFICATE_BASE64` | Base64-encoded `.pfx` (or `.p12`). |
| `WINDOWS_CERTIFICATE_PASSWORD` | Password for the `.pfx`. |

When set, the workflow signs `OpenAir.exe` and the bundled DLLs with
`signtool`. An EV/OV certificate from a CA is required for SmartScreen
reputation; Azure Trusted Signing is a cheaper modern alternative.
