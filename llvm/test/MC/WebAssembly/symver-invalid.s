# RUN: split-file %s %t
# RUN: not llvm-mc -triple=wasm32 -filetype=obj %t/undefined.s -o /dev/null 2>&1 | FileCheck %s --check-prefix=UNDEFINED
# RUN: not llvm-mc -triple=wasm32 -filetype=obj %t/version.s -o /dev/null 2>&1 | FileCheck %s --check-prefix=VERSION
# RUN: not llvm-mc -triple=wasm32 -filetype=obj %t/remove.s -o /dev/null 2>&1 | FileCheck %s --check-prefix=REMOVE
# RUN: not llvm-mc -triple=wasm32 -filetype=obj %t/duplicate.s -o /dev/null 2>&1 | FileCheck %s --check-prefix=DUPLICATE

#--- undefined.s
.symver missing, api@@V1
# UNDEFINED: WebAssembly .symver requires a defined symbol

#--- version.s
.symver source, api@
# VERSION: expected symbol@version or symbol@@version

#--- remove.s
.symver source, api@V1, remove
# REMOVE: expected newline

#--- duplicate.s
.symver first, api@@V1
.symver second, api@@V2
.section .data,"",@
.globl first
first:
.int32 1
.size first, 4
.globl second
second:
.int32 2
.size second, 4
# DUPLICATE: symbol version alias is already defined
