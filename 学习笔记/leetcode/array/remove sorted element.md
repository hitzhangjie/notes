#### 题目

##### - 有序数组，最多只保留一个元素

给定一个排序好的数组，数组中可能出现重复的元素，要求删除重复出现的元素，如数组[ 1 2 2 3 4 5]，处理后应为[ 1 2 3 4 5 ]。

这里还是采用的与**remove element.md**中类似的方法，即通过两个索引变量，一个控制原数组的遍历操作，一个控制新数组的最后一个有效元素的位置。

```c
void removeDuplicates(int A[], int len, int *_len) {
    if(len == 0) {
        *_len = 0;
        return;
    }

    int j = 0;
    for(int i = 1; i < len; i++) {
        if(A[j] != A[i]) {
            A[++j] = A[i];
        }
    }
    *_len = j + 1;
}
```

##### - 有序数组，最多可保留两个元素

给定一个排序好的数组，数组中可能出现重复的元素，要求元素最多可重复出现两次，如数组[ 1 2 2 2 3 4 5]，处理后应为[ 1 2 2 3 4 5]。

这里还是采用的与**remove element.md**中类似的方法，即通过两个索引变量，一个控制原数组的遍历操作，一个控制新数组的最后一个有效元素的位置。另外呢，再额外通过一个变量num来记录当前A[j]重复出现的次数以决定是否要将重复元素从数组删除。

```c
void removeDuplicates(int A[], int len, int *_len) {
    if(len == 0) {
        *_len = 0;
        return;
    }

    int j = 0;
    int num = 0;
    for(int i = 1; i < len; i++) {
        if(A[j] == A[i]) {
            num++;
            if(num < 2) {
                A[++j] = A[i];
            }
        } else {
            A[++j] = A[i];
            num = 0;
        }
    }
    *_len = j + 1;
}
```


