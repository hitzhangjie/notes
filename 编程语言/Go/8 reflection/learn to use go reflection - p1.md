# Learning to Use Go Reflection

[![Go to the profile of Jon Bodner](assets/1*yHkNHFXnp6oQ_Rb66JdxEQ-20190303150216219.jpeg)](https://medium.com/@jon_43067?source=post_header_lockup)

[Jon Bodner](https://medium.com/@jon_43067) Dec 13, 2017

### **What’s Reflection?**

Most of the time, variables, types, and functions in Go are pretty straightforward. When you need a type, you define a type:

```go
type Foo struct {
  A int
  B string
}
```

When you need a variable, you define a variable:

```go
var x Foo
```

And when you need a function, you define a function:

```go
func DoSomething(f Foo) {
  fmt.Println(f.A, f.B)
}
```

But sometimes you want to work with variables at runtime using information that didn’t exist when the program was written. Maybe you’re trying to map data from a file or network request into a variable. Maybe you want to build a tool that works with different types. In those situations, you need to use *reflection*. Reflection gives you the ability to examine types at runtime. It also *allows* you to examine, modify, and create variables, functions, and structs at runtime.

Reflection in Go is built around three concepts: **Types, Kinds, and Values**. The reflect package in the standard library is the home for the types and functions that implement reflection in Go.

### **Finding Your Type**

First let’s look at types. You can use reflection to get the type of a variable var with the function call varType := reflect.TypeOf(var). This returns a variable of type reflect.Type, which has methods with all sorts of information about the type that defines the variable that was passed in.

The first method we’ll look at is Name(). This returns, not surprisingly, the name of the type. Some types, like a slice or a pointer, don’t have names and this method returns an empty string.

The next method, and in my opinion the first really useful one, is Kind(). The kind is what the type is made of — a slice, a map, a pointer, a struct, an interface, a string, an array, a function, an int or some other primitive type. The difference between the kind and the type can be tricky to understand, but think of it this way. *If you define a struct named Foo, the kind is struct and the type is Foo*.

One thing to be aware of when using reflection: everything in the reflect package assumes that you know what you are doing and many of the function and method calls will panic if used incorrectly. For example, if you call a method on reflect.Type that’s associated with a different kind of type than the current one, your code will panic. Always remember to use the kind of your reflected type to know which methods will work and which ones will panic.

If your variable is a pointer, map, slice, channel, or array, you can find out the contained type by using varType.Elem().

If your variable is a struct, you can use reflection to get the number of fields in the struct, and get back each field’s structure contained in a reflect.StructField struct. The reflect.StructField gives you the name, order, type, and struct tags on a fields.

Since a few lines of source code are worth a thousand words of prose, here’s a simple example for dumping out the type information for a variety of variables:

```go
type Foo struct {
	A int `tag1:"First Tag" tag2:"Second Tag"`
	B string
}

func main() {
	sl := []int{1, 2, 3}
	greeting := "hello"
	greetingPtr := &greeting
	f := Foo{A: 10, B: "Salutations"}
	fp := &f

	slType := reflect.TypeOf(sl)
	gType := reflect.TypeOf(greeting)
	grpType := reflect.TypeOf(greetingPtr)
	fType := reflect.TypeOf(f)
	fpType := reflect.TypeOf(fp)

	examiner(slType, 0)
	examiner(gType, 0)
	examiner(grpType, 0)
	examiner(fType, 0)
	examiner(fpType, 0)
}

func examiner(t reflect.Type, depth int) {
	fmt.Println(strings.Repeat("\t", depth), "Type is", t.Name(), "and kind is", t.Kind())
	switch t.Kind() {
	case reflect.Array, reflect.Chan, reflect.Map, reflect.Ptr, reflect.Slice:
		fmt.Println(strings.Repeat("\t", depth+1), "Contained type:")
		examiner(t.Elem(), depth+1)
	case reflect.Struct:
		for i := 0; i < t.NumField(); i++ {
			f := t.Field(i)
			fmt.Println(strings.Repeat("\t", depth+1), "Field", i+1, "name is", f.Name, "type is", f.Type.Name(), "and kind is", f.Type.Kind())
			if f.Tag != "" {
				fmt.Println(strings.Repeat("\t", depth+2), "Tag is", f.Tag)
				fmt.Println(strings.Repeat("\t", depth+2), "tag1 is", f.Tag.Get("tag1"), "tag2 is", f.Tag.Get("tag2"))
			}
		}
	}
}
```

And the output looks like this:

```bash
 Type is  and kind is slice
	 Contained type:
	 Type is int and kind is int
 Type is string and kind is string
 Type is  and kind is ptr
	 Contained type:
	 Type is string and kind is string
 Type is Foo and kind is struct
	 Field 1 name is A type is int and kind is int
		 Tag is tag1:"First Tag" tag2:"Second Tag"
		 tag1 is First Tag tag2 is Second Tag
	 Field 2 name is B type is string and kind is string
 Type is  and kind is ptr
	 Contained type:
	 Type is Foo and kind is struct
		 Field 1 name is A type is int and kind is int
			 Tag is tag1:"First Tag" tag2:"Second Tag"
			 tag1 is First Tag tag2 is Second Tag
		 Field 2 name is B type is string and kind is string
```

### **Making a New Instance**

In addition to examining the types of your variables, you can also use reflection to read, set, or create values. First you need to use refVal := reflect.ValueOf(var) to create a reflect.Value instance for your variable. If you want to be able to use reflection to modify the value, you have to get a pointer to the variable with refPtrVal := reflect.ValueOf(&var); if you don’t, you can read the value using reflection, but you can’t modify it.

Once you have a reflect.Value, you can get the reflect.Type of the variable with the Type() method.

If you want to modify a value, remember it has to be a pointer, and you have to dereference the pointer first. You use refPtrVal.Elem().Set(newRefVal) to make the change, and the value passed into Set() has to be a reflect.Value too.

If you want to create a new value, you can do so with the function call newPtrVal := reflect.New(varType), passing in a reflect.Type. This returns a pointer value that you can then modify. using Elem().Set() as described above.

Finally, you can go back to a normal variable by calling the Interface() method. Because [Go doesn’t have generics](https://medium.com/capital-one-developers/closures-are-the-generics-for-go-cb32021fb5b5), the original type of the variable is lost; the method returns a value of type interface{}. If you created a pointer so that you could modify the value, you need to dereference the reflected pointer by using Elem().Interface(). In both cases, you will need to cast your empty interface to the actual type in order to use it.

Here’s some code to demonstrate these concepts:

```go
type Foo struct {
	A int `tag1:"First Tag" tag2:"Second Tag"`
	B string
}

func main() {
	greeting := "hello"
	f := Foo{A: 10, B: "Salutations"}

	gVal := reflect.ValueOf(greeting)
	// not a pointer so all we can do is read it
	fmt.Println(gVal.Interface())

	gpVal := reflect.ValueOf(&greeting)
	// it’s a pointer, so we can change it, and it changes the underlying variable
	gpVal.Elem().SetString("goodbye")
	fmt.Println(greeting)

	fType := reflect.TypeOf(f)
	fVal := reflect.New(fType)
	fVal.Elem().Field(0).SetInt(20)
	fVal.Elem().Field(1).SetString("Greetings")
	f2 := fVal.Elem().Interface().(Foo)
	fmt.Printf("%+v, %d, %s\n", f2, f2.A, f2.B)
}
```

The output looks like:

```bash
hello
goodbye
{A:20 B:Greetings}, 20, Greetings
```

**You can run the example at** [**https://play.golang.org/p/PFcEYfZqZ8**](https://play.golang.org/p/PFcEYfZqZ8)

### **Making Without Make**

In addition to making instances of built-in and user-defined types, you can also use reflection to make instances that normally require the make function. You can make a slice, map, or channel using the reflect.MakeSlice, reflect.MakeMap, and reflect.MakeChan functions. In all cases, you supply a reflect.Type and get back a reflect.Value that you can manipulate with reflection, or that you can assign back to a standard variable.

```go
func main() {
	// declaring these vars, so I can make a reflect.Type
	intSlice := make([]int, 0)
	mapStringInt := make(map[string]int)

	// here are the reflect.Types
	sliceType := reflect.TypeOf(intSlice)
	mapType := reflect.TypeOf(mapStringInt)

	// and here are the new values that we are making
	intSliceReflect := reflect.MakeSlice(sliceType, 0, 0)
	mapReflect := reflect.MakeMap(mapType)

	// and here we are using them
	v := 10
	rv := reflect.ValueOf(v)
	intSliceReflect = reflect.Append(intSliceReflect, rv)
	intSlice2 := intSliceReflect.Interface().([]int)
	fmt.Println(intSlice2)

	k := "hello"
	rk := reflect.ValueOf(k)
	mapReflect.SetMapIndex(rk, rv)
	mapStringInt2 := mapReflect.Interface().(map[string]int)
	fmt.Println(mapStringInt2)
}
```

The output for this code is:

```bash
[10]
map[hello:10]
```

**You can run the example at** [**https://play.golang.org/p/z4tnyEf6bH**](https://play.golang.org/p/z4tnyEf6bH)**.**

### Making Functions**

Reflection doesn’t just let you make new places to store data. You can use reflection to make new functions using the reflect.MakeFunc function. This function expects the reflect.Type for the function that we want to make and a closure whose input parameters are of type []reflect.Value and whose output parameters are also of type []reflect.Value. Here’s a quick example, which creates a timing wrapper for any function that’s passed into it:

```go
func MakeTimedFunction(f interface{}) interface{} {
	rf := reflect.TypeOf(f)
	if rf.Kind() != reflect.Func {
		panic("expects a function")
	}
	vf := reflect.ValueOf(f)
	wrapperF := reflect.MakeFunc(rf, func(in []reflect.Value) []reflect.Value {
		start := time.Now()
		out := vf.Call(in)
		end := time.Now()
		fmt.Printf("calling %s took %v\n", runtime.FuncForPC(vf.Pointer()).Name(), end.Sub(start))
		return out
	})
	return wrapperF.Interface()
}

func timeMe() {
	fmt.Println("starting")
	time.Sleep(1 * time.Second)
	fmt.Println("ending")
}

func timeMeToo(a int) int {
	fmt.Println("starting")
	time.Sleep(time.Duration(a) * time.Second)
	result := a * 2
	fmt.Println("ending")
	return result
}

func main() {
	timed := MakeTimedFunction(timeMe).(func())
	timed()
	timedToo := MakeTimedFunction(timeMeToo).(func(int) int)
	fmt.Println(timedToo(2))
}
```

You can run the code here <https://play.golang.org/p/QZ8ttFZzGx> and see the output:

```bash
starting
ending
calling main.timeMe took 1s
starting
ending
calling main.timeMeToo took 2s
4
```

### **I Want a New Struct**

There’s one more thing that you can make using reflection in Go. You can make brand-new structs at runtime by passing a slice of reflect.StructField instances to the reflect.StructOf function. This one is a bit weird; we are making a new type, but we don’t have a name for it, so you can’t really turn it back into a “normal” variable. You can create a new instance and use `Interface() `to put the value into a variable of type interface{}, but if you want to set any values on it, you need to use reflection.

```go
func MakeStruct(vals ...interface{}) interface{} {
	var sfs []reflect.StructField
	for k, v := range vals {
		t := reflect.TypeOf(v)
		sf := reflect.StructField{
			Name: fmt.Sprintf("F%d", (k + 1)),
			Type: t,
		}
		sfs = append(sfs, sf)
	}
	st := reflect.StructOf(sfs)
	so := reflect.New(st)
	return so.Interface()
}

func main() {
	s := MakeStruct(0, "", []int{})
	// this returned a pointer to a struct with 3 fields:
	// an int, a string, and a slice of ints
	// but you can’t actually use any of these fields
	// directly in the code; you have to reflect them
	sr := reflect.ValueOf(s)

	// getting and setting the int field
	fmt.Println(sr.Elem().Field(0).Interface())
	sr.Elem().Field(0).SetInt(20)
	fmt.Println(sr.Elem().Field(0).Interface())

	// getting and setting the string field
	fmt.Println(sr.Elem().Field(1).Interface())
	sr.Elem().Field(1).SetString("reflect me")
	fmt.Println(sr.Elem().Field(1).Interface())

	// getting and setting the []int field
	fmt.Println(sr.Elem().Field(2).Interface())
	v := []int{1, 2, 3}
	rv := reflect.ValueOf(v)
	sr.Elem().Field(2).Set(rv)
	fmt.Println(sr.Elem().Field(2).Interface())
}
```

Running this code returns:

```bash
0
20

reflect me
[]
[1 2 3]
```

**The code for this is at** [**https://play.golang.org/p/lJiTP6vYYN**](https://play.golang.org/p/lJiTP6vYYN)

### **What Can’t You Do?**

There’s one big limitation on reflection. While you can use reflection to create new *functions*, there’s no way to create new *methods* at runtime. This means you cannot use reflection to implement an interface at runtime. It also means that using reflection to make a new struct can break in strange ways. When you create a new struct out of a slice of struct fields, there are some problematic interactions with one of the my favorite features in Go — delegation via anonymous struct fields.

Here’s a quick review of delegation. Most of the time, when you have a field in a struct, you give it a name. In this example, we have two types, Foo and Bar:

```go
type Foo struct {
	A int
}

func (f Foo) Double() int {
	return f.A * 2
}

type Bar struct {
	Foo
	B int
}

type Doubler interface {
	Double() int
}

func DoDouble(d Doubler) {
	fmt.Println(d.Double())
}

func main() {
	f := Foo{10}
	b := Bar{Foo: f, B: 20}
	DoDouble(f) // passed in an instance of Foo; it meets the interface, so no surprise here
	DoDouble(b) // passed in an instance of Bar; it works!
}
```

If you run this code at <https://play.golang.org/p/aeroNQ7bEI>, you’ll see two things. First, the Foo field in Bar doesn’t have a name. That makes it an anonymous or embedded field. Second, Bar is treated as though it meets the Doubler interface, even though the Double method was only implemented by Foo. This ability is called delegation; at compile time, Go automatically generates methods on Bar that match the methods on Foo. This isn’t inheritance; if you try to pass a Bar into a function that expects a Foo, your code will not compile.

However, if you use reflection to build a struct with embedded fields and you try to access the methods on those fields, you can get some very odd behavior. The best thing to d o is to stay away from using them. There’s an issue in the Go GitHub repository to fix this <https://github.com/golang/go/issues/15924>, and another one asking for the general ability to define a new type with a set of methods <https://github.com/golang/go/issues/16522>. Unfortunately, there hasn’t been any progress on either issue for a while.

So what’s the big deal? What could we do if we could implement interfaces dynamically? Well, just like we were able to generate a wrapper for a function by taking advantage of Go’s support for generating functions, we could do the same for an interface. In Java, this functionality is called a *dynamic proxy*. When combined with annotations, it gives a powerful way to move from an imperative programming style to a declarative one. One great example is [JDBI](http://jdbi.org/). It’s a Java library that lets you build a DAO layer by defining an interface that’s annotated with SQL queries. All of the boilerplate code that’s normally written to support database interactions is generated at runtime, dynamically. That’s powerful.

### **That’s Great, But What’s the Point?**

But even with this limitation, reflection is still a powerful tool that every Go developer should have in their toolbox. But what can they use it for? In the next blog post, I’ll explore some uses of reflection in existing libraries, and build something new using reflection.

*DISCLOSURE STATEMENT: These opinions are those of the author. Unless noted otherwise in this post, Capital One is not affiliated with, nor is it endorsed by, any of the companies mentioned. All trademarks and other intellectual property used or displayed are th ownership of their respective owners. This article is © 2017 Capital One.*

