// RUN: fir-opt --target-rewrite="target=wasm32-unknown-wasi" %s | FileCheck %s

// CHECK-LABEL: func.func private @return_complex(
// CHECK-SAME: !fir.ref<tuple<f32, f32>> {llvm.sret = tuple<f32, f32>})
func.func private @return_complex() -> complex<f32>

// CHECK-LABEL: func.func private @take_complex(
// CHECK-SAME: !fir.ref<tuple<f64, f64>> {llvm.byval = tuple<f64, f64>})
func.func private @take_complex(complex<f64>)
