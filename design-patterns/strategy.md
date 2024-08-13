# Intro
## Background 
Suppose we want to find the sum and product of all the elements within an
array. Normally, we need write two functions that are quite similar to each
other. Apparently, both of the operation follows some pattern: 
- firstly initialize an accumulator,
- then iterates through the whole array and accumulates.

## Strategy Design Patter
In strategy design pattern, we declares an interface to support all versions
of some algorithm.
```cpp
struct Reducer {
  virtual int init() = 0;
  virtual int add(int a, int b) = 0;
};

int reduce(std::vector<int> v, Reducer *reduce) {
  int res = reduce->init();
  for (size_t i = 0; i < v.size(); i++) {
    res = reduce->add(res, v[i]);
  }
  return res;
}
```

And client can defines the algorithm according to their needs.
```cpp
struct SumReducer : Reducer {
  int init() override {
    return 0;
  }

  int add(int a, int b) override {
    return a + b;
  }
};

struct Produce : Reducer {
  int init() override {
    return 1;
  }

  int add(int a, int b) override {
    return a * b;
  }
};
```

More example
```cpp
struct Max : Reducer {
  int init() override {
    return std::numeric_limits<int>::min();
  }

  int add(int a, int b) override {
    return std::min(a, b);
  }
};

struct Min : Reducer {
  int init() override {
    return std::numeric_limits<int>::max();
  }

  int add(int a, int b) override {
    return std::max(a, b);
  }
};
```

## Multiple Strategy
But what if we want to perform the reduction on multiple data types, for
instance, from both `cin` and `vector`? Then we can use multiple abstraction.
```cpp
struct Inputer {
  virtual std::optional<int> fetch() = 0;
};
```

So if we want to read from `cin` and `vector`, we can implements the inputer for 
each of them:
```cpp
struct CinInputer : Inputer {
  std::optional<int> fetch() {
    int tmp;
    std::cin >> tmp;
    if (tmp == -1) 
      return std::nullopt;
    return tmp;
  }
};

struct VectorInputer : Inputer {
  std::vector<int> v;
  int pos = 0;

  VectorInputer(std::vector<int> v) : v(v) {}

  std::optional<int> fetch override {
    if (pos == v.size())
      return std::nullopt;
    return v[pos++];
  }
}
```
This is actually an iterator pattern, which helps us iterates through a data 
structure of interest.

And reduce at the end:
```cpp
int reduce(Inputer *inputer, Reducer *reducer) {
  int res = reducer->init();
  while (int tmp = inputer->fetch()) {
    res = reducer->add(res, tmp);
  }
  return res;
}
```
