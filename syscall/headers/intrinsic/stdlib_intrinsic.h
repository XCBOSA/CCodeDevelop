#ifndef STDLIB_INTRINSIC_H
#define STDLIB_INTRINSIC_H

typedef int (*sort_comparator)(const void *, const void *);

void _stdlib_intrinsic_qsort(char *base, int elemSize, int low, int high, sort_comparator compare) {
    if (low < high) {
        int originalLow = low, originalHigh = high;
        int selectIndex = low;
        while (low < high) {
            while (low < high && (compare(base + high * elemSize, base + selectIndex * elemSize) >= 0)) {
                high--;
            }
            while (low < high && (compare(base + low * elemSize, base + selectIndex * elemSize) <= 0)) {
                low++;
            }
            if (low < high) {
                for (int i = 0; i < elemSize; i++) {
                    char c = base[low * elemSize + i];
                    base[low * elemSize + i] = base[high * elemSize + i];
                    base[high * elemSize + i] = c;
                }
            }
        }
        for (int i = 0; i < elemSize; i++) {
            char c = base[selectIndex * elemSize + i];
            base[selectIndex * elemSize + i] = base[low * elemSize + i];
            base[low * elemSize + i] = c;
        }
        if (originalLow < high) {
            _stdlib_intrinsic_qsort(base, elemSize, originalLow, low - 1, compare);
        }
        if (low < originalHigh) {
            _stdlib_intrinsic_qsort(base, elemSize, low + 1, originalHigh, compare);
        }
    }
}

void qsort(void *base, int num, int size, sort_comparator comparator) {
    _stdlib_intrinsic_qsort(base, size, 0, num - 1, comparator);
}

int int_comparator(void *lhs, void *rhs) {
    return (*(int *)lhs) - (*(int *)rhs);
}

int long_comparator(void *lhs, void *rhs) {
    return (*(long *)lhs) - (*(long *)rhs);
}

int double_comparator(void *_lhs, void *_rhs) {
    double lhs = *(double *)_lhs;
    double rhs = *(double *)_rhs;
    if (lhs > rhs) return 1;
    if (lhs == rhs) return 0;
    if (lhs < rhs) return -1;
}

#endif
