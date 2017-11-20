#### 题目

给定一个表示各数位取值的数组，如用数组[ 1 2 3 4 5 6 7 8 9 ]来代表数字123456789，对其进行+1操作。数组A[0]代表的是最高有效位，A[max]是最低有效位。

这里通过变量**i**从最低有效位开始遍历，直到最高有效位截止，遍历过程中处理好进位和本位和就ok了。

```c
void plus_one(int digits[], int len, int *_digits, int *_len) {

    _digits = (int *)malloc(sizeof(int) * (len+1));
    memset(_digits, 0, len+1);
    
    int sum = 0;
    int carry = 1;
    for(int i =  len-1; i >= 0; i--) {
        sum = carry + digits[i];
       carry = sum / 10;
        _digits[i+1] = sum % 10;
    }

    if(carry > 0) {
        _digits[0] = carry;
        *_len = len + 1;
    }
    else {
        _digits += 1;
        *_len = len;
    }
}
```


