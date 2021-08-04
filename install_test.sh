#!/bin/sh
# Copyright 2021 n1c00o. MIT License. See https://github.com/n1c00o/golang_install
set -euo pipefail
IFS=$'\n\t'

# Remove existing golang installation if any
rm -rf $HOME/go
sh ./install.sh
$HOME/go/bin/go version
