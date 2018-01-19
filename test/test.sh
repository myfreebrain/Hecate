#! /bin/bash
set -euo pipefail

service postgresql start

yarn install

cd $(dirname $0)/..
~/.cargo/bin/cargo build

echo "CREATE DATABASE hecate" | psql -U postgres

function startsrv() {
    ~/.cargo/bin/cargo run&

    sleep 2

    # On OSX when cargo first runs it will be connected to `localhost:8000`
    # but not to 127.0.0.1. curl localhost:8000  will work but curl 127.0.0.1 will fail.
    # Node request converts localhost:8000 to 127.0.0.1 behind the scenes, resulting in failure
    # running a second startsrc fixes this.
    if ! curl '127.0.0.1:8000'; then
        startsrv
    else
        testsrv
    fi
}

function testsrv() {
    for TEST in test/*.test.js; do
        node $TEST
    done

}

startsrv