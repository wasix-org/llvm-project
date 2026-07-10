// WASIX fork test: wasm32-wasixv2 bakes the WASIX platform contract into the
// driver as overridable defaults. wasm32-wasix (v1) is only a rename of its
// wasm32-wasi-based setup and must receive no behavior changes.

// Compile defaults: always-threaded (pthread + thread features), wasm EH
// (exnref) with wasm SjLj, local-exec TLS model for non-PIC.
// RUN: %clang -### --target=wasm32-wasixv2 -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=CC1_V2 %s
// CC1_V2: "-cc1"
// CC1_V2-SAME: "-pthread"
// CC1_V2-SAME: "-ftls-model=local-exec"
// CC1_V2-SAME: "-target-feature" "+atomics"
// CC1_V2-SAME: "-target-feature" "+bulk-memory"
// CC1_V2-SAME: "-target-feature" "+mutable-globals"
// CC1_V2-SAME: "-target-feature" "+sign-ext"
// CC1_V2-SAME: "-target-feature" "+exception-handling"
// CC1_V2-SAME: "-exception-model=wasm"
// CC1_V2-SAME: "-mllvm" "-wasm-enable-eh"
// CC1_V2-SAME: "-mllvm" "-wasm-enable-sjlj"
// CC1_V2-SAME: "-mllvm" "-wasm-use-legacy-eh=false"

// -fno-exceptions opts out of the EH defaults.
// RUN: %clang -### --target=wasm32-wasixv2 -fno-exceptions -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=NO_EH %s
// NO_EH: "-cc1"
// NO_EH-NOT: "-wasm-enable-eh"
// NO_EH-NOT: "-exception-model=wasm"

// An explicit -fwasm-exceptions takes the stock upstream path (eh only, no
// implicit sjlj).
// RUN: %clang -### --target=wasm32-wasixv2 -fwasm-exceptions -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=EXPLICIT_EH %s
// EXPLICIT_EH: "-cc1"
// EXPLICIT_EH-SAME: "-mllvm" "-wasm-enable-eh"
// EXPLICIT_EH-NOT: "-wasm-enable-sjlj"

// Explicit TLS model wins; PIC leaves the global-dynamic default alone.
// RUN: %clang -### --target=wasm32-wasixv2 -ftls-model=global-dynamic -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=TLS_EXPLICIT %s
// TLS_EXPLICIT-NOT: "-ftls-model=local-exec"
// TLS_EXPLICIT: "-ftls-model=global-dynamic"
// RUN: %clang -### --target=wasm32-wasixv2 -fPIC -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=TLS_PIC %s
// TLS_PIC-NOT: "-ftls-model=local-exec"

// Threads cannot be disabled.
// RUN: not %clang -### --target=wasm32-wasixv2 -no-pthread -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=NO_PTHREAD %s
// NO_PTHREAD: error: unsupported option '-no-pthread' for target 'wasm32-unknown-wasixv2'

// Link defaults: wasm-ld (not wasm-component-ld), imported shared memory,
// 1MB stack, 4GiB max memory, host-required exports, -lpthread. Defaults
// come before user linker flags so explicit flags win (wasm-ld last-wins).
// RUN: %clang -### --target=wasm32-wasixv2 --sysroot=/foo %s 2>&1 \
// RUN:   | FileCheck -check-prefix=LINK_V2 %s
// LINK_V2: wasm-ld
// LINK_V2-NOT: wasm-component-ld
// LINK_V2-SAME: "--import-memory"
// LINK_V2-SAME: "-z" "stack-size=1048576"
// LINK_V2-SAME: "--max-memory=4294967296"
// LINK_V2-SAME: "--export-if-defined=__wasm_call_ctors"
// LINK_V2-SAME: "--export-if-defined=__tls_base"
// LINK_V2-SAME: "--export-if-defined=__stack_low"
// LINK_V2-SAME: "--export-if-defined=__stack_high"
// LINK_V2-SAME: "--export-if-defined=__stack_pointer"
// LINK_V2-SAME: "--export-if-defined=__data_end"
// LINK_V2-SAME: "--export-if-defined=__indirect_function_table"
// LINK_V2-SAME: "--export-if-defined=__wasm_init_tls"
// LINK_V2-SAME: "--export-if-defined=__tls_size"
// LINK_V2-SAME: "--export-if-defined=__tls_align"
// LINK_V2-SAME: "-mllvm" "-wasm-enable-eh"
// LINK_V2-SAME: "--shared-memory"
// LINK_V2-SAME: "-lpthread"

// User stack size appears after the default, so it wins in wasm-ld.
// RUN: %clang -### --target=wasm32-wasixv2 --sysroot=/foo -Wl,-z,stack-size=65536 %s 2>&1 \
// RUN:   | FileCheck -check-prefix=LINK_STACK %s
// LINK_STACK: "stack-size=1048576"
// LINK_STACK-SAME: "stack-size=65536"

// No wasm-opt by default on wasixv2, even at -O2 with wasm-opt on PATH.
// RUN: %clang -### --target=wasm32-wasixv2 --sysroot=/foo -O2 %s 2>&1 \
// RUN:   | FileCheck -check-prefix=NO_WASM_OPT %s
// NO_WASM_OPT-NOT: wasm-opt

// WASIX v1 gets none of the defaults: no thread features, no EH flags, no
// TLS model, plain linker command line.
// RUN: %clang -### --target=wasm32-wasix -c %s 2>&1 \
// RUN:   | FileCheck -check-prefix=CC1_V1 %s
// CC1_V1: "-cc1"
// CC1_V1-NOT: "-pthread"
// CC1_V1-NOT: "+atomics"
// CC1_V1-NOT: "-wasm-enable-eh"
// CC1_V1-NOT: "-exception-model=wasm"
// CC1_V1-NOT: "-ftls-model=local-exec"
// RUN: %clang -### --target=wasm32-wasix --sysroot=/foo %s 2>&1 \
// RUN:   | FileCheck -check-prefix=LINK_V1 %s
// LINK_V1: wasm-ld
// LINK_V1-NOT: "--import-memory"
// LINK_V1-NOT: "--max-memory=4294967296"
// LINK_V1-NOT: "--export-if-defined=
// LINK_V1-NOT: "--shared-memory"
