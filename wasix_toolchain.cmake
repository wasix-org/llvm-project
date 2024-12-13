set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR wasm32)

set(CMAKE_SYSROOT $ENV{HOME}/wasix/sysroot32)
set(triple wasm32-wasi)

set(CMAKE_C_COMPILER clang-16)
set(CMAKE_CXX_COMPILER clang++-16)
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER_TARGET ${triple})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

SET(CMAKE_C_FLAGS 
   "-matomics -mbulk-memory -mmutable-globals -pthread -mthread-model posix -ftls-model=local-exec -fno-trapping-math -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS "
   CACHE STRING "" FORCE)

SET(CMAKE_CXX_FLAGS
   "-matomics -mbulk-memory -mmutable-globals -pthread -mthread-model posix -ftls-model=local-exec -fno-trapping-math -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS "
   CACHE STRING "" FORCE)

SET(CMAKE_EXE_LINKER_FLAGS 
   "-Wl,--shared-memory -Wl,--max-memory=4294967296 -Wl,--import-memory -Wl,--export-dynamic -Wl,--export=__stack_pointer -Wl,--export=__heap_base -Wl,--export=__data_end -Wl,--export=__wasm_init_tls -Wl,--export=__wasm_signal -Wl,--export=__tls_size -Wl,--export=__tls_align -Wl,--export=__tls_base -lwasi-emulated-mman -lwasi-emulated-process-clocks" 
   CACHE STRING "" FORCE)
