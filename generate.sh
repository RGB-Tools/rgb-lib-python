#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PY_SRC="${SCRIPT_DIR}/rgb_lib/_rgb_lib/"

RGBLIBFFI_PATH="./rgb-lib/rgb-lib-ffi"
MANIFEST_PATH=(--manifest-path "$RGBLIBFFI_PATH/Cargo.toml")

echo "Generating librgblibffi.so..."
cargo build "${MANIFEST_PATH[@]}"
cp "$RGBLIBFFI_PATH/target/debug/librgblibffi.so" "$PY_SRC/"

echo "Generating rgb_lib.py..."
RGBFFI_BINDGEN_OUTPUT_DIR="$PY_SRC" cargo run "${MANIFEST_PATH[@]}" \
    --package rgb-lib-ffi-bindgen -- \
    --language python --udl-file $RGBLIBFFI_PATH/src/rgb-lib.udl
