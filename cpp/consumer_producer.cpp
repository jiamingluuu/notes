#include <thread>
#include <iostream>
#include <mutex>
#include <condition_variable>
#include <queue>

std::mutex mtx;
std::condition_variable cv;
std::queue<int> product;

void producer(int id) {
    for (int i = 0; i < 5; ++i) {
        std::unique_lock<std::mutex> lck(mtx);
        product.push(id * 100 + i);
        std::cout << "Producer " << id << " produced " << product.back() << std::endl;
        cv.notify_one();
        lck.unlock();
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
}

void consumer(int id) {
    for (int i = 0; i < 5; ++i) {
        std::unique_lock<std::mutex> lck(mtx);
        cv.wait(lck, []{ return !product.empty(); });
        int prod = product.front();
        product.pop();
        lck.unlock();
        std::cout << "Consumer " << id << " consumed " << prod << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
}

int main() {
    std::thread producers[2];
    std::thread consumers[2];

    for (int i = 0; i < 2; ++i) {
        producers[i] = std::thread(producer, i + 1);
        consumers[i] = std::thread(consumer, i + 1);
    }

    for (int i = 0; i < 2; ++i) {
        producers[i].join();
        consumers[i].join();
    }

    return 0;
}

