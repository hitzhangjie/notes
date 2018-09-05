
# 1 archive

## 1.1 tar

package ```archive/tar ``` is used for creating and extracting *.tar file.

### 1.1.1 how to create a tarball?
- create a tar writer ```tw```
- open and read file content into []byte, i.e, ```tar body```
- register filename and content via ```tar header```, write tar header and tar body into tar writer
- close tar writer to flush compressed data into buffer ```buf```
- create the *.tar file and write ```buf``` into this tarball

### 1.1.2 how to extract a tarball?
- open and read tarball data into ```buf```
- create a tar reader ```tr``` to parse data in ```buf```
- use ```tr``` to iterate ```tar header``` and ```tar body```
- use ```tar header``` to get file name, use ```tar body``` to restore file content
- create file on disk according to extracted filename and content

### 1.1.3 tar example

```go
// 创建tarball、解压tarball
package main

import (
	"log"
	"archive/tar"
	"io"
	"fmt"
	"bytes"
	"os"
	"strings"
)

type FileToTar struct {
	Name, Body string
}

func main() {

	// 检查命令行参数是否有效
	checkArgs()

	// 创建压缩文件
	writeTarball(os.Args[1], os.Args[2:])

	// 读取压缩文件
	readTarball(os.Args[1])

}

// 检查参数是否合法
func checkArgs() {

	// 检查参数数量
	if len(os.Args) <= 3 {
		fmt.Fprintf(os.Stderr,
			"error, usage:\n\t "+"go run main.go <tar> <f1> <f2> ...\n")
		os.Exit(1)
	}

	// 检查压缩文件是否已经存在
	tfile := os.Args[1]
	_, ok := checkFileExisted(tfile)
	if ok {
		fmt.Fprintf(os.Stderr, "error: tarball %s already existed\n", tfile)
		os.Exit(1)
	}

	// 检查压缩文件名 & 待压缩文件是否存在
	for _, fname := range os.Args[2:] {
		_, ok := checkFileExisted(fname)
		if !ok {
			fmt.Fprintf(os.Stderr, "error: %s not existed\n", fname)
			os.Exit(1)
		}
	}
}

// 检查文件是否存在
func checkFileExisted(fname string) (os.FileInfo, bool) {
	i, e := os.Stat(fname)
	if os.IsNotExist(e) {
		return nil, false
	}

	return i, true
}

// 读取待压缩的文件内容
func readFiles(fnames []string) []FileToTar {

	files := make([]FileToTar, len(fnames))

	for idx, fname := range fnames {

		ifo, _ := checkFileExisted(fname)
		sz := ifo.Size()
		fmt.Fprintf(os.Stdout, "%s size:%d bytes\n", fname, sz)

		f, e := os.Open(fname)
		if e != nil {
			fmt.Fprintf(os.Stderr, "%s\n", e)
			os.Exit(1)
		}

		buf := make([]byte, sz)
		_, e = f.Read(buf)
		if e != nil {
			fmt.Fprintf(os.Stderr, "%s\n", e)
			os.Exit(1)
		}

		file := FileToTar{fname, string(buf)}
		files[idx] = file
	}

	return files
}

// 创建压缩文件
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

// 读取tarball
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
			break;
		}

		name := hdr.Name
		sz := hdr.Size
		buf := bytes.NewBuffer(make([]byte, sz))
		io.Copy(buf, tr)

		fmt.Fprintf(os.Stdout, "read tarball: [%s]->[%d]bytes->[%s]\n", name, sz, strings.TrimRight(buf.String(), "\n"))
	}
}
```

## 1.2 zip

package ```archive/zip``` is used for creating and extracting zip files.

### 1.2.1 how to create a zip?

- create zip writer via ```zw := zip2.NewWriter(buf_zip)```
- open and read file to be zipped into ```buf```
- create zip entry via ```f := zw.Create()```
- write zip entry data via ```f.Write(buf)```
- close and flush compressed data to zip_buf via ```zw.Close()```

### 1.2.2 how to read a zip?

- open zip file to get file handle ```f *File```
- create a zip reader via ```zr, e := zip2.NewReader(f)```
- use ```zr``` to get all zipped entries, which is of type ```[]*File```
- get zip entry filename and content

### 1.2.3 zip example

```go
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

func checkError(err error, exit bool) {

	if err != nil {
		fmt.Println(err)
		if exit {
			os.Exit(1)
		}
	}
}
```

## 1.3 summary

package archive can be used for compressing/decompressing files. 

Compressed format like *.tar or *.zip are very common, so here package archive/tar and archive/zip should be mastered.



