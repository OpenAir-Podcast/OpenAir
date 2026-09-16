# Flathub / Flatpak packaging

This directory contains the Flatpak packaging for OpenAir. Flutter apps cannot
resolve their `pub.dev` dependencies inside the network-less Flathub build
sandbox, so the manifest is a **template** that must first be turned into an
offline manifest by [flatpak-flutter](https://github.com/TheAppgineer/flatpak-flutter).

| File | Purpose |
| --- | --- |
| `flatpak-flutter.yml` | Editable template manifest (input to flatpak-flutter). |
| `io.github.openair_podcast.openair.metainfo.xml` | AppStream metadata required by Flathub. |
| `io.github.openair_podcast.openair.desktop` | Desktop entry, installed as-is. |
| `io.github.openair_podcast.openair.png` | 512x512 app icon. |
| `flathub.json` | Flathub submission options (currently x86_64 only). |
| `io.github.openair_podcast.openair.yml` | **Generated** offline manifest (gitignored). |
| `generated/` | **Generated** pinned pub sources + Flutter SDK module (gitignored). |

## 1. Generate the offline manifest

```sh
pip install -r https://raw.githubusercontent.com/TheAppgineer/flatpak-flutter/main/requirements.txt
git clone https://github.com/TheAppgineer/flatpak-flutter
cd /path/to/OpenAir/flatpak
python3 ~/flatpak-flutter/flatpak-flutter.py flatpak-flutter.yml
```

This writes `io.github.openair_podcast.openair.yml` and the `generated/`
directory (which holds the pinned pub sources as `generated/sources/pubspec.json`
and the Flutter SDK module) into the **current working directory** — so run it
from `flatpak/`. It also picks up foreign-code patches (e.g. the `sqlite3`
package's offline build patch) from flatpak-flutter's registry based on
`pubspec.lock`.

> The `tag:` in the Flutter `sources` entry must match a Flutter release tag.
> Bump it together with the SDK used in CI. Pre-generated SDK modules exist for
> many versions; flatpak-flutter generates the rest on demand.

## 2. Build locally to verify

```sh
flatpak install flathub org.freedesktop.Sdk.Extension.rust-stable  # only if Rust deps appear
flatpak-builder --repo=repo --force-clean --sandbox --user --install \
  --install-deps-from=flathub build io.github.openair_podcast.openair.yml
flatpak run io.github.openair_podcast.openair
```

## 3. Submit to Flathub

1. Fork [`flathub/flathub`](https://github.com/flathub/flathub) and open a PR
   adding a `io.github.openair_podcast.openair` submission (use the `new-pr` template).
2. Flathub creates a `flathub/io.github.openair_podcast.openair` repo. Add the files from
   this directory **including the generated** `io.github.openair_podcast.openair.yml` and
   `generated/`.
3. Flathub CI builds it. Fix up `finish-args`/runtime as requested by reviewers.

### Generative AI policy

Flathub requires AI-generated material to be disclosed and forbids AI agents
from opening or replying on submissions. OpenAir was developed with AI
assistance, so include `flatpak/GENAI_DISCLOSURE.md` (edit the percentage as
appropriate) in the PR, and open it as a human with a human-written description.

The Flathub app-id is `io.github.openair_podcast.openair` because the project
is hosted on GitHub and does not control an `openair.podcast` domain (required by
Flathub's [Application ID rules](https://docs.flathub.org/docs/for-app-authors/requirements#application-id)).

## Notes / maintenance

- `flathub.json` is limited to `x86_64` because the bundled media libraries may
  not build on `aarch64`. Remove the restriction once arm64 is verified.
- Re-run step 1 and refresh `io.github.openair_podcast.openair.yml` + `generated/`
  whenever dependencies or the Flutter version change.
- Keep `io.github.openair_podcast.openair.metainfo.xml` `<releases>` in sync with each release.
