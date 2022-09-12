# RGB Lib Python bindings

This project builds a Python library, `rgb-lib`, for the [rgb-lib]
Rust library, which is included as a git submodule. The bindings are created by
the [rgb-lib-ffi] project, which is located inside the rgb-lib submodule.

## Install from PyPI

Install the [latest release] by running:
```shell
pip install rgb-lib
```

## Install locally

### Requirements
- [cargo]
- [poetry]

In order to install the project locally, run:
```shell
# Update the submodule
git submodule update --init

# Generate the bindings
./generate.sh

# Build the source and wheels archives
poetry build

# Install the wheel
pip install ./dist/rgb_lib-<version>-py3-none-any.whl

# or install the sdist
pip install ./dist/rgb-lib-<version>.tar.gz
```


[cargo]: https://github.com/rust-lang/cargo
[rgb-lib]: https://github.com/RGB-Tools/rgb-lib
[rgb-lib-ffi]: https://github.com/RGB-Tools/rgb-lib/tree/master/rgb-lib-ffi
[latest release]: https://pypi.org/project/rgb-lib/
[poetry]: https://github.com/python-poetry/poetry
