#!/usr/bin/env bash
#
# Full site build. Chains the two Swift generators that produce data
# the Eleventy templates need, then runs Eleventy.
#
# Run from the repo root:
#   bash scripts/build-site.sh
#
# Or via the bun script wrapper:
#   bun run site:full
#
# Order matters:
#   1. build-cable-db.swift writes docs/whatcable.db and docs/cables.json
#      from data/known-cables.md + Sources/.../usbif-vendors.tsv.
#   2. render-known-cables.swift parses data/known-cables.md and writes
#      src/_includes/cables-table.njk (the noscript fallback table).
#   3. Eleventy reads src/ and writes docs/, including cables.njk which
#      includes the table partial from step 2.

set -euo pipefail

cd "$(dirname "$0")/.."

echo "=> Building cable database..."
swift scripts/build-cable-db.swift

echo ""
echo "=> Rendering cables table partial..."
swift scripts/render-known-cables.swift

echo ""
echo "=> Building site with Eleventy..."
bun run site:build

echo ""
echo "Site build complete. Output in docs/."
