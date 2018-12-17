#!/usr/bin/env bash

# Script to run tests
# Installs bats, a bash test framework, if it does not exists

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
bats_dir=${script_dir}/bats
BATS=${bats_dir}/bin/bats

CWD=`pwd`

if [ ! -f  ${BATS} ]; then
    echo "bats (${BATS}) is not installed."
    echo "Install bats'..."
    cd ${script_dir}
    git clone https://github.com/bats-core/bats-core.git bats
    if [ $? != 0 ]; then
        echo "ERROR: bats install failed"
        cd $CWD
        exit 1
    fi
    cd $CWD
fi

cd ${script_dir}
args=$@
if [ -z "$args" ]; then
    args="*.bats"
fi
echo "Running ${BATS} $args"
${BATS} $args
res=$?
cd $CWD
exit $res
