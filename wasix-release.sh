#!/usr/bin/env bash

set -euxo pipefail

OUTFILE=${OUTFILE:-LLVM-$(uname -s)-$(uname -m).tar.gz}

# Set the suffix to .exe on windows
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in linux*) OS="linux";; darwin*) OS="apple";; windows*|mingw*|msys*|cygwin*) OS="windows";; *) echo "Unsupported OS: $OS"; exit 1;; esac
SUFFIX=""
if test "$OS" = "windows"; then
  SUFFIX=".exe"
fi

cmake --build build -t bin/lld$SUFFIX -t bin/clang$SUFFIX -t bin/llvm-ar$SUFFIX -t bin/llvm-nm$SUFFIX -t bin/llvm-ranlib$SUFFIX -j16
ls build/bin

# Bit of a weird name, but build* is already gitignored, so we abuse that.
rm -rf build-release
mkdir -p build-release
mkdir -p build-release/lib

# Copy over the necessary files
cp -r build/bin build-release
cp -r build/lib/clang build-release/lib

# Remove unneccessary files
rm -rf build-release/bin/*tblgen*
rm -rf build-release/bin/llvm-lit*
# Strip binaries
strip build-release/bin/*

if test "$OS" = "windows"; then
  : "${MINGW_BIN:?MINGW_BIN must point to the selected MinGW bin directory}"
  for dll in libgcc_s_seh-1.dll libstdc++-6.dll libwinpthread-1.dll; do
    test -f "$MINGW_BIN/$dll"
    cp "$MINGW_BIN/$dll" build-release/bin
  done
fi

ls build-release/bin

cd build-release
tar -czf "$OUTFILE" bin lib
