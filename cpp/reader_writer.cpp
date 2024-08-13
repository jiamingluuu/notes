#include <iostream>
#include <shared_mutex>
#include <thread>

class SharedData {
private:
    std::shared_mutex rw_mutex_;
    int data_;

public:
    void write(int value) {
        std::unique_lock<std::shared_mutex> writeLock(rw_mutex_);
        std::cout << "Writing " << value << std::endl;
        data_ = value;
        // Simulate write delay
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    int read() const {
        std::shared_lock<std::shared_mutex> readLock(rw_mutex_);
        std::cout << "Reading " << data_ << std::endl;
        // Simulate read delay
        std::this_thread::sleep_for(std::chrono::seconds(1));
        return data_;
    }
};

int main() {
    SharedData sharedData;

    std::thread writers[1];
    std::thread readers[3];

    writers[0] = std::thread([&](){ sharedData.write(42); });

    for (int i = 0; i < 3; ++i) {
        readers[i] = std::thread([&](){ sharedData.read(); });
    }

    for (int i = 0; i < 1; ++i) {
        writers[i].join();
    }
    for (int i = 0; i < 3; ++i) {
        readers[i].join();
    }

    return 0;
}

