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

Once services are running, a regtest bitcoin address can be funded from the
console with:

```sh
./services.sh fund <bitcoin_address>
```

and a regtest block can be mined with:

```sh
./services.sh mine
```

Executing each code cell in the notebook from top to bottom reproduces an
example of wallet creation, asset issuance and asset transfer, with alternating
sender and receiver roles.

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
