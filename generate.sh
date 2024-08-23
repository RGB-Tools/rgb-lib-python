#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PY_SRC="${SCRIPT_DIR}/src/rgb_lib/_rgb_lib/"

RGBLIBFFI_PATH="./rgb-lib/bindings/uniffi"
MANIFEST_PATH=(--manifest-path "$RGBLIBFFI_PATH/Cargo.toml")

echo "Generating librgblibuniffi.so..."
cargo build "${MANIFEST_PATH[@]}"
cp "$RGBLIBFFI_PATH/target/debug/librgblibuniffi.so" "$PY_SRC/"

echo "Generating rgb_lib.py..."
cargo run "${MANIFEST_PATH[@]}" \
    --bin rgb-lib-uniffi-bindgen generate $RGBLIBFFI_PATH/src/rgb-lib.udl \
    --out-dir "$PY_SRC" --language python --no-format
