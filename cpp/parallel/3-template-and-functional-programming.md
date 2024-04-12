# Template and functional programming

## Template
Template is used to prevent redundant code.

```cpp
#include <iostream>
#include <string>

template <typename T>    // use `typename T = int` to set the default type
T twice(T t) {
    return t * 2;
}

// int can also used as a template parameter 
template <int N>
void show_times(std::string msg) {
    for (int i = 0; i < N; i++) {
        std::cout << msg << std::endl;
    }
}

// we can hybrid the usage of overload and template
std::string twice(std::string s) {
    return t + t;
}

int main() {
    std::cout << twice<int>(21) << std::endl;

    // compiler can derive the template type automatically
    std::cout << twice(3.14f) << std::endl;

    std::cout << twice("hello") << std::endl;
    return 0;
}
```

*Remark:*
- When using `template <int N>`, `N` is a constant at compile-time. Compiler
    therefore can generates a snippets of code for each N, can perform
    optimization individually.
- Whereas then passing N as a parameter into the function, for instance:
    `func(int N)`, compiler cannot optimize.
- Be careful with template, abusing the use of template lags the compiling
    time.
- It is not recommended to separate the definition and implementation of
    template.

Template is lazy evaluated. Sometimes a pseudo-template is used to reduce
compiling time.
```cpp
template <typename T = void>
void foo() {
    "bar" = 123;    // ok, because template is not invoked
}

int main() {
    return 0;
}
```

### rvalue and lvalue
In non-rigorous speaking
- lvalue is an object that has an identifiable location in memory.
- rvalue is data value is normally an expression.

### `const` keywords
`const` annotates a read-only variable.
- `int const *` declares a pointer to a constant integer. We can change the 
    integer that the pointer pointing to, but cannot change the integer value.
- `int * const` declares a constant pointer to an integer. We can change the 
    integer value, but not the pointer value.

### Type decay, declare, and etc
`std::decay_t` function can be used to decay the reference type of a variable. 
For instance, `std::decay_t<int &>` has the same type with `int`. It basically 
unwrap a variable type from reference and `const` keywords.

`decltype` function can be used to derive the return type of an expression.
- This function often used together with `auto` to derive the un-decayed type 
    of a function return type.
```cpp
decltype(auto) foo() {
    int &x = 1;
    return x;
} // type: int &

auto bar() {
    int &x = 1;
    return x
} // type: int
```

`using` keyword is used to alias type name.
```cpp
using func_t = int(*)(int);
```

When we only know that return type:
```cpp
template <typename T1, typename T2>
auto add(std::vector<T1> const &a, std::vector<T2> const &b) {
    using T0 = decltype(T1{} + T2{});
    std::vector<T0> ret;
    for (size_t i = 0; i < std::min(a.size(), b.size()); i++) {
        ret.push_back(a[i] + b[i]);
    }
    return ret;
}
```

## Functional programming
Functions can also passed as parameter
```cpp
#include <iostream>

void print_int(int n) {
    printf("number: %d\n", n);
}

void print_float(float f) {
    printf("number: %f\n", n);
}

template <typename Func>
void call_twice(Func func) {
    func(0);
    func(1);
}

int main() {
    call_twice(print_int);      // template type is derived automatically.
    call_twice(print_float);

    return 0;
}
```

### Lambda expression
*Lambda expression* is an anonymous function.
```cpp
auto twice = [] (int n) -> int {
    return n + n;
};
```

The return type can be implicitly derived
```cpp
auto twice = [] (int n) {
    return n + n;
};
```

Lambda expression can capture the variable at the same scope when function is 
defined, this feature is called *closure*.
```cpp
int fac = 2;
int counter = 0;
auto twice = [&] (int n) {  // `&` is a mutable reference
    counter++;
    return n * fac;
};
```
Notice that we often pass a lambda expression as a const reference to another 
function. This is because as more variables are captured, the size of the 
lambda expression increases. For instance, the `twice` expression above is 
16 bytes sized, because two pointers (`fac` and `counter`) are captured.

The abuse of lambda expression causes dangling pointer
```cpp
auto make_twice(int fac) {
    return [&] (int n) {
        return n * fac;
    };
}

int main() {
    auto twice = make_twice(2);
    call_twice(twice);              // Error, when make_twice() returns, fac
                                    // is deallocated, a dangling pointer.
    return 0;
}
```
We should ensure the lifetime of lambda expression instance is shorter than 
the variable captured.

And to solve this issue, we can use the following to pass by value:
```cpp
auto make_twice(int fac) {
    return [=] (int n) {
        return n * fac;
    };
};
```

### Preventing abuse of template for lambda expression
Because we do not know the type of a lambda expression, so template is often 
used together with lambda expression. But sometimes, we may want to separate 
the function declaration and implementation, or want to reduce the compiling 
time. In this case, `std::function` or `std::any` can be used to turn the 
expression into a virtual function.
```cpp
void call_twice(std::function<int(int)> const &func) {
    ...
}
```

### Use `auto` together with lambda expression
The followings are equivalent. Lambda expression with `auto`-typed parameter is 
also lazy evaluated.
```cpp
auto twice = [] (auto n) {
    return n * 2;
};

template <typename T>
auto twice = [] (T n) {
    return n * 2;
};
```

### More examples
This pattern is often used in asynchronized programs.
```cpp
#include <iostream>
#include <vector>

template <typename Func>
void fetch_data(Func const &func) {
    for (int i = 0; i < 32; i++) {
        func(i);
        func(i + 0.5f);
    }
}

int main() {
    std::vector<int> res_i;
    std::vector<float> res_f;
    fetch_data([&] (auto const &x) {
        using T = std::decay_t<decltype(x)>;
        if constexpr (std::is_same_v<T, int>) {
            res_i.push_back(x);
        } else if constexpr (std::is_same_v<T, float>) {
            res_f.push_bac(x);
        }
    });

    return 0;
}
```

Lambda expression can also be used to find values immediately.
```cpp
std::vector<int> arr = {1, 3, 2, 7, 8, 5};
int tofind = 5;
int index = [&] {
    for (int i = 0; i < arr.size(); i++) {
        if (arr[i] == tofind) 
            return i;
    }
    return -1;
}();
```

Lambda expression can be used to perform recurrence 
```cpp
std::vector<int> arr = {1, 4, 2, 8, 5, 7, 1, 4};
std::set<int> visited;
auto dfs = [&] (auto const &dfs, int index) -> void {
    if (visited.find(index) == visited.end()) {
        visited.insert(index);
        std::cout << index << std::endl;
        int next = arr[index];
        dfs(dfs, next);
    }
}
dfs(dfs 0);
```

## Some common containers
### Tuple
```cpp
#include <tuple
auto tup = std::tuple<int, float, char>(3, 3.14f, 'g');
auto tup_ = std::tuple(3, 3.14f, 'g');  // type can be implicitly derived.

// to fetch data
auto first = tup.get(0);
auto [first, second, third] = tup;

// can also binds to reference
auto &[first, second, third] = tup;
```








