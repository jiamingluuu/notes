# Compiler Optimization
>> The followings are only suggestions. Optimization is hard to control, so 
experiments should be carried out to examine which method boost performance the 
best.
## AT&T typed assembly
suffix is used to indicates the bit of variable assignment
- `b` is used for byte, 8 bits
- `w` is used for word, 16 bits
- `l` is used for long, 32 bits
- `q`, 64 bits

function return value is stored in `eax` register
```s
# return 42
movl    $42, %eax
```

the calculation of linear function on x86 is fast, this is because we have 
```s
leal    (%rdi,%rsi,8), %eax
```
`leal` instruction stands for load effective address, the code above assigns
`eax = rdi + rsi * 8`. `leal` is particularly useful for array indexing.

```cpp
int func(int *a, std::size_t b) {
    return a[b];
    // movl     (%rdi,%rsi,4), %eax
}
```

## Float number as function parameters and return value
`xmm` registers are 128 bits wide, each can holds 4 floats or 2 doubles.
```cpp
float func(float a, float b) {
    return a + b;
    // addss    %xmm1, %xmm0
}
```
`addss` has tree parts
- `add`, addition
- first `s`, scalar, indicating only calculating the lowest bits. On the 
    contrary is `p`, packed, calculates all the bits of a xmm register.
- second `s`, single-precision floating number. On the contrary of `d` for 
    double.

The `addps` is an example of simd (single-instruction multiple-data) 
instruction. We assume it is four times faster than a single `addss`.

## What can compiler do for optimization?
### Algebraic calculation simplification
```cpp
int func() {
    int sum
    for (std::size_t i = 0; i < 100; i++) 
        sum += i;
    return sum
    // compiler will 
    // movl $5050, %eax
}
``` 
but this has limitation, the following will not be simplified
```cpp
int func() {
    std::vector<int> arr;
    for (std::size_t i = 0; i < 100; i++)
        arr.push_back(i);
    return std::reduce(arr.begin(), arr.end());
}
```

Normally, containers that are stored on heap will not be optimized, for instance
in std namespace: 
- vector, map, set, function, any, 
- unique_ptr, shared_ptr, weak_ptr

But for those who stored on stack, they will be optimized
- array, bitset, glm::vec, string_view
- pair, tuple, optional, variant

To enforce the optimization, we can use `constexpr`.

### inline
Functions can be classified as 
- External, those only contains a declaration in the current file, and 
    implementation in other file. Compiler will generate a `@PLT` suffix.
- Internal, those implementation is in the same file.

### Write to memory
For instance
```cpp
void func(int *a) {
    a[0] = 123;
    a[1] = 456
}
```
The compiler will do the following
```s
movq    .LC(%rip), %rax
movq    %rax, (%rdi)
```
But if the assignment memory is not adjacent, we
```cpp
void func(int *a) {
    a[0] = 123;
    a[2] = 456
}
```

*Remark*
When designing a data structures, data structure should be compact (data are 
close to each other), aligned with 16 bytes or 32 bytes, when designing a data 
structure. So compiler is easy to perform optimization by using simd 
instructions.

### For loop
*Hot* codes are those assessed frequently, on the contrary of *cold*.

`__restrict` keyword indicates two pointers does not points to an overlapped
memory region.
```cpp
void func(float *__restrict a, float *__restrict b) {
    for (int i = 0; i < 1024; i++) 
        a[i] += b[i];
}
```
Other possible versions:
```cpp
// compiled with `gcc -fopenmp -O3`
void func(float *a, float *b) {
#pragma omp simd 
    for (int i = 0; i < 1024; i++)
        a[i] = b[i] + 1;
}

// or does not use omp
void func(float *a, float *b) {
#pragma GCC ivdep   // ignore dependency
    for (int i = 0; i < 1024; i++)
        a[i] = b[i] + 1;
}
```

Prevent embedding an external function in a for loop, which fails optimization.

We can also expand for loop
```cpp
void func(float *a) {
#pragma GCC unroll 4
    for (int i = 0; i < 1024; i++)
        a[i] = 1:
}

// optimized after
void func(float *a) {
    for (int i = 0; i < 1024; i = i + 4) {
        a[i + 0] = 1;
        a[i + 1] = 1;
        a[i + 2] = 1;
        a[i + 3] = 1;
    }
}
```

### struct
Make the size of structs be a power of 2, it is easy for vectorized 
optimization.

An AOS (array of struct) example:
```cpp
struct X {
    float x;
    float y;
    float z;
    char pad[4];
};

// or equivalently
struct alignas(16) X {
    float x;
    float y;
    float z;
};

X x[1024]:

void func() {
    for (int i = 0; i < 1024; i++)
        a[i].x *= a[i].y;
}
```

But SOA (struct of array) is better
```cpp
struct X {
    float x[1024];
    float y[1024];
    float z[1024];
};

void func() {
    for (int i = 0; i < 1024; i++) 
        a.x[i] *= a.y[i];
}
```
Sometime, SOA on a single core has better performance than AOS on multi-core.

### STL containers
STL container often fails optimization, but we still can do something.
```cpp
// we cannot put __restrict here because this only tells compiler the pointer 
// for each vector is not overlapped, but not the data in the vector.
void func(std::vector<int> &a, std::vector<int> &b) {
    for (int i = 0; i < 1024; i++)
#pragma omp simd
        a[i] = b[i] + 1;
}

// or
void func(std::vector<int> &a, std::vector<int> &b) {
    for (int i = 0; i < 1024; i++)
#pragma GCC ivdep
        a[i] = b[i] + 1;
}
```

We can also perform SOA optimization on vector
```cpp
struct X {
    std::vector<float> x;
    std::vector<float> y;
    std::vector<float> z;
};
```
but we need to make sure once one of the vector is pushed with element, all the
other vectors should also be pushed.

### Numerical methods
```cpp
float func(float a) {
    return a / 2;
}

// because mult is faster than div, so it will be optimized to 
float func(int a) {
    return a * 0.5f;
}
```

```cpp
// the following fails to optimize, because b can potentially equal to 0
float func(float *a, float b) {
    for (int i = 0; i < 1024; i++)
        a[i] /= b;
}

// solution:
float func(float *a, float b) {
    float inv_b = 1 / b;
    for (int i = 0; i < 1024; i++)
        a[i] *= inv_b;
}
```

Always use the math function from std library, because
- `sqrt` only accepts double inputs, so slow .
- `sqrtf` is used for float, so faster than above.
- `std::sqrt` overloads float and double.
- `abs` only accepts int inputs.
- `fabs` an `dabs` only accepts float and double.
- `std::abs` has overload on both int, float and double.

`-ffast-math` compiling flag is used to let compiler do more optimization on 
numerical computations, ignore handling errors like dividing by zero and 
taking square root of a negative.

## Others
Use `-O3` in CMake
```
set(CMAKE_BUILD_TYPE Release)
```

Use `-fopenmp`
```
find_package(OpenMP REQUIRED)
target_link_libraries(testbench PUBLIC OpenMP::OpenMP_CXX)
```

`-ffast-math` and `--march=native`
```
target_compile_options(testbench PUBLIC -ffast-math --march=native)
```
