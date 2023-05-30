#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PY_SRC="${SCRIPT_DIR}/src/rgb_lib/_rgb_lib/"

RGBLIBFFI_PATH="./rgb-lib/rgb-lib-ffi"
MANIFEST_PATH=(--manifest-path "$RGBLIBFFI_PATH/Cargo.toml")

echo "Generating librgblibffi.so..."
cargo build --release "${MANIFEST_PATH[@]}"
cp "$RGBLIBFFI_PATH/target/release/librgblibffi.so" "$PY_SRC/"

echo "Generating rgb_lib.py..."
cargo run --release "${MANIFEST_PATH[@]}" \
    --bin rgb-lib-ffi-bindgen generate $RGBLIBFFI_PATH/src/rgb-lib.udl \
    --out-dir $PY_SRC --language python --no-format
