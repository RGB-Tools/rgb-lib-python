"""Module to build the native library and the bindings."""

from os import getenv
from pathlib import Path
from platform import machine
from shutil import copy
from subprocess import run
from sysconfig import get_platform

PYTHON_LIB_DIR = Path("rgb_lib")
UNIFFI_DIR = Path("rgb-lib/bindings/uniffi")
MANIFEST_PATH = UNIFFI_DIR.joinpath("Cargo.toml")
UDL_PATH = UNIFFI_DIR.joinpath("src", "rgb-lib.udl")
OSX_VERSION = "12.3"

# supported platforms metadata
PLATFORMS = {
    "linux-x86_64": {
        "target": "x86_64-unknown-linux-gnu",
        "filename": "librgblibuniffi",
        "extension": "so",
        "wheel_tag": "manylinux_2_34_x86_64",
    },
    "linux-aarch64": {
        "target": "aarch64-unknown-linux-gnu",
        "filename": "librgblibuniffi",
        "extension": "so",
        "wheel_tag": "manylinux_2_34_aarch64",
    },
    "macosx-x86_64": {
        "target": "x86_64-apple-darwin",
        "filename": "librgblibuniffi",
        "extension": "dylib",
        "wheel_tag": "macosx_12_0_x86_64",
    },
    "macosx-arm64": {
        "target": "aarch64-apple-darwin",
        "filename": "librgblibuniffi",
        "extension": "dylib",
        "wheel_tag": "macosx_12_0_arm64",
    },
    "win-amd64": {
        "target": "x86_64-pc-windows-gnu",
        "filename": "rgblibuniffi",
        "extension": "dll",
        "wheel_tag": "win_amd64",
    },
}


def build():
    """Handle the platform-specfic part of the build process."""
    # platform selection: from env var or auto-detected
    platform = getenv("PLATFORM")
    if not platform:
        platform = get_current_platform()
    elif platform and platform not in PLATFORMS:
        raise RuntimeError(f"unsupported platform: {platform}")
    # platform-specific build
    build_docker_image(platform)
    build_rust_library(platform)
    copy_rust_library(platform)
    generate_bindings(platform)


def build_docker_image(platform):
    """Build the docker image to cross-build for the provided platform."""
    target = PLATFORMS[platform]["target"]
    if "macosx" in platform:
        target = f"{target}-cross"
    args = ["cargo", "build-docker-image", target, "--tag", "local"]
    if "macosx" in platform:
        mac_sdk_url = (
            "https://github.com/joseluisq/macosx-sdks/releases/download/"
            f"{OSX_VERSION}/MacOSX{OSX_VERSION}.sdk.tar.xz"
        )
        args.extend(["--build-arg", f"MACOS_SDK_URL={mac_sdk_url}"])
    run(args, cwd="cross", check=True)


def build_rust_library(platform):
    """Build the Rust library for the specified target."""
    target = PLATFORMS[platform]["target"]
    run(
        [
            "cross",
            "build",
            "--manifest-path",
            str(MANIFEST_PATH),
            "--release",
            "--target",
            target,
        ],
        check=True,
    )


def copy_rust_library(platform):
    """Copy the compiled Rust library to the Python package directory."""
    target = PLATFORMS[platform]["target"]
    lib_name = get_lib_name(platform)
    src = UNIFFI_DIR.joinpath("target", target, "release", lib_name)
    dst = PYTHON_LIB_DIR.joinpath(lib_name)
    copy(src, dst)


def generate_bindings(platform):
    """Generate Python bindings using uniffi-bindgen."""
    target = PLATFORMS[platform]["target"]
    lib_name = get_lib_name(platform)
    lib_path = UNIFFI_DIR.joinpath(
        "target",
        target,
        "release",
        lib_name,
    )
    if not lib_path.exists():
        raise RuntimeError(f"lib path ({lib_path}) not found")
    run(
        [
            "cargo",
            "run",
            "--manifest-path",
            str(MANIFEST_PATH),
            "--bin",
            "rgb-lib-uniffi-bindgen",
            "generate",
            str(UDL_PATH),
            "--out-dir",
            str(PYTHON_LIB_DIR),
            "--language",
            "python",
            "--no-format",
        ],
        check=True,
    )


def get_current_platform():
    """Get the platform for the running system."""
    platform = get_platform()
    if platform.startswith("macosx"):
        arch = machine()
        platform = f"macosx-{arch}"
    return platform


def get_lib_name(platform):
    """Get library name based on provided target."""
    filename = PLATFORMS[platform]["filename"]
    extension = PLATFORMS[platform]["extension"]
    return f"{filename}.{extension}"


if __name__ == "__main__":
    build()
