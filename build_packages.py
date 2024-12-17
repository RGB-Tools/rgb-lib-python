"""Module to build native wheels and sdist."""

from fileinput import input as finput
from glob import glob
from os import environ, remove
from pathlib import Path
from re import sub
from shutil import copy
from subprocess import run
from tomllib import load

from build import OSX_VERSION, PLATFORMS, PYTHON_LIB_DIR, UNIFFI_DIR, get_lib_name

CROSS_COMMIT = "4090bec"
CROSS_TOOLCHAIN_COMMIT = "d139724"
OUTPUT_DIR = Path("dist")


def cleanup(platform):
    """Cleanup the build artifacts for the given platform."""
    print("Cleaning up build artifacts")
    bindings = PYTHON_LIB_DIR.joinpath("rgb_lib.py")
    lib_name = get_lib_name(platform)
    native_lib = PYTHON_LIB_DIR.joinpath(lib_name)
    wheel = get_wheel_name()
    for file in [bindings, native_lib, wheel]:
        print(f"Removing file {str(file)}")
        remove(file)


def configure_cross():
    """Configure cross options."""
    src = Path("Cross.toml")
    dst = UNIFFI_DIR.joinpath("Cross.toml")
    copy(src, dst)


def get_version():
    """Get the package version."""
    with open("pyproject.toml", "rb") as pyproject_fd:
        pyproject_toml = load(pyproject_fd)
    return pyproject_toml["project"]["version"]


def get_wheel_name():
    """Get the name of the original wheel built by poetry."""
    return list(OUTPUT_DIR.glob("rgb_lib-*-cp3*-cp3*-*.whl"))[0]


def main():
    """Build wheels for all platforms and the source distribution."""
    # setup cross files
    print("\n\n\n==== setting up cross")
    setup_cross()
    # build platform-specific wheels
    for platform in PLATFORMS:
        print(f"\n\n\n==== bulding wheel for platform {platform}")
        environ["PLATFORM"] = platform
        run(["poetry", "build", "--format", "wheel"], check=True)
        retag_wheel(platform)
        cleanup(platform)
    # build the platform-independent sdist
    print("\n\n\n==== bulding source distribution")
    run(["poetry", "build", "--format", "sdist"], check=True)
    # reset submodules
    print("\n\n\n==== resetting submodules")
    reset_submodules()


def patch_cross_files():
    """Patch cross files."""
    # patch base ubuntu image version
    files = glob("cross/docker/Dockerfile*")
    files.extend(glob("cross/docker/cross-toolchains/docker/Dockerfile.*"))
    substitutions = [
        (r"ubuntu:20", r"ubuntu:22"),
    ]
    patch_files(files, substitutions)
    # patch linux-image.sh for updated ubuntu
    files = ["cross/docker/linux-image.sh"]
    substitutions = [
        (r"kversion=5.10.0-26", r"kversion=6.1.0-29"),
        (r"bullseye", r"bookworm"),
        (r"archive-key-{7.0,8,9,10,11}", r"archive-key-12"),
        (r"release-{7,8,9,10,11}", r"release-12"),
        (r"archive_{2020,2021,2022,2023,2024}", r"archive_2025"),
    ]
    patch_files(files, substitutions)
    # patch wine version for updated ubuntu
    files = ["cross/docker/wine.sh"]
    substitutions = [
        (r'version="9.0.0.0~focal-1"', r'version="10.0.0.0~jammy-1"'),
        (r"focal", r"jammy"),
    ]
    patch_files(files, substitutions)
    # patch darwin scripts
    files = ["cross/docker/cross-toolchains/docker/darwin.sh"]
    substitutions = [
        (r"OSX_VERSION_MIN=10.7", rf"OSX_VERSION_MIN={OSX_VERSION}"),
    ]
    patch_files(files, substitutions)
    files = ["cross/docker/cross-toolchains/docker/darwin-entry.sh"]
    substitutions = [
        (r"-fuse-ld=", r"-fuse-ld=/opt/osxcross/bin/"),
    ]
    patch_files(files, substitutions)


def patch_files(files, substitutions):
    """Patch a list of files according to the provided substitutions."""
    with finput(files=files, inplace=True) as file:
        for line in file:
            for pattern, replacement in substitutions:
                line = sub(pattern, replacement, line)
            print(line, end="")


def reset_submodules():
    """Restore submodules to their original content."""
    run(["git", "submodule", "update", "--force", "--recursive"], check=True)
    cross_toml = UNIFFI_DIR.joinpath("Cross.toml")
    if cross_toml.exists():
        remove(cross_toml)


def retag_wheel(platform):
    """Retag the wheel with the correct tags."""
    print("Retagging wheel")
    wheel_tag = PLATFORMS[platform]["wheel_tag"]
    wheel = get_wheel_name()
    # remove original tags
    run(
        ["wheel", "tags", "--remove", str(wheel)],
        check=True,
    )
    # set final tags
    run(
        [
            "wheel",
            "tags",
            "--python-tag",
            "py3",
            "--abi-tag",
            "none",
            "--platform-tag",
            wheel_tag,
            str(wheel),
        ],
        check=True,
    )


def setup_cross():
    """Setup cross for cross-building."""
    reset_submodules()
    run(["git", "reset", "--hard", CROSS_COMMIT], cwd="cross", check=True)
    run(
        ["git", "reset", "--hard", CROSS_TOOLCHAIN_COMMIT],
        cwd="cross/docker/cross-toolchains",
        check=True,
    )
    patch_cross_files()
    configure_cross()


if __name__ == "__main__":
    main()
