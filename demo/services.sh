#!/usr/bin/env bash


_die() {
    echo "err: $*"
    exit 1
}


COMPOSE="docker compose"
if ! $COMPOSE >/dev/null; then
    _die "could not call docker compose (hint: install docker compose plugin)"
fi
BCLI="$COMPOSE exec -T -u blits bitcoind bitcoin-cli -regtest"
DATA_DIR="data"

build() {
    $COMPOSE build jupyter
}

start() {
    $COMPOSE down -v
    rm -fr $DATA_DIR
    mkdir -p $DATA_DIR
    # see docker-compose.yml for the exposed ports
    EXPOSED_PORTS=(3000 8888)
    for port in "${EXPOSED_PORTS[@]}"; do
        if [ -n "$(ss -HOlnt "sport = :$port")" ];then
            _die "port $port is already bound, services can't be started"
        fi
    done
    $COMPOSE up -d

    # wait for bitcoind to be up
    until $COMPOSE logs bitcoind |grep -q 'Bound to'; do
        sleep 1
    done

    # prepare bitcoin funds
    $BCLI createwallet miner >/dev/null
    mine 103 >/dev/null

    # wait for electrs to have completed startup
    until $COMPOSE logs electrs |grep -q 'finished full compaction'; do
        sleep 1
    done

    # wait for proxy to have completed startup
    until $COMPOSE logs proxy |grep -q 'App is running at http://localhost:3000'; do
        sleep 1
    done


    # wait for jupyter to have completed startup
    local jupyter_str='http://127.0.0.1:8888/lab?token='
    until $COMPOSE logs jupyter |grep -q "$jupyter_str"; do
        sleep 1
    done
    local link
    link=$($COMPOSE logs jupyter \
        |grep "${jupyter_str}" |tail -1 |awk '{print $NF}')

    echo
    echo "open jupyter by pointing a browser to the following link:"
    # insert notebook path and show link in console
    echo "${link//\?/\/tree\/rgb-lib.ipynb?}"
}

stop() {
    $COMPOSE down -v
    rm -fr $DATA_DIR
}

fund() {
    local address="$1"
    [ -n "$1" ] || _die "destination address required"
    $BCLI -rpcwallet=miner sendtoaddress "$address" 1
    mine
}

mine() {
    local blocks=1
    [ -n "$1" ] && blocks="$1"
    $BCLI -rpcwallet=miner -generate "$blocks"
}

[ -n "$1" ] || _die "command required"
case $1 in
    build|start|stop) "$1";;
    fund|mine) "$@";;
    *) _die "unrecognized command";;
esac
