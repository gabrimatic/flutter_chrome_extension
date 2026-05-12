#!/usr/bin/env bash
set -euo pipefail

flutter build web \
  --csp \
  --no-web-resources-cdn \
  --no-source-maps \
  --no-wasm-dry-run
