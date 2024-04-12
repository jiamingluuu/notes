# RAII and Smart Pointers 
## Vector
```cpp
#include <ranges>    // C++ 20
#include <numeric>
#include <vector>
#include <algorithm>
int main() {
    int sum = 0;
    std::vector<int> v = {1, 2, 3, 4};
    // usage of iterator
    for (int vi : v) {
        sum += vi;
    }

    // a lambda function, `&` indicates capture the variable from outside
    std::for_each(v.begin(), v.end(), [&] (auto vi) {
        sum += vi;
    });

    // we can ignore the <int> in C++11
    std::vector v = {4, 3, 2, 1, 0, -1, -2};

    // in C++ 20
    for (auto &&vi : v
         | std::views::filter([] (auto &&x)) { return x >= 0; }
         | std::views::transform([] (auto &&x)) { return sqrtf(x); }
         ) {
        std::cout << vi << std::endl;
    }
}
```

## RAII (Resource Acquisition Is Initialization)
- Just constructor and destructor.

The destructor is invoked whenever exception is caught
```cpp
#include <fstream>
#include <iostream>
#include <stdexcept>

void test() {
    std::ofstream fout("a.txt");
    fout << "foo\n";
    throw std::runtime_error("error");      // file closed when exit.
    fout << "something\n";
}

int main() {
    try {
        test();
    } catch (std::exception const &e) {
        std::cout << "catch exception: " << e.what() << std::endl;
    }
    
    return 0;
}
```

The `explicit` keyword

`explicit` can be used for annotate cpp class constructor to forbid implicit 
invocation of construction. For instance

```cpp
struct Pig {
    std::string name;
    int weight;
    // if there were no constructor, compiler will generates an empty 
    // constructor automatically. but the initialized value will be random.
    
    Pig() = default;    // use the default constructor
    Pig() = delete;     // delete the constructor, error is thrown if used.

    // the followings will be provided by the compiler if not defined by user
    // Pig(Pig const *other)...
    // Pig &operator=(Pig const &other)... 
    // Pig(Pig &&other)...
    // Pig &operator=(Pig &&other)...
    // ~Pig()

    explicit Pig(std::string name, int weight) 
        : name(name)
        , weight(weight)
    {}
};

int main() {
    Pig pig1 = {"piggy", 80};   // error
    Pig pig2("piggy", 80);      // ok
    Pig pig3{"piggy", 80};      // ok
}
```

Difference between using `()` and `{}` for initialization
- `()` is a force type casting, whereas `{}` is not.
- seldom should we use `()` for constructor invocation

*Remark*
- We should never use the default constructor in practice, delete it manually.

And also, the followings are recommended:
1. if destructor is defined, copy constructor and copy assignment function 
    should be defined
2. if copy constructor is defined, define or delete copy assignment function
3. if move constructor is defined, define or delete move assignment function
4. if copy constructor or copy assignment is defined, define copy constructor or 
    move assignment 

## Deep copy, shallow copy, and move
- shallow copy is just a reference 
- deep copy is copy all the value from one to another
- move is copy all the value from one to another, and empty the original data,
    it is just a change of pointer, so has O(1) time complexity.

*Remark* 
In the following cases, move is used
- `return x`
- `x = std::vector<int>(200)`
- `x = std::move(y)`

In the following cases, deep copy is used
- `return std::as_const(v2)`
- `v1 = v2`

  The followings does nothing
  - `std::move(v2)`
  - `std::as_const(v2)`

## Smart Pointers
### unique_prt
  a smart pointer that encapsulates class instance, and deletes the copy function. 

  But what if we want to use or manipulates the pointer? The answer is 
  - use `p.get()` for a mutable reference. This returns the naive pointer to the 
      object p, that is `*p`.
  - or simply use `std::move(p)` to move the ownership to the caller 
      function/object. But if we still want to access the variable at the original 
      place, we can do the followings:
```cpp
std::vector<std::shared_ptr<C>> objlist;

void func(std::shared_ptr<C> p) {
    objlist.push_back(std::move(p))
}

int main() {
    std::unique_ptr<C> p = std::make_unique<C>();
    C *raw_p = p.get();

    func(std::move(p));         // move the ownership to func() 

    raw_p->do_something();      // ok, since raw_p still hows the address of p

    objlist.clear();            // (a)

    raw_p->do_something();      // error, since the mem is cleared by (a)
    
    return 0;
}
```

### shared_ptr
With all the functionality of `unique_ptr`, add an atomic counter (that is 
initialized with value 1) to counts owner. Free the encapsulated instance when 
the counter is 0.

*Remark*
- `shared_ptr` is less efficient than the primitive pointer and `unique_ptr`.
    Because we need hardware instructions to support the increment and decrement
    of the counter.
- cyclic reference would cause the pointer cannot be freed
```cpp
struct C {
    std::shared_ptr<C> child;
    std::shared_ptr<C> parent;
}

// the solution is to change one of CHILD or PARENT to a week_ptr
struct D {
    std::shared_ptr<C> child;
    std::weak_ptr<C> parent;    // modifying week_ptr instance does not change 
                                // the cnt for object's shared_ptr
}


int main() {
    auto parent = std::make_shared<C>();    // cnt == 1
    auto child = std::make_shared<C>();     // cnt == 1
    
    parent->child = child;                  // cnt == 2
    child->parent = parent;                 // cnt == 2

    parent = nullptr;                       // cnt == 1
    child = nullptr                         // cnt == 1
    // both CHILD and PARENT are not freed because struct C's attributes still 
    // holds a reference of them.
}
```

*Remark*
To conclude, we recommend use smart pointers in the followings way:
- `unique_ptr`: when the object O is *only* owned by user U
- primitive pointer: when object O is owned by other user S, but O is guaranteed 
    to be freed before S is freed.
- `shared_ptr`: when multiple users are sharing the ownership of object O
- `weak_ptr`: when user U does not have the ownership of object O, and 
    U is not freed after O is freed.

In practice, we often use `shared_ptr` and `weak_ptr` in pair, `unique_ptr` and 
primitive pointer in pair.
