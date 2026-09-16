# Generative AI disclosure (Flathub submission)

Per the Flathub [Generative AI policy](https://docs.flathub.org/docs/for-app-authors/requirements#generative-ai-policy),
this submission discloses the AI-generated material included in the
application and its Flathub packaging.

## Affected parts and approximate extent

- **Application source code**: a portion of the Dart/Flutter source in this
  repository was developed with the assistance of an AI coding assistant
  (opencode) and was reviewed, edited, and tested by the human maintainer. The
  exact files change over time; the affected code spans the UI layer, services,
  and controllers. Approximate extent: 30-60% of the codebase over the project
  lifetime.
- **Flathub packaging**: the Flatpak template manifest
  (`flatpak/flatpak-flutter.yml`), AppStream metadata
  (`flatpak/io.github.OpenAir_Podcast.OpenAir.metainfo.xml`), desktop entry, and `flathub.json`
  in this submission were generated with AI assistance and reviewed by the
  maintainer before inclusion.
- **CI configuration**: `.github/workflows/build_all_platforms.yml`
  (added/modified in this release) was AI-assisted and human-reviewed.

Material not listed above is original human-authored work.

## Provenance of disclosed material

- The project is Apache-2.0 licensed and distributed from
  <https://github.com/OpenAir-Podcast/OpenAir> (tagged releases).
- AI-generated portions carry the same license and are built from source by
  Flathub; all runtime dependencies are declared in the manifest sources.

## Submission process

This pull request was opened and its description written by a human maintainer
in compliance with the policy: no AI agent opened, automated, or replied on
this submission, and no AI-agent review was requested.
