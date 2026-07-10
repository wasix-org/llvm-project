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

# Default sysroot for direct `clang --target=wasm32-wasixv2` invocations.
# Clang auto-loads <normalized-triple>.cfg from the directory of the clang
# binary; the toolchain is installed at <root>/llvm with sysroots at
# <root>/sysroot (wasixcc layout), and the canonical WASIX v2 sysroot is the
# exnref-EH flavor. An explicit --sysroot on the command line overrides this.
cat > build-release/bin/wasm32-unknown-wasixv2.cfg <<'CFG'
--sysroot=<CFGDIR>/../../sysroot/sysroot-exnref-eh
CFG

# Remove unneccessary files
rm -rf build-release/bin/*tblgen*
rm -rf build-release/bin/llvm-lit*
# Strip binaries
strip build-release/bin/*

ls build-release/bin

cd build-release
tar -czf $OUTFILE bin lib