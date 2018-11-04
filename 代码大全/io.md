# Go Walkthrough: io package

Go is a programming language built for working with bytes. Whether you have lists of bytes, streams of bytes, or individual bytes, Go makes it easy to process. From these simple primitives we build our abstractions and services.

The io package is one of the most fundamental packages within the standard library. It provides a set of interfaces and helpers for working with streams of bytes.

This post is part of a series of walkthroughs to help you understand the standard library better. While generated documentation provides a wealth of information, it can be difficult to understand packages in a real world context. This series aims to provide context of how standard library packages are used in every day applications. If you have questions or comments you can reach me at [@benbjohnson](https://twitter.com/benbjohnson) on Twitter.

### Reading bytes

There are two fundamental operations when working with bytes: reading & writing. Let’s take a look at reading bytes first.

#### Reader interface

The basic construct for reading bytes from a stream is the [Reader](https://golang.org/pkg/io/#Reader) interface:

```
type Reader interface {
        Read(p []byte) (n int, err error)
}
```

This interface is implemented throughout the standard library by everything from [network connections](https://golang.org/pkg/net/#Conn) to [files](https://golang.org/pkg/os#File) to [wrappers for in-memory slices](https://golang.org/pkg/bytes/#Reader).

The Reader works by passing a buffer, p, to the Read() method so that we can reuse the same bytes. If Read() returned a byte slice instead of accepting one as an argument then the reader would have to allocate a new byte slice on every Read() call. That would wreak havoc on the garbage collector.

One problem with the Reader interface is that it comes with some subtle rules. First, it returns an io.EOF error as a normal part of usage when the stream is done. This can be confusing for beginners. Second, your buffer isn’t guaranteed to be filled. If you pass an 8-byte slice you could receive anywhere between 0 and 8 bytes back. Handling partial reads can be messy and error prone. Fortunately there are helpers functions for this problem.

#### Improving reader guarantees

Let’s say you have a protocol you’re parsing and you know you need to read an 8-byte uint64 value from a reader. In this case it’s preferable to use io.ReadFull() since you have a fixed size read:

```
func ReadFull(r Reader, buf []byte) (n int, err error)
```

This function ensures that your buffer is completely filled with data before returning. If your buffer is partially read then you’ll receive an io.ErrUnexpectedEOF back. If no bytes are read then an io.EOF is returned. This simple guarantee simplifies your code tremendously. To read 8 bytes you only need to do this:

```
buf := make([]byte, 8)
if _, err := io.ReadFull(r, buf); err == io.EOF {
        return io.ErrUnexpectedEOF
} else if err != nil {
        return err
}
```

There are also many higher level parsers such as [binary.Read()](https://golang.org/pkg/encoding/binary/#Read) which handle parsing specific types. We’ll cover those in future walkthroughs within different packages.

Another lesser used helper function is [ReadAtLeast()](https://golang.org/pkg/io/#ReadAtLeast):

```
func ReadAtLeast(r Reader, buf []byte, min int) (n int, err error)
```

This function will read additional data into your buffer if it is available but will always return a minimum number of bytes. I haven’t found a need for this function personally but I can see it being useful if you need to minimize Read() calls and you’re willing to buffer additional data.

#### Concatenating streams

Many times you’ll encounter instances where you need to combine multiple readers together. You can combine these into a single reader by using the [MultiReader](https://golang.org/pkg/io/#MultiReader):

```
func MultiReader(readers ...Reader) Reader
```

For example, you may be sending a HTTP request body that combines an in-memory header with data that’s on-disk. Many people will try to copy the header and file into an in-memory buffer but that’s slow and can use a lot of memory.

Here’s a simpler approach:

```
r := io.MultiReader(
        bytes.NewReader([]byte("...my header...")),
        myFile,
)
http.Post("http://example.com", "application/octet-stream", r)
```

The MultiReader let’s the [http.Post()](https://golang.org/pkg/net/http/#Post) consider the two readers as one single concatenated reader.

#### Duplicating streams

One issue you may run across when using readers is that once a reader is read, the data cannot be reread. For example, your application may fail to parse an HTTP request body and you’re unable to debug the issue because the parser has already consumed the data.

The [TeeReader](https://golang.org/pkg/io/#TeeReader) is a great option for capturing the reader’s data while not interfering with the consumer of the reader.

```
func TeeReader(r Reader, w Writer) Reader
```

This function constructs a new reader that wraps your reader, r. Any reads from the new reader will also get written to w. This writer can be anything from an [in-memory buffer](https://golang.org/pkg/bytes/#Buffer) to a log file to [STDERR](https://golang.org/pkg/os/#pkg-variables).

For example, you can capture bad requests like this:

```
var buf bytes.Buffer
body := io.TeeReader(req.Body, &buf)
// ... process body ...
if err != nil {
        // inspect buf
        return err
}
```

However, it’s important that you restrict the request body that you’re capturing so that you don’t run out of memory.

#### Restricting stream length

Because streams are unbounded they can cause memory or disk issues in some scenarios. The most common example is a file upload endpoint. Endpoints typically have size restrictions to prevent the disk from filling, however, it can be tedious to implement this by hand.

The [LimitReader](https://golang.org/pkg/io/#LimitReader) provides this functionality by producing a wrapping reader that restricts the total number of bytes read:

```
func LimitReader(r Reader, n int64) Reader
```

One issue with LimitReader is that it won’t tell you if your underlying reader exceeds n. It will simply return [io.EOF](https://golang.org/pkg/io/#EOF) once n bytes are read from r. One trick you can use is to set the limit to n+1 and then check if you’ve read more than n bytes at the end.

### Writing bytes

Now that we’ve covered reading bytes from streams let’s look at how to write them to streams.

#### Writer interface

The Writer interface is simply the inverse of the Reader. We provide a buffer of bytes to push out onto a stream.

```
type Writer interface {
        Write(p []byte) (n int, err error)
}
```

Generally speaking writing bytes is simpler than reading them. Readers complicate data handling because they allow partial reads, however, partial writes will always return an error.

#### Duplicating writes

Sometimes you’ll want to send writes to multiple streams. Perhaps to a log file or to STDERR. This is similar to the [TeeReader](https://golang.org/pkg/io/#TeeReader) except that we want to duplicate writes instead of duplicating reads.

The [MultiWriter](https://golang.org/pkg/io/#MultiWriter) comes in handy in this case:

```
func MultiWriter(writers ...Writer) Writer
```

The name is a bit confusing since it’s not the writer version of [MultiReader](https://golang.org/pkg/io/#MultiReader). Whereas MultiReader concatenates several readers into one, the MultiWriter returns a writer that duplicates each write to multiple writers.

I use MultiWriter extensively in unit tests where I need to assert that a service is logging properly:

```
type MyService struct {
        LogOutput io.Writer
}
...
var buf bytes.Buffer
var s MyService
s.LogOutput = io.MultiWriter(&buf, os.Stderr)
```

Using a MultiWriter allows me to verify the contents of buf while also seeing the full log output in my terminal for debugging.

#### Optimizing string writes

There are a lot of writers in the standard library that have a WriteString() method which can be used to improve write performance by not requiring an allocation when converting a string to a byte slice. You can take advantage of this optimization by using the io.[WriteString](https://golang.org/pkg/io/#WriteString)() function.

The function is simple. It first checks if the writer implements a WriteString() method and uses it if available. Otherwise it falls back to copying the string to a byte slice and using the Write() method.

*(Thanks to* [*Bouke van der Bijl*](https://twitter.com/BvdBijl) *for pointing this one out)*

### Copying bytes

Now that we can read bytes and we can write bytes, it only makes sense that we’d want to plug those two sides together and copy between readers and writers.

#### Connecting readers & writers

The most basic way to copy a reader to a writer is the aptly named [Copy](https://golang.org/pkg/io/#Copy)() function:

```
func Copy(dst Writer, src Reader) (written int64, err error)
```

This function uses a 32KB buffer to read from src and then write to dst. If any error besides io.EOF occurs in the read or write then the copy is stopped and the error is returned.

One issue with Copy() is that you cannot guarantee a maximum number of bytes. For example, you may want copy a log file up to its current file size. If the log continues to grow during your copy then you’ll end up with more bytes than expected. In this case you can use the [CopyN](https://golang.org/pkg/io/#CopyN)() function to specify an exact number of bytes to be written:

```
func CopyN(dst Writer, src Reader, n int64) (written int64, err error)
```

Another issue with Copy() is that it requires an allocation for the 32KB buffer on every call. If you are performing a lot of copies then you can reuse your own buffer by using [CopyBuffer](https://golang.org/pkg/io/#CopyBuffer)() instead:

```
func CopyBuffer(dst Writer, src Reader, buf []byte) (written int64, err error)
```

I haven’t found the overhead of Copy() to be very high so I personally don’t use CopyBuffer().

#### Optimizing copy

To avoid using an intermediate buffer entirely, types can implement interfaces to read and write directly. When implemented, the Copy() function will avoid the intermediate buffer and use these implementations directly.

The [WriterTo](https://golang.org/pkg/io/#WriterTo) interface is available for types that want to write their data out directly:

```
type WriterTo interface {
        WriteTo(w Writer) (n int64, err error)
}
```

I’ve used this in BoltDB’s [Tx.WriteTo](https://godoc.org/github.com/boltdb/bolt#Tx.WriterTo)() which allows users to snapshot the database from a transaction.

On the read side, the [ReaderFrom](https://golang.org/pkg/io/#ReaderFrom) allows a type to directly read data from a reader:

```
type ReaderFrom interface {
        ReadFrom(r Reader) (n int64, err error)
}
```

#### Adapting reader & writers

Sometimes you’ll find that you have a function that accepts a Reader but all you have is a Writer. Perhaps you need to write out data dynamically to an HTTP request but http.[NewRequest](https://golang.org/pkg/net/http/#NewRequest)() only accepts a Reader.

You can invert a writer by using io.[Pipe](https://golang.org/pkg/io/#Pipe)():

```
func Pipe() (*PipeReader, *PipeWriter)
```

This provides you with a new reader and writer. Any writes to the new PipeWriter will go to the PipeReader.

I rarely use this functionality directly, however, the exec.[Cmd](https://golang.org/pkg/os/exec/#Cmd) uses this for implementing Stdin, Stdout, and Stderr pipes which can be really useful when working with command execution.

### Closing streams

All good things must come to an end and this is no exception when working with byte streams. The [Closer](https://golang.org/pkg/io/#Closer) interface is provided as a generic way to close streams:

```
type Closer interface {
        Close() error
}
```

There’s not much to say about Closer since it is so simple, however, I find it useful to always return an error from my Close() functions so that my types can implement Closer when it’s required. Closer isn’t always used directly but is sometimes combined with other interfaces the case of [ReadCloser](https://golang.org/pkg/io/#ReadCloser), [WriteCloser](https://golang.org/pkg/io/#WriteCloser), and [ReadWriteCloser](https://golang.org/pkg/io/#ReadWriteCloser).

### Moving around within streams

Streams are usually a continuous flow of bytes from beginning to end but there are a few exceptions. A file, for example, can be operated on as a stream but you can also jump to a specific position within the file.

The [Seeker](https://golang.org/pkg/io/#Seeker) interface is provided to jump around in a stream:

```
type Seeker interface {
        Seek(offset int64, whence int) (int64, error)
}
```

There are 3 ways to jump around: move from on the current position, move from the beginning, and move from the end. You specify the mode of movement using the whence argument. The offset argument specifies how many bytes to move by.

Seeking can be useful if you are using fixed length blocks in a file or if your file contains an index of offsets. Sometimes this data is stored in the header so moving from the beginning makes sense but sometimes this data is specified in a trailer so you’ll need to move from the end.

### Optimizing for Data Types

Reading and writing in chunks can be tedious if all you need is a single byte or [rune](https://golang.org/pkg/builtin/#rune). Go provides some interfaces for making this easier.

#### Working with individual bytes

The [ByteReader](https://golang.org/pkg/io/#ByteReader) and [ByteWriter](https://golang.org/pkg/io/#ByteWriter) interfaces provide a simple interface for reading and writing single bytes:

```
type ByteReader interface {
        ReadByte() (c byte, err error)
}
type ByteWriter interface {
        WriteByte(c byte) error
}
```

You’ll notice that there’s no length arguments since the length will always be either 0 or 1. If a byte is not read or written then an error is returned.

The [ByteScanner](https://golang.org/pkg/io/#ByteScanner) interface is also provided for working with buffered byte readers:

```
type ByteScanner interface {
        ByteReader
        UnreadByte() error
}
```

This allows you to push the previously read byte back onto the reader so it can be read the next time. This is particularly useful when writing LL(1) parsers since it allows you to peek at the next available byte.

#### Working with individual runes

If you are parsing Unicode data then you’ll need to work with runes instead of individual bytes. In that case, the [RuneReader](https://golang.org/pkg/io/#RuneReader) and [RuneScanner](https://golang.org/pkg/io/#RuneScanner) are used instead:

```
type RuneReader interface {
        ReadRune() (r rune, size int, err error)
}
type RuneScanner interface {
        RuneReader
        UnreadRune() error
}
```

### Conclusion

Byte streams are essential to most Go programs. They are the interface to everything from network connections to files on disk to user input from the keyboard. The [io](https://golang.org/pkg/io) package provides the basis for all these interactions.

We’ve looked at reading bytes, writing bytes, copying bytes, and finally looked at optimizing these operations. These primitives may seem simple but they provide the building blocks for all data-intensive applications. Please take a look at the [io](https://golang.org/pkg/io) package and consider its interfaces in your application.