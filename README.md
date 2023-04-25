# RGB Lib Python bindings

This project builds a Python library, `rgb-lib`, for the [rgb-lib]
Rust library, which is included as a git submodule. The bindings are created by
the [rgb-lib-ffi] project, which is located inside the rgb-lib submodule.

## Install from PyPI

Install the [latest release] by running:
```shell
pip install rgb-lib
```

## Demo

The `demo/` directory contains a demonstration of the most common operations in
the form of a Jupyter notebook. See the included `README.md` file for more
details.

## Install locally

### Requirements
- [cargo]
- [poetry] 1.4+

In order to install the project locally, run:
```shell
# Update the submodule
git submodule update --init

# Generate the bindings
./generate.sh

# Build the source and wheels archives
poetry build

# Install the wheel (replacing <version> with built version)
pip install ./dist/rgb_lib-<version>-py3-none-any.whl

# or install the sdist (replacing <version> with built version)
pip install ./dist/rgb_lib-<version>.tar.gz
```

## Build in Docker
In order to build the project in a Docker container, run:
```shell
# Update the submodule
git submodule update --init

# run the build script
./build_in_docker.sh
```

The `build_in_docker.sh` script will build the docker image and use it to first
generate the bindings, then build the source and wheel archives. Once the build
completes, archives will be available in the `dist/` directory as if they were
built locally.

## Publish

Publishing to PyPI is handled with Poetry.

To configure the access token, which only needs to be done once, run:
```shell
poetry config pypi-token.pypi <token>
```

To publish a new release run:
```shell
poetry publish
```


[cargo]: https://github.com/rust-lang/cargo
[rgb-lib]: https://github.com/RGB-Tools/rgb-lib
[rgb-lib-ffi]: https://github.com/RGB-Tools/rgb-lib/tree/master/rgb-lib-ffi
[latest release]: https://pypi.org/project/rgb-lib/
[poetry]: https://github.com/python-poetry/poetry
