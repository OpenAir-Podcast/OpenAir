#!/usr/bin/env bash
# Fill in the real InstallerSha256 for the winget manifest.
#
# The Windows release asset (openair-v<version>-windows-x64.zip) is built by CI
# and uploaded to the GitHub release. Until that release exists there is no file
# to hash, which is why the checked-in manifest keeps a placeholder. Once the
# v0.18.21+73 (or later) release is published, run this from the repo root:
#
#   packaging/winget/fill_hash.sh
#
# It resolves the asset URL from the manifest itself and rewrites
# InstallerSha256 in place. (The `winget` CI job does the same thing
# automatically via winget-releaser; this is for manual submissions.)

set -euo pipefail

cd "$(dirname "$0")"

MANIFEST="OpenAir-Podcast.OpenAir.installer.yaml"

# Asset URL, e.g. https://github.com/OpenAir-Podcast/OpenAir/releases/download/v0.18.21+73/openair-v0.18.21+73-windows-x64.zip
URL="${1:-}"
if [[ -z "$URL" ]]; then
  URL=$(grep -oP 'https://[^ ]+' "$MANIFEST" | head -1)
fi

ZIP=$(basename "$URL")
if [[ ! -f "$ZIP" ]]; then
  echo "Downloading $URL"
  curl -fL --retry 3 -o "$ZIP" "$URL"
fi

SHA=$(sha256sum "$ZIP" | awk '{print $1}')
echo "Computed sha256: $SHA"

python3 - "$MANIFEST" "$SHA" <<'PY'
import re
import sys

path, sha = sys.argv[1], sys.argv[2]
text = open(path).read()
new, n = re.subn(r'(InstallerSha256:\s*)"[0-9a-fA-F]{64}"?', r'\1"' + sha + '"', text, count=1)
if n != 1:
    open(path).close()
    raise SystemExit('InstallerSha256 line not found in ' + path)
open(path, 'w').write(new)
print('InstallerSha256 updated in', path)
PY