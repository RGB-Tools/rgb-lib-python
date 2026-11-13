"""Module to operate the regtest services used by the demo.

The notebook runs in a container alongside the services defined in
compose.yaml, so bitcoind is called via its RPC interface and electrs via the
electrum protocol. This allows the notebook to fund wallets and mine blocks on
its own, without the need to call services.sh from the console.
"""

from base64 import b64encode
from json import dumps, load, loads
from socket import create_connection
from time import monotonic, sleep
from urllib.request import Request, urlopen

BITCOIND_URL = "http://bitcoind:18443"
BITCOIND_USER = "user"
BITCOIND_PASSWORD = "default_password"
ELECTRS_ADDRESS = ("electrs", 50001)
MINER_WALLET = "miner"
RPC_TIMEOUT = 30
SYNC_TIMEOUT = 120


def _bitcoind_rpc(method, params=None, wallet=None):
    """Call the given method on the bitcoind RPC interface."""
    url = BITCOIND_URL + (f"/wallet/{wallet}" if wallet else "")
    credentials = f"{BITCOIND_USER}:{BITCOIND_PASSWORD}".encode()
    request = Request(
        url,
        data=dumps({"id": "demo", "method": method, "params": params or []}).encode(),
        headers={
            "Authorization": "Basic " + b64encode(credentials).decode(),
            "Content-Type": "application/json",
        },
    )
    with urlopen(request, timeout=RPC_TIMEOUT) as response:
        result = load(response)
    if result.get("error"):
        raise RuntimeError(f'bitcoind RPC error: {result["error"]}')
    return result["result"]


def _electrs_height():
    """Get the height of the chain tip indexed by electrs."""
    request = dumps({"id": 0, "method": "blockchain.headers.subscribe", "params": []})
    with create_connection(ELECTRS_ADDRESS, timeout=RPC_TIMEOUT) as sock:
        sock.sendall(request.encode() + b"\n")
        data = b""
        while not data.endswith(b"\n"):
            chunk = sock.recv(4096)
            if not chunk:
                raise RuntimeError("electrs closed the connection")
            data += chunk
    return loads(data)["result"]["height"]


def _wait_electrs(height):
    """Wait for electrs to have indexed the chain up to the given height."""
    deadline = monotonic() + SYNC_TIMEOUT
    while _electrs_height() < height:
        if monotonic() > deadline:
            raise RuntimeError(f"electrs did not index block {height} in time")
        sleep(1)


def fund(address, amount=1):
    """Send the given amount of bitcoins to the given address and confirm it."""
    txid = _bitcoind_rpc("sendtoaddress", [address, amount], wallet=MINER_WALLET)
    print(f"sent {amount} BTC to {address} (txid {txid})")
    mine()


def mine(blocks=1):
    """Mine the requested number of blocks, then wait for electrs to sync."""
    address = _bitcoind_rpc("getnewaddress", wallet=MINER_WALLET)
    _bitcoind_rpc("generatetoaddress", [blocks, address])
    height = _bitcoind_rpc("getblockcount")
    _wait_electrs(height)
    print(f"mined {blocks} block(s), chain height is now {height}")
