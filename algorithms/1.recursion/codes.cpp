#include <iostream>
// #include <stdio.h>

using namespace std;

int peasant_multiply(int x, int y) {
    int prod;

    if (x == 0)
        return 0;

    else {
        prod = peasant_multiply(x / 2, y + y);

        if (x % 2 == 1) 
            prod = prod + y;

        return prod;
    }
}

void hanoi(int n, char from, char via, char to) {
    if (n > 0) {
        hanoi(n - 1, from, to, via);
        printf("move disk %d from %c to %c\n", n, from, to);
        hanoi(n - 1, via, from, to);
    }
}

int main() {
    hanoi(3, 'a', 'b', 'c');

    return 0;
}
