# 3 bufio

bufio implements **buffered io**, bufio **wrappes interface io.Reader and io.Writer**, it uses underlying buffer to store the data that is already read or to be written, and **based on this, bufio implements reading byte, word, line, slice and writing byte, rune, string**.

## 3.1 reader

following is a bufio.Reader example, this example show how to byte, rune, bytes, slice and line.

```go
func testReader() {

	buf := bytes.NewBuffer([]byte("hello, world"))
	rd := bufio.NewReader(buf)

	b, _ := rd.ReadByte()
	fmt.Println("read byte:", string(b))

	r, _, _ := rd.ReadRune()
	fmt.Println("read rune:", string(r))

	s, _ := rd.ReadBytes(',')
	//s, _ := rd.ReadSlice(',')
	fmt.Println("read bytes:", string(s))

	rd.Reset(bufio.NewReader(os.Stdin))
	for {
		l, p, _ := rd.ReadLine()
		fmt.Println("read line:", string(l), p)
	}
}
```

## 3.2 scanner

following is a bufio.Scanner example, this example shows how to scan byte, word and line. **Before starting the scan operation, SplitMode must be specified**, bufio.ScanLine is the default SplitMode.

```go
func testScanWord() {
	sc := bufio.NewScanner(os.Stdin)
	sc.Split(bufio.ScanWords)

	for sc.Scan() {
		fmt.Println(sc.Text())
	}
}

func testScanLine() {
	sc := bufio.NewScanner(os.Stdin)
	for sc.Scan() {
		fmt.Println(sc.Text())
	}
}

func testScanByte() {
	sc := bufio.NewScanner(os.Stdin)
	sc.Split(bufio.ScanBytes)
	
	for sc.Scan() {
		for _, b := range sc.Bytes() {
			fmt.Printf("%d -> %[1]c\n", b)
		}
	}
}
```

## 3.3 writer

following is a bufio.Writer example, this example shows how to write a byte, string into bytes.Buffer or os.Stdout.

```go
func testWriter() {
	// write to buffer
	var buf bytes.Buffer
	ww := bufio.NewWriter(&buf)
	ww.WriteString("hello world")
	ww.WriteByte('\n')
	ww.Flush()             // flush the data
	fmt.Println(buf.String())

	// write to stdout
	w := bufio.NewWriter(os.Stdout)
	w.WriteString("hello")
	w.WriteString("world")
	w.WriteRune('你')
	w.WriteRune('们')
	w.WriteRune('好')
	w.WriteByte('\n')
	w.Flush()              // flush the data
}
```

## 3.4 summary

package bufio wraps io.Reader and io.Writer interface, it is very convient to do some reading or writing tasks with the help of it.




