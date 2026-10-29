# RUN: llvm-mc -triple=wasm32 -filetype=obj %s -o %t.o
# RUN: llvm-readobj --symbols %t.o | FileCheck %s
# RUN: wasm-ld --no-entry --export=api --export=data %t.o -o %t.wasm

# Forward definitions and multiple versions must retain their types and indices.
.symver old, api@V1
.symver current, api@@V2
.symver object, data@@V2

.section .text.old,"",@
.globl old
old:
.functype old () -> (i32)
i32.const 1
end_function

.section .text.current,"",@
.globl current
current:
.functype current () -> (i32)
i32.const 2
end_function

.section .data.object,"",@
.globl object
object:
.int32 42
.size object, 4

# CHECK: Name: api@V1
# CHECK-NEXT: Type: FUNCTION
# CHECK: ElementIndex: 0x0
# CHECK: Name: api@V2
# CHECK-NEXT: Type: FUNCTION
# CHECK: ElementIndex: 0x1
# CHECK: Name: api{{$}}
# CHECK-NEXT: Type: FUNCTION
# CHECK: ElementIndex: 0x1
# CHECK: Name: data@V2
# CHECK-NEXT: Type: DATA
# CHECK: Size: 0x4
# CHECK: Name: data{{$}}
# CHECK-NEXT: Type: DATA
# CHECK: Size: 0x4
