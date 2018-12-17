#!/usr/bin/env bash

# Run tests in the vagrant VM
vagrant ssh -c "/vagrant/tests/run-tests.sh $@"