# Flathub / Flatpak packaging

This directory contains the Flatpak packaging for OpenAir. Flutter apps cannot
resolve their `pub.dev` dependencies inside the network-less Flathub build
sandbox, so the manifest is a **template** that must first be turned into an
offline manifest by [flatpak-flutter](https://github.com/TheAppgineer/flatpak-flutter).

| File | Purpose |
| --- | --- |
| `flatpak-flutter.yml` | Editable template manifest (input to flatpak-flutter). |
| `com.openair.podcast.metainfo.xml` | AppStream metadata required by Flathub. |
| `com.openair.podcast.desktop` | Desktop entry, installed as-is. |
| `com.openair.podcast.png` | 512x512 app icon. |
| `flathub.json` | Flathub submission options (currently x86_64 only). |
| `com.openair.podcast.yml` | **Generated** offline manifest (gitignored). |
| `pubspec-sources.json` | **Generated** pinned pub/flutter sources (gitignored). |

## 1. Generate the offline manifest

```sh
pip install -r https://raw.githubusercontent.com/TheAppgineer/flatpak-flutter/main/requirements.txt
git clone https://github.com/TheAppgineer/flatpak-flutter
cd /path/to/OpenAir
python3 ../flatpak-flutter/flatpak-flutter.py flatpak/flatpak-flutter.yml
```

This writes `flatpak/com.openair.podcast.yml` and `flatpak/pubspec-sources.json`.
It also picks up foreign-code patches (e.g. the `sqlite3` package's offline
build patch) from flatpak-flutter's registry based on `pubspec.lock`.

> The `tag:` in the Flutter `sources` entry must match a Flutter release tag.
> Bump it together with the SDK used in CI. Pre-generated SDK modules exist for
> many versions; flatpak-flutter generates the rest on demand.

## 2. Build locally to verify

```sh
flatpak install flathub org.freedesktop.Sdk.Extension.rust-stable  # only if Rust deps appear
flatpak-builder --repo=repo --force-clean --sandbox --user --install \
  --install-deps-from=flathub build flatpak/com.openair.podcast.yml
flatpak run com.openair.podcast
```

## 3. Submit to Flathub

1. Fork [`flathub/flathub`](https://github.com/flathub/flathub) and open a PR
   adding a `com.openair.podcast` submission (use the `new-pr` template).
2. Flathub creates a `flathub/com.openair.podcast` repo. Add the files from
   this directory **including the generated** `com.openair.podcast.yml` and
   `pubspec-sources.json`.
3. Flathub CI builds it. Fix up `finish-args`/runtime as requested by reviewers.

Flathub requires the app-id to be a domain you control, or an
`io.github.<owner>.<app>` id. If `openair.podcast` is not a domain you own,
switch the id (and the desktop/metainfo/icon filenames) to
`io.github.OpenAir_Podcast.OpenAir` before submitting.

## Notes / maintenance

- `flathub.json` is limited to `x86_64` because the bundled media libraries may
  not build on `aarch64`. Remove the restriction once arm64 is verified.
- Re-run step 1 and refresh `com.openair.podcast.yml` + `pubspec-sources.json`
  whenever dependencies or the Flutter version change.
- Keep `com.openair.podcast.metainfo.xml` `<releases>` in sync with each release.
