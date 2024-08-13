# Multi-threading in Modern C++
## `std::chrono`
To use the library
```cpp
#include <chrono>
```

Calculate the execution time
```cpp
auto t0 = std::chrono::steady_clock::now();
for (volatile int i = 0; i < 100000000; i++);
auto t1 = std::chrono::steady_clock::now();
auto dt = t1 - t0;
auto ms = std:;chrono::duration_cast<std::chrono::milliseconds>(dt).count();
```

Sleep
```cpp
std::this_thread::sleep_for(std::chrono::milliseconds(400));
```

## Thread
In C++11, we can use `std::thread` library, which is implemented based on `pthread.h`, to perform multi-threading.

To enable `std::thread`, we can use CMake
```
find_package(Threads REQUIRED)
target_link_libraries(cpptest PUBLIC Threads::Threads)
```

### Thread APIs
```cpp
std::thread t1([&] {
  download("hello.zip");
});

interact();

t1.join();
```

However, when we declare a thread with in a function, we should be careful
```cpp
void func() {
  std::thread t1([&] {
    download("hello.zip");
  })

  t1.detach()
}
```
Because thread objects has destructor, so when function returns but the thread is not terminated, the thread handle is destroyed. We can use `detach()` to prevent this behaviour.

Or instead, we can also do the following:
```cpp
class ThreadPool {
  std::vector<std::thread> pool;

public: 
  void push_back(std::thread t) {
    pool.push_back(std:;move(t));
  }

  ~ThreadPool {
    for (auto &t: pool) t.join();
  }
}

ThreadPool tpool;

void func() {
  std::thread t([&] {
    download("hello.zip");
  })

  tpool.push_back(std::move(t));
}

int main() {
  func();

  return 0; // call join() inside the destructor when main function exit
}
```

## Asynchronous Programming
`std::async` receives a lambda expression and returns `std::future` object. 
- A thread is created to execute the lambda expression, the `future` object can be seen as the handle for the thread.
- When `get()` is invoked on the `future`, we wait until the thread returns.
```cpp 
#include <future>
#include <thread>

int main() {
  std::future<int> fret = std::async([&] {
    return download("hello.zip");
  });

  int ret = fret.get();
  std::cout << ret << '\n';
}
```

We can also use `wait()` for wait until the function terminates. 
```cpp
std::future<int> fret = std::async([&] {
  return download("hello.zip");
});
// do something
std::cout << "waiting for download...\n";
fret.wait();
std::cout << "wait returned\n";
int ret = fret.get();
std::cout << "received:" << ret << "\n";
```

Or use the function `wait_for()` to specifies the time for waiting.
```cpp
auto stat = fret.wait_for(std::chrono::milliseconds(1000));
if (stat == std::future_status::ready) {
  std::cout << "future is ready\n":
} else {
    std::cout << "future is not ready\n";
}
```

### `std::launch::deferred`
When we specifies the `std::launch::deferred` parameter when constructing thread instance, thread is not spawned during instantiation. Instead, thread execution only begins when `get()` is invoked.
```cpp
std::future<int> fret = std::async(std::launch::deferred, [&] {
  return download("hello.zip");
})
```

### `promise`
`promise` is used for fetching the return value of a thread object.
```cpp
std::promise<int> pret;
std::thread t1([&] {
  auto ret = download("hello.zip");
  pret.set_value(ret);
})
std::future<int> fret = pret.get_future();

// do something
int ret = fret.get();
```

*Remark*
- `future` and `promise` can have type `void`.
- `future` and `promise` have deleted the copy assignment and copy constructor function. In order to borrow the object , wrap it with `std::shared_future<void>`.

## Mutual Exclusion
### Mutex
A mutex can be used to prevent race condition while modifying data structure concurrently.
```cpp
std::vector<int> v;
std::mutex m;

std::thread t1([&] {
  for (int i = 0; i < 100; i++) {
    m.lock();
    v.push_back(i);
    m.unlock()
  }
})

std::thread t2([&] {
  for (int i = 0; i < 100; i++) {
    m.lock();
    v.push_back(i);
    m.unlock();
  }
})
```

We can also use `std::lock_guard`, which call `lock()` during the constructor function and call `unlock()` during destructor function. 
```cpp
std::mutex m;
std::thread t1([&] {
  for (int i = 0; i < 100; i++) {
    std::lock_guard grd(m);
    v.push_back(i);
  }
})

std::thread t2([&] {
  for (int i = 0; i < 100; i++) {
    std::lock_guard grd(m);
    v.push_back(i);
  }
})
```

However, `lock_guard` can not release the lock in advance, so we can also use `std::unique_lock` for having a higher flexibility.
```cpp
std::mutex m;

std::thread t([&] {
  for (int i = 0; i < 100; i++) {
    std::unique_lock grd(m);
    v.push_back(i);

    grd.unlock();
    do_something();
    grd.lock();
  }
})
```

`grd()` acquire the lock by default, but we can use `grd(m, std::defer_lock)` to prevent acquiring lock when the guard is initialized.

We can also use `try_lock()` to acquire the lock in a non-blocking pattern, there this function either:
- returns true and acquire the lock, or 
- returns false and does not block the current thread.

Between `lock()` and `try_lock()`, we have `try_lock_for(t)` which wait for acquiring the lock for `t` timestamps, the unit is determined by using `chrono`.





