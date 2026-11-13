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

# notebook files (inside the jupyter container)
NOTEBOOK="rgb-lib.ipynb"
NOTEBOOK_OUT="rgb-lib-executed.ipynb"
# max execution time for a single notebook cell, in seconds
CELL_TIMEOUT="${CELL_TIMEOUT:-600}"
# max time to wait for a service to complete startup, in seconds
TIMEOUT=120

_wait_for() {
    local service="$1" pattern="$2" start_time
    start_time=$(date +%s)
    until $COMPOSE logs "$service" |grep -q "$pattern"; do
        if [ $(($(date +%s) - start_time)) -gt $TIMEOUT ]; then
            echo "timeout waiting for $service to start, logs follow"
            $COMPOSE logs "$service"
            _die "could not start services"
        fi
        sleep 1
    done
}

build() {
    local args=()
    # requirement specifier for the rgb-lib package (e.g. a local wheel)
    [ -n "$RGB_LIB_SPEC" ] && args+=("--build-arg" "RGB_LIB_SPEC=$RGB_LIB_SPEC")
    $COMPOSE build "${args[@]}" jupyter
}

start() {
    $COMPOSE down -v
    # see docker-compose.yml for the exposed ports
    EXPOSED_PORTS=(3000 8888)
    for port in "${EXPOSED_PORTS[@]}"; do
        if [ -n "$(ss -HOlnt "sport = :$port")" ];then
            _die "port $port is already bound, services can't be started"
        fi
    done
    $COMPOSE up -d || _die "could not start services"

    # wait for bitcoind to be up
    _wait_for bitcoind 'Bound to'

    # prepare bitcoin funds
    $BCLI createwallet miner >/dev/null
    mine 103 >/dev/null

    # wait for electrs to have completed startup
    _wait_for electrs 'finished full compaction'

    # wait for proxy to have completed startup
    _wait_for proxy 'App is running at http://localhost:3000'

    # wait for jupyter to have completed startup
    local jupyter_str='http://127.0.0.1:8888/lab?token='
    _wait_for jupyter "$jupyter_str"
    local link
    link=$($COMPOSE logs jupyter \
        |grep "${jupyter_str}" |tail -1 |awk '{print $NF}')

    echo
    echo "open jupyter by pointing a browser to the following link:"
    # insert notebook path and show link in console
    echo "${link//\?/\/tree\/${NOTEBOOK}?}"
}

stop() {
    $COMPOSE down -v
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

_execute_notebook() {
    $COMPOSE exec -T jupyter jupyter nbconvert --to notebook --execute \
        --ExecutePreprocessor.timeout="$CELL_TIMEOUT" \
        --output "$NOTEBOOK_OUT" "$NOTEBOOK"
}

run_test() {
    build || _die "demo image build failed"
    start
    echo
    echo "executing the notebook (this will take a while)"
    if ! _execute_notebook; then
        echo
        echo "notebook execution failed, service logs follow"
        $COMPOSE logs
        stop
        _die "demo test failed"
    fi
    # save the executed notebook, so it can be inspected
    $COMPOSE cp "jupyter:/home/jupyter/${NOTEBOOK_OUT}" "./${NOTEBOOK_OUT}"
    stop
    echo
    echo "demo test completed successfully (see ./${NOTEBOOK_OUT})"
}

[ -n "$1" ] || _die "command required"
case $1 in
    build|start|stop) "$1";;
    fund|mine) "$@";;
    test) run_test;;
    *) _die "unrecognized command";;
esac
