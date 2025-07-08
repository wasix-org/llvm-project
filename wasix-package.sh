#! /bin/bash

set -euo pipefail

mkdir -p wasix-sysroot
pushd wasix-sysroot
rm -rf ./*

release_info=$(curl -s https://api.github.com/repos/wasix-org/wasix-libc/releases/latest)

for asset_name in sysroot.tar.gz sysroot-eh.tar.gz sysroot-ehpic.tar.gz; do
    asset_url=$(echo "$release_info" | grep -o "browser_download_url.*$asset_name" | cut -d'"' -f3)
    curl -L "$asset_url" -o "./$asset_name"
    tar xzf $asset_name 
done

popd

# clang expects a build of the builtins library at this specific path.
# Technically, we have two flavors of it: PIC and non-PIC. However, most
# software will probably be non-PIC, so we're putting that in as a default;
# software that needs the PIC version must invoke the linker directly to
# pass in the correct version of this library, or just use wasixcc which
# does this automatically.
mkdir -p build-wasix/lib/clang/20/lib/wasm32-unknown-wasi/
cp wasix-sysroot/wasix-sysroot/sysroot/lib/wasm32-wasi/libclang_rt.builtins-wasm32.a \
    build-wasix/lib/clang/20/lib/wasm32-unknown-wasi/libclang_rt.builtins.a

# Giving people a chance to validate the built package...
wasmer package build

echo "Successfully built webc package. You can run 'wasmer publish' to publish to the registry."