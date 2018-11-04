压缩文件的创建、读取操作，golang标准库中也提供了相应的库来实现，因为不同的压缩格式对应着不同的压缩算法，有不同的package来支持，这里不可能一一列举，就将平时我比较常用的tar和zip格式为例，来演示下如何在golang中支持压缩文件的创建、读取操作。

# tar文件创建、读取

## tar文件创建

```go
func writeTarball(tarball string, fnames []string) {

	fmt.Println("files to compress:", len(os.Args[2:]))

	// - 创建tar writer
	var buf_tar bytes.Buffer
	tw := tar.NewWriter(&buf_tar)

	// - 读取所有待压缩文件
	files := readFiles(fnames)

	// - 将待压缩的数据以tar header/body的形式进行登记
	for _, file := range files {
		hdr := &tar.Header{
			Name: file.Name,
			Mode: 0600,
			Size: int64(len(file.Body)),
		}
		if err := tw.WriteHeader(hdr); err != nil {
			log.Fatal(err)
		}
		if _, err := tw.Write([]byte(file.Body)); err != nil {
			log.Fatal(err)
		}
	}

	// - call tw.Close() flush压缩数据到[]byte中存储
	if err := tw.Close(); err != nil {
		log.Fatal(err)
	}

	// - 将压缩后数据写入磁盘
	tfile, err := os.Create(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1)
	}

	tfile.Write(buf_tar.Bytes())
	fmt.Println("archive files done")
}
```

## tar文件读取

```go
func readTarball(tarball string) {

	// 读取tarball数据到buf
	ifo, ok := checkFileExisted(tarball)

	if !ok {
		fmt.Fprintf(os.Stderr, "error: tarball %s not existed\n")
		os.Exit(1)
	}

	buf := make([]byte, ifo.Size())
	file, err := os.Open(tarball)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1)
	}

	_, err = file.Read(buf)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1)
	}

	// 创建tar reader并解析文件数据
	buf_tar := bytes.NewBuffer(buf)
	tr := tar.NewReader(buf_tar)

	// tar reader对压缩包中的tar header\body进行读取
	for {
		hdr, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
			break
		}

		name := hdr.Name
		sz := hdr.Size
		buf := bytes.NewBuffer(make([]byte, sz))
		io.Copy(buf, tr)

		fmt.Fprintf(os.Stdout, "read tarball: [%s]->[%d]bytes->[%s]\n",
			name, sz, strings.TrimRight(buf.String(), "\n"))
	}
}
```

# zip文件创建、读取

## zip文件创建

```go
import (
	zip2 "archive/zip"
    "os"
    "fmt"
)
func writeZip(zip string, fnames []string) {

	var buf_zip bytes.Buffer
	zw := zip2.NewWriter(&buf_zip)

	for _, f := range fnames {
		ifo, err := os.Stat(f)
		checkError(err, true)
		buf := make([]byte, ifo.Size())

		file, err := os.Open(f)
		checkError(err, true)

		_, err = file.Read(buf)
		checkError(err, true)

		w, err := zw.Create(f)
		checkError(err, true)

		w.Write(buf)
	}

	zw.Close()

	file, err := os.Create(zip)
	checkError(err, true)

	file.Write(buf_zip.Bytes())
}
```

## zip文件读取

```go
import (
	zip2 "archive/zip"
    "os"
    "fmt"
)
func readZip(zip string) {

	ifo, err := os.Stat(zip)
	checkError(err, true)

	file, err := os.Open(zip)
	checkError(err, true)

	zr, e := zip2.NewReader(file, ifo.Size())
	checkError(e, true)

	for _, f := range zr.File {
		name := f.Name
		data := make([]byte, f.UncompressedSize64)
		rc, _ := f.Open()
		rc.Read(data)

		fmt.Fprintf(os.Stdout, "filename:%s size:%dbytes data:%s\n",
			name, len(data), data)
	}
}
```



