#include <iostream>

using namespace std;

void arr_print(int *arr, int n) {
    for (int i = 0; i < n; i++) {
        printf("%d ", *(arr + i));
    }

    printf("\n");
    return;
}

int *fibbonacci_multiply(int *x, int *y, int n, int m) {
    // O(mn) time comp
    // TODO: this algorithm is incorrect, adjustment to be done

    int *z = new int[m + n - 1];
    int hold = 0;

    for (int k = 0; k < n + m - 1; k++) {
        for (int i = 1; i <= k; i ++) {
            int j = k - i;

            if (i < n && j < m) {
                hold = hold + x[i] + y[j];
            }
        }

        z[k] = hold % 10;
        hold = hold / 10;
    }

    return z;
}

int peasant_multiply(int x, int y) {
    /*
     * O(log x * log y) time complexity
     *
     * the correctness of the following algorithm can be prove be using the 
     * recursive identity:
     *
     * if x is odd,  x * y = (x / 2) * (y + y) + y
     * if x is even, x * y = (x / 2) * (y + y)
     */
    
    int prod = 0;

    while (x > 0){
        if (x % 2 == 1) {
            prod = prod + y;
        }

        x = x / 2;
        y = y + y;
    }

    return prod;
}

int main() {
    int x[] = {1, 2};
    int y[] = {1, 2};

    arr_print(fibbonacci_multiply(x, y, 2, 2), 3);
    cout << peasant_multiply(12, 12);
}
