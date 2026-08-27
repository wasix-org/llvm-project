! RUN: %flang_fc1 -triple wasm32-unknown-wasi -emit-mlir %s -o - | FileCheck %s --check-prefix=WASI
! RUN: %flang_fc1 -triple wasm32-unknown-unknown -emit-mlir %s -o - | FileCheck %s --check-prefix=WASM

! WASI-LABEL: func.func @__main_argc_argv(%arg0: i32, %arg1: !llvm.ptr) -> i32 {
! WASI: %[[ENVP:.*]] = fir.zero_bits !llvm.ptr
! WASI: fir.call @_FortranAProgramStart(%arg0, %arg1, %[[ENVP]],

! WASM-LABEL: func.func @main(%arg0: i32, %arg1: !llvm.ptr, %arg2: !llvm.ptr) -> i32 {
! WASM: fir.call @_FortranAProgramStart(%arg0, %arg1, %arg2,

end program
