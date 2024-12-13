Build CLANG 16 to WASM/WASIX

1. Install `clang-16` and `llvm-16`:
```
sudo apt install clang-16 llvm-16
```
2. Clone the wasix-libc repo with its submodules:
```
git clone --recurse-submodules https://github.com/wasix-org/wasix-libc
```
3. Build the sysroot containing the C++ standard library
```
CC=clang-16 AR=llvm-ar-16 NM=llvm-nm-16 RANLIB=llvm-ranlib-16 ./build32.sh
```
4. Copy the `sysroot32` folder into the `~/wasix` folder:
```
cp -r /path/to/sysroot32 ~/wasix
```
5. Apply the `wasix.patch`:
```
git am wasix.patch
```
6. Configure the project:
```
cmake -S llvm -B build -G Ninja --toolchain $PWD/wasix_toolchain.cmake \
-DLLVM_ENABLE_PROJECTS='clang;lld' \
-DLLVM_ENABLE_RUNTIMES='' \
-DCMAKE_INSTALL_PREFIX=~/clang_wasm/llvm16 \
-DCMAKE_BUILD_TYPE=MINSIZEREL \
-DLLVM_TARGETS_TO_BUILD="WebAssembly" \
-DCMAKE_CXX_COMPILER_WORKS=1 \
-DLLVM_DEFAULT_TARGET_TRIPLE=wasm32-wasi \
-DCMAKE_CROSSCOMPILING_EMULATOR=wasmer \
-DLLVM_ENABLE_LIBCXX=ON \
-DNO_INSTALL_RPATH=ON \
-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
-DLLVM_BUILD_TESTS=OFF \
-DLLVM_INCLUDE_TESTS=OFF \
-DLLVM_INCLUDE_UTILS=OFF \
-DLLVM_BUILD_EXAMPLES=OFF \
-DLLVM_INCLUDE_EXAMPLES=OFF \
-DBUILD_SHARED_LIBS=OFF \
-DLLVM_ENABLE_LTO=OFF \
-DLLVM_ENABLE_PIC=OFF
```
7. Build the projects:
```
ninja -C build
```
8. Install the artifacts
```
ninja -C build install
```
This will install the clang and llvm binaries under `~/clang_wasix/llvm16`. Now because of some limitations, applying `--asyncify` on the 
produced clang will result in an error when trying to run it using the Wasmer runtime. The solution is to split clang into two binaries:
- `clang`: Full featured clang without `--asynicfy`
- `clang-slim`: Only the client side of `clang` which when invoked, will spawn the `clang` binary. This binary is small enough that running a `--asyncify` pass is okay
9. Make a backup of the `clang` binary:
```
cp ~/clang_wasm/llvm16/bin/clang-16 ~/clang_wasm/llvm16/bin/clang-16-full
```
Now we need to recompile the project to procude `clang-slim`
10. Apply the `clang-slim.patch` file:
```
git apply clang-slim.patch
```
11. Repeat steps 7 and 8
12. Make a backup of the slim version of clang:
```
cp ~/clang_wasm/llvm16/bin/clang-16 ~/clang_wasm/llvm16/bin/clang-16-slim
```
13. Now it is up to you what to include the final wasmer package or not. For every file, remember to run `wasm-opt` with some optimization flag.
14. Remember to in addition to the optimizations also `--asyncify` the `clang-16-slim` binary
