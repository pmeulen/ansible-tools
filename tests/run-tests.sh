#!/usr/bin/env bash

# Script to run tests
# Installs bats, a bash test framework, if it does not exists

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
bats_dir=${script_dir}/bats
BATS=${bats_dir}/bin/bats
py3_dir=${script_dir}/py3

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

echo "Running tests using distro python and ansible version:"
python --version
ansible --version

cd ${script_dir}
args=$@
if [ -z "$args" ]; then
    args="*.bats"
fi
echo "Running ${BATS} $args"
${BATS} $args
res=$?
if [ ! $res -eq 0 ]; then
    echo "Python 2 tests failed"
    cd $CWD
    exit $res
fi

if [ ! -d ${py3_dir} ]; then
    echo "Creating python3 environment for running tests"
    cd ${script_dir}
    pyvenv py3
    source py3/bin/activate
    pip install --upgrade pip
    pip install ansible
    pip install python3-keyczar
fi

echo "Running tests using ansible and keyczart from python3 environment:"
cd ${script_dir}
source py3/bin/activate
python --version
ansible --version

echo "Running ${BATS} $args"
${BATS} $args
res=$?

if [ ! $res -eq 0 ]; then
    echo "Python 3 tests failed"
    cd $CWD
    exit $res
fi

cd $CWD
exit $res
