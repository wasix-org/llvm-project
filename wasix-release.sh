#! /bin/bash

set -euxo pipefail

OUTFILE=${OUTFILE:-LLVM-$(uname -s)-$(uname -p).tar.gz}

# Bit of a weird name, but build* is already gitignored, so we abuse that.
rm -rf build-release
mkdir -p build-release

cd build
ninja -j16
cd ..

mkdir -p build-release/bin

cp -L build/bin/clang build-release/bin/
ln -s clang build-release/bin/clang++

cp -L build/bin/lld build-release/bin/
ln -s lld build-release/bin/wasm-ld

cp -L build/bin/llvm-ar build-release/bin/
cp -L build/bin/llvm-nm build-release/bin/
cp -L build/bin/llvm-ranlib build-release/bin/

mkdir -p build-release/lib
cp -r build/lib/clang build-release/lib/

cd build-release
tar -czf $OUTFILE bin lib