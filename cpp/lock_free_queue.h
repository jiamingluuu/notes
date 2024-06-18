#include <atomic>
#include <filesystem>
#include <future>
#include <memory>

template<typename T>
struct Node {
  std::shared_ptr<T> data_;
  std::atomic<Node<T> *> next_;

  Node(T value) : data_(std::make_shared<T>(value)), next_(nullptr) {}
};

template<typename T> 
class LockFreeQueue {
public:
  LockFreeQueue() : head_(new Node<T>(T())), tail_(head_.load()) {}
  ~LockFreeQueue() {
    while (head_.load() != tail_.load()) {
      Node<T> * oldHead = head_.load();
      head_.store(oldHead->next_.load());
      delete oldHead;
    }
    delete tail_.load();
  }

  void Enqueue(T value) {
    Node<T> *newNode = new Node<T>(value);
    newNode->next_.store(nullptr);
    while (true) {
      Node<T> *oldTail = tail_.load();
      Node<T> *next = oldTail->next_.load();

      if (oldTail == tail_.load()) {
        if (next == nullptr) {
          if (oldTail->next_.compare_exchange_strong(next, newNode)) {
            tail_.compare_exchange_strong(oldTail, newNode);
            return;
          }
        } else {
          tail_.compare_exchange_strong(oldTail, newNode);
        }
      }
    }
  }

  std::shared_ptr<T> Dequeue() {
    while (true) {
      Node<T> *oldHead = head_.load();
      Node<T> *oldTail = tail_.load();
      Node<T> *next = oldHead->next_.load();

      if (oldHead == head_.load()) {
        if (oldHead == oldTail) {
          if (next == nullptr) {
            return std::shared_ptr<T>();
          }
          tail_.compare_exchange_strong(oldHead, next);
        } else {
          if (head_.compare_exchange_strong(oldHead, next)) {
            return oldHead->data_;
          }
        }
      }
    }
    return nullptr;
  }

private:
  std::atomic<Node<T> *> head_;
  std::atomic<Node<T> *> tail_;
};
