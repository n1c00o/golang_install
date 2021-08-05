#!/bin/sh
# Copyright 2021 n1c00o. MIT License. See https://github.com/n1c00o/golang_install
set -eu

GOPATH="$HOME/go"
GOUTIL="$HOME/.go"
LATEST="$(curl -sS https://golang.org/VERSION?m=text)"

case $(uname -s) in
MSYS_NT*)
  OS="windows"
  ;;
Linux)
  OS="linux"
  ;;
Darwin)
  OS="darwin"
  ;;
*)
  echo "Error: OS $(uname -s) is not supported by the script." 1>&2
  exit 1
  ;;
esac

if [ "$OS" = "windows" ]; then
  PKG_END=zip
else
  PKG_END=tar.gz
fi

case $(uname -m) in
i*)
  ARCH="386"
  ;;
x*)
  ARCH="amd64"
  ;;
aarch64)
  ARCH="arm64"
  ;;
*)
  echo "Error: Arch $(uname -m) is not supported by the script." 1>&2
  exit 1
  ;;
esac

PKG="$LATEST.$OS-$ARCH.$PKG_END"
URL="https://golang.org/dl/$PKG"

mkdir -p "$GOUTIL"

if which go 1>/dev/null; then
  OLD_GO_VERSION=$(go version | grep -oP "go[0-9.]+")
else
  OLD_GO_VERSION=""
fi

remove_old_install() {
  echo "Removing old installation..."
  rm -rf "$GOPATH"
}

FORCE=0
if [ $# -eq 1 ]; then
  if [ "$1" = "-f" ]; then
    FORCE=1
  fi
fi
# Check for cache
# if not, download and cache
# otherwise, simply copy
echo "Checking for existing installation in $GOPATH"

if ! [ "$OLD_GO_VERSION" = "$LATEST" ]; then
  if [ -z "$OLD_GO_VERSION" ]; then
    echo "No Go installation found"
  else
    echo "Current Go installation is not the latest: $OLD_GO_VERSION -> $LATEST"

    if [ $FORCE -eq 1 ]; then
      remove_old_install
    else
      echo "Would you like to remove the existing installation? [y/N] "
      read -r yn

      case "$yn" in
      [Yy]*)
        remove_old_install
        ;;
      *)
        echo "Installation cancelled..."
        exit 0
        ;;
      esac
    fi

  fi

  if ! [ -e "$GOUTIL/$PKG" ]; then
    echo "Downloading version $LATEST for $ARCH on $OS..."
    wget -t=5 --random-wait --continue --show-progress --progress=bar:force "$URL" -P "$GOUTIL"
  fi

  echo "Unpacking latest version $LATEST into $GOPATH..."
  tar -C "$HOME" -xzf "$GOUTIL/$PKG"

  echo "Installed Go $LATEST successfully!"
  echo "Manually add the following to your shell profile (.bashrc, .zshrc...)"
  echo "  export GOPATH=\"$GOPATH\""
  echo "  export PATH=\"$GOPATH/bin:/usr/local/go/bin:\$PATH\""

else
  echo "Current Go installation is up to date ($LATEST for $ARCH on $OS)!"
fi
