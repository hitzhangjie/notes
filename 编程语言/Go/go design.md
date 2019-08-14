# how to understand abstraction ?

**Edsger Dijkstra**: The purpose of abstraction is not to be vague, but to create a new semantic level in which one can be absolutely precise.



# why datetime format '2006-01-02 15:04:05.999' ？

Using a reference time is actually simpler than using formatting codes—once you get your head around the idea of what the reference time is. The numbers aren't random; there is one reference time: the specific instant in time that the time package uses for all its formatting functions. You just format that instant the way you want your times formatted, and the time package will imitate that format.

参考内容：https://groups.google.com/forum/#!searchin/golang-nuts/2006-01-02$2015$3A04$3A05|sort:date/golang-nuts/0nQbfyNzk9E/XtJt2X3dk7IJ



# why no constructors or descrutors ?

C++ has more than one type constructor, it also has one destructor. It's OK to take memory footprint and performance into consideration. 

But the tradeoffs btw readability, maintenancy, memory  footprint and performance optimizations, developers cares more about readability and maintenancy, besides we have better ways (GC) to optimize memory allocation and performance, so go doesn't need constructors or desctructors.



# why using conversion over casting ?

The idea of conversion over casting, there would be a cost of new memory, but we always be safe than sorry. Conversion over casting, it's an integrity play to keep our software, our data and memory safe.

following is an example:

```bash
|byte1|...|...|...|
0     1
```

if we declare a int8 variable, it's stored in memory area [0, 1), but if we write code as following:

```c
struct B {
	int8 n8;
} b;

int32 n32; 
auto sum = n32 + b.n8;
```

Maybe compiler will add 3 more bytes before `int8 n8`, after that, if we have some other code to read data byte by byte from `struct B b`, it will read more than one byte, maybe it will cause errors.

While in go, conversion will create new variable, it works similar to:

```go
var tmp = int32(b.n8)	
var sum = n32 + tmp
```

`struct B b` field `int 8 n8` only takes 1 byte, it's type-safe.



# why struct fields alignments and padding?

Alignments are there to make reading and writing memory as effient as possible. To understand this, we must understand hardware word boundary first.

```bash
|----------|----------|
0          8          16
```

Providing hardware word is 8-byte long.

If we have a struct like following:

```go
struct V {
  f1 int8
  f2 int8
}
```

If there's no struct fields alignments, V.f1, V.f2 maybe stored like this in memory:

```bash
|------v.f1|v.f2-------|
0          8          16
```

As hardware instruction can only read 8-byte once, so it will run 2 instructions to read v.f1 and v.f2. It's not efficient!

While there's alignments, v.f1 and v.f2 will be stored like this in memory:

```bash
|-v.f1-v.f2|----------|
0          8          16
```

Now only one read instruction to execute is enough, it's much more efficient than no-alignments occassion.

To fullfill struct fields alignments, some bytes will be padded before fields, that's padding, for example:

```go
struct V {
  b bool
  n1 int8
  n2 int4
}
```

If there's no alignements and padding, sizeof(struct v) will be 6 bytes.

If there's struct fields alignments, padding will be put before or after fields, like:

```go
struct v {
  b bool  // put at area [0,1)
  n1 int8 // put at area [1,2)
  ...     // padding 2 bytes
  n2 int4 // put at area [4,8)
}
```

now, sizeof(struct v) will be 8 bytes.



# named type conversion and literal type conversion ?

- named type, type has a name
- literal type, also called unnamed type, doesn't have a name

in Go, named type conversion must be explicit conversion, while literal type conversion looks like implicit conversion is ok. Actually, literal type conversion is not really implicit conversion, the integrity is guaranteed in our source code.

Following is an example:

```go
type A struct {
	a int
}

type AA struct {
	a int
}

  
a := A{}
aa := AA{}
a = A(aa)			// named type AA must explicitly converted to A

a = struct {  // literal type struct{int} converted to A, integrity is met by source code
			a int
		}{
			100,
		}
```



# why goroutine can only directly access its frame memory ?

The code we write either reads from memory or writes to memory. Goroutines only has direct access to memory for the frame it is operating on.

For exmaple: 

```go
func main() {
	v := 10
}
```

In this frame `main`, main goroutine wants to assign value `10` to variable `v`, we must allocated an memory area to store the value 10.

```bash
|---main-frame---|
|
|--data-section--|
|      10        |
|--text-section--|
|
|--    ...     --|
|                |
```

If current active frame is `main-frame`, the direct memory that this goroutine can only read from or write to is this area `main-frame`. What does that mean to us?

It means if this data transformation has to be executed by the goroutine, and it can only operate within the scope of memory within this frame, it means all of the data that the goroutine needs to perform this data transformation has to be in there, this frame.

As the example metioned above, we assign value 10 to variable v, we basically are now gonna be allocating eight bytes of memory right here inside this frame `data-section`. It has to be inside this frame, because if it's not, the goroutine cannot access it.

Understand that this frame is serving a really important purpose. It's creating a sandbox, a layer of isolation. It gives us  a sense of immutability that the goroutine can only mutate or cause problems here and nowhere else in our code. This is very very powerful constructs that we're gonna wanna leverage and it starts to allow us to talk about things like semantics.

# why passing as value in function arguments ?

"What we see is what we got !" Yes, but there's more reasons, one of which is value mechanics.

Passing as value in function arguments actually makes a copy of original value, it provides an isolation level in active frame level, it is very very important! 

Let's diff the terms, **mechanics and semantics**:

- mechanics, it means how things work

- semantics, it means how things behave

Everything has a cost, nothing is free. So what's the cost of value semantics ? We have multiple copies of data through  t the program. There's no efficiency with the value semantics, and sometimes it can be very complicated to get a piece of data that's changed and to get that updated everywhere it needs to be.

Our value semantics are very powerful semantics because it's gonna reduce things like side effects (only mutate in active frame area). It's giving us isolation, it's giving us theses levels of immutability that are so important torvards integrity. 

But sometimes, the inefficiency of value semantics might cause more complexity in the code. It might even cause some performance problems, and performance does matter.

One of the things we've gotta learn is how to balance our value and our pointer semantics, following is an example:

```go
func main() {
  v := 10
  increment(v)
}

// value semantics, only mutate in frame of `increment`, no side effects out of this frame
func increment(v int) {
  v++
}

// pointer semantics, argument v is new copy of data `v`, also passing by value
// but with pointer semantics, it can has side effects out of this frame
fucn increment(v &int) {
  *v = (*v)++
}
```

