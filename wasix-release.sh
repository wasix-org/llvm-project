#!/usr/bin/env bash

set -euxo pipefail

OUTFILE=${OUTFILE:-LLVM-$(uname -s)-$(uname -p).tar.gz}

cmake --build build -t bin/lld -t bin/clang -t bin/llvm-ar -t bin/llvm-nm -t bin/llvm-ranlib -j16

# Bit of a weird name, but build* is already gitignored, so we abuse that.
rm -rf build-release
mkdir -p build-release
mkdir -p build-release/lib

# Copy over the necessary files
cp -r build/bin build-release
cp -r build/lib/clang build-release/lib

# Remove unneccessary files
rm -rf build-release/bin/*tblgen
rm -rf build-release/bin/llvm-lit
# Strip binaries
strip build-release/bin/*

cd build-release
tar -czf $OUTFILE bin lib