#!/usr/bin/env bash
set -euo pipefail
MACHIN="${MACHIN:-machin}"
"$MACHIN" encode tokens.src wabin.src > wabin.mfl
"$MACHIN" build wabin.mfl -o machin-wabin
echo "built ./machin-wabin"
