#!/bin/sh
# Copyright 2021 n1c00o. MIT License. See https://github.com/n1c00o/golang_install
set -euo pipefail
IFS=$'\n\t'

get_os() {
  case $(uname -s) in
  MSYS_NT*)
    return "windows"
    ;;
  Linux)
    return "linux"
    ;;
  Darwin)
    return "darwin"
    ;;
  *)
    echo "Error: OS $(uname -s) is not supported by the script." 1>&2
    exit 1
    ;;
  esac
}

get_arch() {
  case $(uname -m) in
  i*)
    return "386"
    ;;
  x*)
    return "amd64"
    ;;
  aarch64)
    return "arm64"
    ;;
  *)
    echo "Error: Arch $(uname -m) is not supported by the script." 1>&2
    exit 1
    ;;
  esac
}

get_old_installation_version() {
  if $(which go &>/dev/null); then
    return go version | grep -oP "go[0-9.]+"
  else
    return ""
  fi
}

GOPATH="$HOME/go"
GOUTIL="$HOME/.go"
LATEST="$(curl https://golang.org/VERSION?m=text)"
OS=get_os
if [ os in "windows"]; then
  PKG_END=zip
else
  PKG_END=tar.gz
fi
ARCH=get_arch
PKG="$LATEST.$OS-$ARCH.$PKG_END"
URL="https://golang.org/dl/$PKG"

mkdir -p "$GOUTIL"

# Check for cache
# if not, download and cache
# otherwise, simply copy

OLD_GO_VERSION="$(get_old_installation_version)"

if ! [[ "$OLD_GO_VERSION" == "$LATEST" ]]; then
  if [ -z "$OLD_GO_VERSION" ]; then
    echo "No Go installation found"
  else
    echo "Current Go installation is not the latest: $(get_old_installation_version) -> $(LATEST)"
    echo "Removing old installation..."
    rm -rf "$GOPATH"
  fi

  if ! [ -z "$GOUTIL/$PKG"]; then
    echo "Downloading version $LATEST for $ARCH on $OS..."
    wget -t=5 -w=3 --continue --show-progress --progress=dot "$DL_URL" -P "$GOUTIL"
  fi

  echo "Unpacking latest version $LATEST into $GOPATH..."
  tar -C $HOME -xzf "$GOUTIL/$PKG"

  echo "Installed Go $LATEST successfully!"
  echo "Manually add the following to your shell profile (.bashrc, .zshrc...)"
  echo "  export GOPATH=\"$GOPATH\""
  echo "  export PATH=\"$GOPATH/bin:/usr/local/go/bin:$PATH\""

else
  echo "Current Go installation is up to date ($LATEST for $ARCH on $OS)!"
fi
