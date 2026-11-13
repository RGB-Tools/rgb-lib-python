## Requirements

Docker and docker compose are required to run this demo.

## Jupyter demo

Build the jupyter docker image with:

```sh
./services.sh build
```

Start regtest blockchain services along with jupyter with:

```sh
./services.sh start
```

Get the link from the console output (`http://localhost:8888/...`) and open it
in a web browser.

Executing each code cell in the notebook from top to bottom reproduces an
example of wallet creation, asset issuance and asset transfer, with alternating
sender and receiver roles. The notebook funds its wallets and mines the
required blocks on its own, via the helpers in `regtest.py`.

The same operations are also available from the console, to fund a regtest
bitcoin address:

```sh
./services.sh fund <bitcoin_address>
```

or to mine a regtest block:

```sh
./services.sh mine
```

Once done with the example, close the jupyter browser page and stop all
services (this will also delete all data produced by services and the demo)
with:

```sh
./services.sh stop
```

The jupyter docker image that has been built will not be removed automatically,
it can be deleted with:

```sh
docker image rm rgb-lib-python-demo
```

## Unattended run

The demo can also be executed without user interaction (this is what CI does to
check the bindings still work), with:

```sh
./services.sh test
```

This builds the image, starts the services, then executes the notebook with
`nbconvert`, failing if any cell raises an error. The executed notebook is
saved as `rgb-lib-executed.ipynb` and the services are stopped on completion.

By default the demo uses the released `rgb-lib` package. To test a locally
built wheel instead, copy it to the `wheels/` directory and set the
`RGB_LIB_SPEC` environment variable to its path inside the container:

```sh
cp ../dist/rgb_lib-<version>-py3-none-manylinux_2_34_x86_64.whl wheels/
RGB_LIB_SPEC=./wheels/rgb_lib-<version>-py3-none-manylinux_2_34_x86_64.whl \
    ./services.sh test
```

The same variable works with `./services.sh build`, to then run the demo
interactively against the local wheel. The maximum execution time allowed for a
single notebook cell (600 seconds by default) can be changed with the
`CELL_TIMEOUT` environment variable.
