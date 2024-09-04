# CMake
A software that can be used to automatically generates `Makefile` for compiling `c` family programs.

the following defines the dependency for compiling the exe file

```cpp
add_executable(a.out main.cpp hello.cpp)
```

`-D` prefix is used for defining variables, for instance
- `-DCMAKE_CXX_COMPILER=`

Suppose we were given

```
.
|
+---- hellolib ---- hello.cpp
|       |
|       +----- hello.h
|       |
|       +----- CMakeLists.txt
|
+----- main.cpp
|
+----- CMakeLists.txt
```

But in `main.cpp` we have

```cpp
#include "hello.h"
```

Sometime it is tedious and problematic to change the include headers definition, so we can use
```cpp
target_link_libraries(a.out PUBLIC hellolib)
target_link_directories(a.out PUBLIC hellolib)
```
Or in `hellolib/CMakeLists.txt` we can add the followings
```cpp
target_include_directories(hellolib PUBLIC .)
```
The `PUBLIC` keywords let the exe file consider the files under the sub-dir `hellolib` automatically.

## Library 
- *Static library* is a set of external functions and variables which are resolved in a caller at compiler time and copied into a target application by a compiler, linked oor binder. Just like a group of object files.
    - The linked file must exists in the system dir or the current dir of exe when running the exe file.
- *Dynamic library*, generates a PLT(procedure linkage table) in the exe file that jumps to a implementation of routine in a external file. It saves the space for the exe.

We can use the `add_library` function in the customized `CMakeLists.txt` file. For example
```cmake
add_library(hellolib STATIC hello.cpp)  // A static library for hello.cpp
add_library(hellolib SHARED hello.cpp)  // A dynamic library for hello.cpp
```

## Header Files

``` cpp
// The following can only be applied to cpp compilers like g++ and clang++
#pragma once // is equivalent to

#ifndef HEADER
#define HEADER
// ... some code
#endif 
```

*Remark*: putting implementation in a `.h` file is ok, but it lag the compilation time.
