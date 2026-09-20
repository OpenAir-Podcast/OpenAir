# Linux / Snap packaging

This directory and `snap/snapcraft.yaml` contain the Snap packaging setup for OpenAir.

| File | Purpose |
| --- | --- |
| `snap/snapcraft.yaml` | Snapcraft manifest for building and packaging the Snap application. |
| `packaging/snap/README.md` | Documentation for building, testing, and distributing the Snap package. |

## 1. Local Build Instructions

The build workflow uses Flutter to create the release bundle, which `snapcraft` packages into a `.snap` file:

```bash
# 1. Build the Flutter Linux Desktop release bundle
flutter build linux --release

# 2. Build the snap package
snapcraft pack --destructive-mode
# or simply:
# snapcraft
```

This generates the `.snap` package (e.g., `openair_0.18.21_amd64.snap`).

## 2. Local Testing

Install the generated snap package locally:

```bash
sudo snap install --dangerous openair_0.18.21_amd64.snap
```

Run the application:

```bash
openair
```

## 3. Snap Store Submission

1. Register your snap name on the Snap Store:
   ```bash
   snapcraft register openair
   ```
2. Upload the built `.snap` package to the stable channel:
   ```bash
   snapcraft upload --release=stable openair_0.18.21_amd64.snap
   ```
