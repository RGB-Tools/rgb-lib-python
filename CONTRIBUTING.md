# RGB Lib Python bindings development

The goal of this project is to produce Python bindings for [rgb-lib], which is
included as a submodule. The bindings are created by the [rgb-lib-uniffi]
project, which is located inside the rgb-lib submodule.

## Build

In order to build the bindings package(s), clone the project (`git clone
https://github.com/RGB-Tools/rgb-lib-python --recurse-submodules`), enter the
project root (`cd rgb-lib-python`) and follow the next instructions.

Always make sure the submodules are up-to-date:

```sh
git submodule update --init --recursive
```

The builds of the native Rust library and of the python bindings are carried
out in Docker, using [cross].

### Requirements

- [poetry] (version 2)
- [docker]
- [cargo]
- [cross] (`cargo install cross`)
- cc (`apt install gcc`)

### Local project

In order to build or install the project on the local machine, cross needs to
be properly configured first. To do so, run:

```sh
poetry run python -c 'import build_packages; build_packages.setup_cross()'
```

or, if the project has already been installed (see below):

```sh
poetry run setup-cross
```

The package can then be built with:

```sh
poetry build
```

or installed with:

```sh
poetry install
```

Once the package has been installed, the following scripts are available to
ease development:

- build-packages (builds all the packages, see the [packages] section)
- setup-cross (configure cross to build project/packages)

### Packages

In order to build all the packages for the project, one wheel per supported
platform plus the sdist, if the project has already been installed run:

```sh
poetry run build-packages
```

else run:

```sh
poetry run python build_packages.py
```

The package build script will build the required docker image and use it to
build the wheels for all supported platforms, then builds the sdist. Once the
build completes, the archives will be available in the `dist/` directory. The
script will also cleanup the build artifacts and restore the submodules to
their initial conditions.

### Wheel tags

The `build.py` script contains the wheel tags associated to the supported
platforms. See Python's [platform compatibility tags] for details. You can use
`sysconfig.get_platform()` and `platform.machine()` to get the data for the
running system.

Special care is necessary for macosx wheels, as there
`sysconfig.get_platform()` returns what the Python interpreter was built for
(e.g. the system python reports `macosx-10.9-universal2`, while homebrew python
3.12 might return `macosx-14.0-arm64`) and the operating system (e.g. version
15.1.1) version is not used in a numerical comparison. To have wheels
successfully install it's important to tag them with the correct major version
but use `0` as the minor version (e.g. `macosx-12.0-arm64` will install on OSX
12.7 but `macosx-12.3-arm64` won't).

## Format

To format the code of the build scripts, from the project root run:

```sh
poetry run black *.py
```

## Lint

To lint the code of the build scripts, from the project root run:

```sh
poetry run flake8 *.py
poetry run pylint *.py
```

## Publish

Publishing to PyPI is handled with [poetry] (version 2.0 or later).

Make sure the `dist/` directory only contains the expected packages (e.g. using
`poetry build` produces a wheel that's not meant to be published). The best way
do to this is to empty the `dist/` directory and then build all the [packages].
To check what would be published use `poetry publish --dry-run`.

To configure the access token, which only needs to be done once, run:

```sh
poetry config pypi-token.pypi <token>
```

To publish a new release run:

```sh
poetry publish
```

### Test PyPI

To use the test PyPI instance, the repository needs to be configured in poetry:

```sh
poetry config repositories.test-pypi https://test.pypi.org/legacy/
```

An access token then needs to also be set:

```sh
poetry config pypi-token.test-pypi <token>
```

Publishing needs to specify the registry:

```sh
poetry publish -r test-pypi
```

To install the package from test PyPI:

```sh
pip install --index-url https://test.pypi.org/simple/ rgb-lib
```

[cargo]: https://github.com/rust-lang/cargo
[cross]: https://github.com/cross-rs/cross
[docker]: https://docs.docker.com/engine/install/
[packages]: #packages
[platform compatibility tags]: https://packaging.python.org/en/latest/specifications/platform-compatibility-tags/
[poetry]: https://github.com/python-poetry/poetry
