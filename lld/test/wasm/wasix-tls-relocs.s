# WASIX fork test: verifies the TLS-relocation behaviors WASIX's dynamic
# linker depends on:
#  1. `__wasm_apply_tls_relocs` is exported, so a dynamic linker that creates
#     a fresh TLS area for a new instance/thread can re-apply TLS relocations.
#  2. `__wasm_init_memory` calls `__wasm_apply_global_tls_relocs` right after
#     initializing the TLS segment (and setting `__tls_base`), so TLS GOT
#     globals are valid for the main thread without a separate
#     `__wasm_init_tls` call.

# RUN: llvm-mc -filetype=obj -triple=wasm32-unknown-unknown -o %t.o %s
# RUN: wasm-ld --experimental-pic -pie -no-gc-sections --shared-memory --no-entry -o %t.wasm %t.o
# RUN: obj2yaml %t.wasm | FileCheck %s
# RUN: llvm-objdump -d --no-show-raw-insn --no-leading-addr %t.wasm | FileCheck --check-prefix=DIS %s

.globl _start
_start:
  .functype _start () -> (i32)
  global.get tls_sym@GOT@TLS
  end_function

.section data,"",@
data_sym:
  .int32 42
  .size data_sym, 4

# TLS section with relocations, so that __wasm_apply_tls_relocs is generated.
.section tls_sec,"T",@
.globl  tls_sym
.p2align  2
tls_sym:
  .int32 0x51
  .int32 data_sym
  .int32 tls_sym
  .size tls_sym, 4

.section  .custom_section.target_features,"",@
  .int8 2
  .int8 43
  .int8 7
  .ascii  "atomics"
  .int8 43
  .int8 11
  .ascii  "bulk-memory"

# __wasm_apply_tls_relocs must be exported (not hidden, as upstream has it).
# CHECK:       - Type:            EXPORT
# CHECK-NEXT:    Exports:
# CHECK-NEXT:      - Name:            memory
# CHECK-NEXT:        Kind:            MEMORY
# CHECK-NEXT:        Index:           0
# CHECK-NEXT:      - Name:            __wasm_apply_tls_relocs
# CHECK-NEXT:        Kind:            FUNCTION

# Establish the function index of __wasm_apply_global_tls_relocs used below.
# CHECK:         FunctionNames:
# CHECK-NEXT:      - Index:           0
# CHECK-NEXT:        Name:            __wasm_call_ctors
# CHECK-NEXT:      - Index:           1
# CHECK-NEXT:        Name:            __wasm_init_tls
# CHECK-NEXT:      - Index:           2
# CHECK-NEXT:        Name:            __wasm_init_memory
# CHECK-NEXT:      - Index:           3
# CHECK-NEXT:        Name:            __wasm_apply_global_tls_relocs

# After winning the init race, __wasm_init_memory initializes the TLS segment,
# sets __tls_base, and must then call __wasm_apply_global_tls_relocs (func 3).
# DIS:      <__wasm_init_memory>:
# DIS:        global.set 3
# DIS-NEXT:   local.get 1
# DIS-NEXT:   i32.const 0
# DIS-NEXT:   i32.const 12
# DIS-NEXT:   memory.init 0, 0
# DIS-NEXT:   call 3
