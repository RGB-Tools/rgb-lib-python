# RGB Lib Python bindings

Python bindings for the [rgb-lib] Rust library.

## Installation

### From PyPI (wheel)

Install the [latest stable release] from PyPI by running:

```sh
pip install rgb-lib
```

### From source distribution (sdist)

Installation from source distribution (tested on Linux) has the following
requirements:

- [docker]
- [cargo]
- [cross]
- cc

The process is quite long and requires several GB of disk space, due to the
builds of the required Docker image and the rgb-lib rust library.

## Usage

Once installed, you can import the `rgb_lib` module and call its APIs.

As an example:

```python
import rgb_lib

keys = rgb_lib.generate_keys(rgb_lib.BitcoinNetwork.REGTEST)
print(keys.account_xpub)
```

## Demo

The `demo/` directory contains a demonstration of the most common operations in
the form of a Jupyter notebook. See the included `README.md` file for more
details.

[cargo]: https://github.com/rust-lang/cargo
[docker]: https://docs.docker.com/engine/install/
[latest stable release]: https://pypi.org/project/rgb-lib/
[rgb-lib-uniffi]: https://github.com/RGB-Tools/rgb-lib/tree/master/bindings/uniffi
[rgb-lib]: https://github.com/RGB-Tools/rgb-lib
