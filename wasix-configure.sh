#! /bin/bash

set -euxo pipefail

rm -rf build
mkdir build

cmake llvm \
  -B build \
  -G Ninja \
  -DLLVM_PARALLEL_{COMPILE,LINK,TABLEGEN}_JOBS=8 \
  -DLLVM_ENABLE_PROJECTS='clang;lld;clang-tools-extra' \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DLLVM_BUILD_TOOLS=ON \
  -DLLVM_BUILD_UTILS=OFF \
  -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
  -DCLANG_ENABLE_OBJC_REWRITER=OFF \
  -DLLVM_TARGETS_TO_BUILD="WebAssembly" \
  -DCLANG_VENDOR="WASIX" \
  -DLLD_VENDOR="WASIX" \
  -DLLVM_APPEND_VC_REV="OFF"
