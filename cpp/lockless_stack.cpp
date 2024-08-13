#include <atomic>
#include <iostream>

class AtomicStack {
private:
    struct Node {
        int data;
        std::atomic<Node*> next;
    };

    alignas(64) std::atomic<Node*> head_{nullptr};

public:
    void push(int data) {
        Node* node = new Node{data, nullptr};
        while (true) {
            Node* oldHead = head_.load(std::memory_order_relaxed);
            node->next = oldHead;
            if (head_.compare_exchange_weak(oldHead, node,
                                            std::memory_order_release,
                                            std::memory_order_relaxed)) {
                break;
            }
        }
    }

    bool pop(int& data) {
        Node* oldHead = head_.exchange(nullptr, std::memory_order_acquire);
        if (oldHead != nullptr) {
            Node* newHead = atomic_load(&oldHead->next);
            data = oldHead->data;
            delete oldHead;
            head_.store(newHead, std::memory_order_release);
            return true;
        }
        return false;
    }
};

int main() {
    AtomicStack stack;
    stack.push(42);
    int value;
    if (stack.pop(value)) {
        std::cout << "Popped value: " << value << std::endl;
    }
    return 0;
}

