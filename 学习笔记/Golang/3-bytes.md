# 3 bytes

package **bytes** provides many utility functions for byte slice, it is analogous to package **strings**, which provides many utility functions for string.

as following, split package bytes' functions into several categories:

- compare
- count & contains & index
- trim & replace
- join & split

here is the example:

```go
package main

import (
	"bytes"
	"fmt"
)

func main() {
	b1 := []byte{1, 2, 3, 4, 5}
	b2 := []byte{1, 2, 3, 2, 3, 2}
	b3 := []byte("hello world")

	// compare
	fmt.Println(bytes.Compare(b1, b2))
	fmt.Println(bytes.Equal(b1, b2))

	// count & contains & index
	// - count
	fmt.Println(bytes.Count(b2, []byte{2, 3, 2})) // 2, 3, 2, 3, 2, Counts doesn't take overlapping into consideration
	// - contains
	fmt.Println(bytes.Contains(b1, []byte{2, 3}))
	// - index
	fmt.Println(bytes.Index(b1, []byte{3, 4}))
	fmt.Println(bytes.LastIndex(b1, []byte{3, 4}))

	// trim & replace
	fmt.Println(string(bytes.Trim(b3, "hd")))
	fmt.Println(string(bytes.TrimLeft(b3, "hd")))
	fmt.Println(string(bytes.TrimRight(b3, "hd")))
	fmt.Println(bytes.TrimPrefix(b1, []byte{1, 2}))
	fmt.Println(bytes.TrimSuffix(b1, []byte{4, 5}))
	fmt.Println(bytes.Replace(b1, []byte{3, 4}, []byte{7, 8}, -1))

	// join & split
	// - join
	ss := [][]byte{b1, b2}
	sep := []byte{0, 0}
	fmt.Println(bytes.Join(ss, sep))
	// -split
	fmt.Println(bytes.Split(b1, []byte{3}))
	fmt.Println(bytes.SplitAfter(b1, []byte{3}))

	fmt.Println(bytes.SplitN(b2, []byte{2}, 2))
	fmt.Println(bytes.SplitAfterN(b2, []byte{2}, 3))
	fmt.Println(bytes.SplitAfterN(b2, []byte{2}, 2))

}
```



