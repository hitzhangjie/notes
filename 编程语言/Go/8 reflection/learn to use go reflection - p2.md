# Learning to Use Go Reflection — Part 2

[![Go to the profile of Jon Bodner](assets/go-reflect-author.jpeg)](https://medium.com/@jon_43067?source=post_header_lockup)

[Jon Bodner Jan 4, 2018

In [my last blog post,](https://medium.com/capital-one-developers/learning-to-use-go-reflection-822a0aed74b7) we looked at Go’s reflection package and went through some quick demonstrations of the features it enables. What wasn’t clear is when these features would be useful. Everything we did with reflection could have been implemented without it — and it would have been more efficient and less verbose. But we also know that the Go team doesn’t like to include features for their own sake. So, what are the things that reflection enables?

### Finding My Reflection

OK, so we can do all of these neat tricks with reflection, but how can I use them in my everyday programs?

Well, for the most part, you won’t. Reflection is a tool that’s used behind the scenes to make normally impossible things possible. It’s hiding in the implementation of some, if not most, libraries and tools.

How can you tell if a library is using reflection? The biggest hint is checking the types of the parameters. If you call a function with a parameter of type interface{}, there’s a good chance it’s going to use reflection to examine or change the parameter’s value.

### Handling JSON

The most common use of reflection is marshaling and unmarshaling data from a file or a network. Whenever you specify struct tags for JSON or database mapping, you are depending on reflection. You are calling a library that’s populating a struct instance, using reflection to both analyze struct tags and set values on a struct’s fields.

Let’s see how this is done by looking at the code inside of the Go standard library that implements JSON unmarshaling.

In order to put the values in a JSON string into a variable, we call the json.Unmarshal function. It takes in two parameters.

- The one that has the JSON text is of type []byte.
- The one with the variable that we want to populate is of type interface{}.

There’s our hint that reflection is going to happen.

If you dive through the code you get to a package-private method called unmarshal. The relevant part looks like this:

```go
func (d *decodeState) unmarshal(v interface{}) (err error) {
  <skip over some setup>
  rv := reflect.ValueOf(v)
  if rv.Kind() != reflect.Ptr || rv.IsNil() {
    return &InvalidUnmarshalError{reflect.TypeOf(v)}
  }
  d.scan.reset()
  // We decode rv not rv.Elem because the Unmarshaler interface
  // test must be applied at the top level of the value.
  d.value(rv)
  return d.savedError
}
```

It’s using reflection to validate that v is the correct kind of variable, a pointer. If it is, the reflected version of v, called rv, is passed to the value method.

After bouncing through a few more functions and methods, we use reflection to populate rv in different ways depending on whether the JSON represents an array, object, or literal. For example, when parsing a JSON object, the standard library uses reflection in many ways.

Reflection is used to test if it’s populating into a nil interface{}:

```go
// Decoding into nil interface? Switch to non-reflect code.
if v.Kind() == reflect.Interface && v.NumMethod() == 0 {
	v.Set(reflect.ValueOf(d.objectInterface()))
	return
}
```

Or if it’s populating into a map:

```go
switch v.Kind() {
	case reflect.Map:
	// Map key must either have string kind, have an integer kind,
	// or be an encoding.TextUnmarshaler.
	t := v.Type()
	switch t.Key().Kind() {
		case reflect.String,
			reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64,
			reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64, reflect.Uintptr:
 		default:
 			if !reflect.PtrTo(t.Key()).Implements(textUnmarshalerType) {
 				d.saveError(&UnmarshalTypeError{Value: "object", Type: v.Type(), Offset: int64(d.off)})
 				d.off --
 				d.next() // skip over { } in input
 				return
 			}
 	}
 	if v.IsNil() {
 		v.Set(reflect.MakeMap(t))
 	}
 	case reflect.Struct:
 		// ok
 	default:
 		d.saveError(&UnmarshalTypeError{Value: "object", Type: v.Type(), Offset: int64(d.off)})
		d.off --
 		d.next() // skip over { } in input
 		return
}
```

And reflection is used when populating the fields in the struct:

```go
subv = v
destring = f.quoted
for _, i := range f.index {
	if subv.Kind() == reflect.Ptr {
		if subv.IsNil() {
			subv.Set(reflect.New(subv.Type().Elem()))
		}
		subv = subv.Elem()
	}
	subv = subv.Field(i)
}
```

This is just a small sampling of the reflection code used to decode JSON. If you want to look through this code yourself, you can find it in the Go standard library at: <https://golang.org/src/encoding/json/decode.go>

### Memoization and Short Term Memory

Populating data structures is one use case for reflection. But what about others? Let’s try building our own library that uses reflection to implement a short-term cache using *memoization*.

If you aren’t familiar with the term, memoization is a technique from the world of functional programming. Functional programming languages tend to impose certain rules. For example, parameters and variables are often *immutable*; they cannot be changed after they are constructed. Functional programming languages also try to limit *side effects*. That’s the name given to things that are done by a function but which aren’t visible in the values returned from the function.

It’s impossible to have a useful program without side effects — as they include things like printing to a screen or writing to a file or putting data in a database — but some side effects, like modifying a global variable, produce programs that are hard to follow. One of the goals of functional programming is to make it easier to follow the flow of data through a program, which in turn makes it easier to understand what the program is actually doing.

There are some other benefits to this style of programming. When you have a function whose input parameters and return values are immutable and the function has no side effects, you can see that every call to this function with the same values will do the exact same work and return the exact same results. If you save off those results, there’s no need to do the work more than once.

And that brings us to memoization. It’s a lot like caching at a function level. Memoization is the process of creating a function that wraps one of these invariant functions, caching the input and output values to avoid doing unneeded work. When a function is memoized, that work is only done once per set of input values. If the same input values are passed in a second time, the return values are pulled from the cache rather than recomputed. For functions that do complex or slow things, the performance savings can be tremendous.

Now, Go may not be a functional language, but we can still apply some of these ideas. This style of programming is a bit restrictive, but avoiding modifications to your input and output parameters and minimizing side effects makes your programs easier to understand and maintain.

Rather than caching forever, let’s look at caching for a short time. This is a pretty common pattern in microservice architectures. Here’s the situation where it’s useful:

> **You have one service that provides a value, and another that uses that value. Because there’s a network call to get the value, it takes some time. This can really slow down the performance of the overall system. When the value doesn’t change all that often, and it doesn’t matter if the value is out of date by a few seconds, caching that value temporarily can give your system a significant performance gain. It’ll be nice if we could avoid extra network calls and implement the caching without lots of changes to the API.**

So how can we implement our memoization-based cache in Go? We’re going to use reflection to do three things:

- Make sure that the input type is a function with at least one input parameter and one output parameter.
- Make a brand-new struct whose fields are the same types as the input parameters for the passed-in function.
- Make a brand-new function whose input parameters and output parameters match the passed-in function.

We are also going to introduce another limitation: the input parameters must all be *comparable*. In Go, a comparable type is one that can be compared with ==. We’re going to use a map to associate our input values with our output values and one of the rule in Go is that the keys for a map must be comparable. This makes sense. In order to tell if we have seen the input parameters before, we need to be able to check them for equality.

Luckily, in Go, there are only four things that are not comparable:

- Slices
- Maps
- Functions
- Structs that contain fields of type slice, map, or function

Let’s start with a definition of our Cacher function. It looks like this:

```go
// Takes in a function and a time.Duration and returns a caching version of the function
// The limitations on memoization are:
// — there must be at least one in parameter
// — there must be at least one out parameter
// — the in parameters must be comparable. That means they cannot be of kind slice, map, or func,
// nor can input parameters be structs that contain (at any level) slices, maps, or funcs.
// Be aware that if your memoized function has any side-effects (does anything that isn’t
// reflected in the output, like print to the screen or write to a database) the side-effects
// will be performed by the function only the first time that the function is invoked with
// particular set of values.
func Cacher(f interface{}, expiration time.Duration) (interface{}, error) {
	return f, nil
}
```

This isn’t doing very much, but at least we know what we’re going to build. Let’s start by filling in the reflection checks to make sure that we have a function passed in to us.

```go
func Cacher(f interface{}, expiration time.Duration) (interface{}, error) {
	ft := reflect.TypeOf(f)
	if ft.Kind() != reflect.Func {
		return nil, errors.New("Only for functions")
	}
	return f, nil
}
```

Now, we need to build the struct that we will use to hold our input parameters. While building this struct, we will also make sure that we have at least one input parameter, one output parameter, and all of the input parameters are comparable.

```go
func buildInStruct(ft reflect.Type) (reflect.Type, error) {
	if ft.NumIn() == 0 {
		return nil, errors.New("Must have at least one param")
	}
	var sf []reflect.StructField
	for i := 0; i < ft.NumIn(); i++ {
		ct := ft.In(i)
		if !ct.Comparable() {
			return nil, fmt.Errorf("parameter %d of type %s and kind %v is not comparable", i+1, ct.Name(), ct.Kind())
		}
		sf = append(sf, reflect.StructField{
			Name: fmt.Sprintf("F%d", i),
			Type: ct,
		})
	}
	s := reflect.StructOf(sf)
	return s, nil
}

func Cacher(f interface{}, expiration time.Duration) (interface{}, error) {
	ft := reflect.TypeOf(f)
	if ft.Kind() != reflect.Func {
		return nil, errors.New("Only for functions")
	}

	inType, err := buildInStruct(ft)
	if err != nil {
		return nil, err
	}

	if ft.NumOut() == 0 {
		return nil, errors.New("Must have at least one returned value")
	}

	fmt.Println("inType looks like", inType)
	return f, nil
}
```

There’s just one step left, declaring the map that we’ll use to hold our cache of input and output values, and using reflection to generate our caching function:

```go
type outExp struct {
	out    []reflect.Value
	expiry time.Time
}

func Cacher(f interface{}, expiration time.Duration) (interface{}, error) {
	ft := reflect.TypeOf(f)
	if ft.Kind() != reflect.Func {
		return nil, errors.New("Only for functions")
	}

	inType, err := buildInStruct(ft)
	if err != nil {
		return nil, err
	}

	if ft.NumOut() == 0 {
		return nil, errors.New("Must have at least one returned value")
	}

	m := map[interface{}]outExp{}
	fv := reflect.ValueOf(f)
	cacher := reflect.MakeFunc(ft, func(args []reflect.Value) []reflect.Value {
		iv := reflect.New(inType).Elem()
		for k, v := range args {
			iv.Field(k).Set(v)
		}
		ivv := iv.Interface()
		ov, ok := m[ivv]
		now := time.Now()
		if !ok || ov.expiry.Before(now) {
			ov.out = fv.Call(args)
			ov.expiry = now.Add(expiration)
			m[ivv] = ov
		}
		return ov.out
	})
	return cacher.Interface(), nil
}
```

And that’s it!

Let’s walk through this code. We first define a type outExp to hold both the output values and the time when our cached value should expire.

We then declare a map m, where the key is interface{} and the value is outExp. These types are chosen for practical reasons. As we saw in our earlier example of using reflection to build structs, we don’t have a type name that we can use to represent a reflection-generated struct. In order to store an instance of it, we have to use a variable of type interface{}. As for the return types, when you use reflection to invoke a function, the return type is []reflect.Value. This is also the value that’s returned from the closure that’s passed into reflect.MakeFunc. In order to avoid copying values, we just hang on to the []reflect.Value that we get back from a reflected function invocation and store that in our map.

In our closure, we use reflection to construct a new instance of our custom type, and populate the fields of it with the values that are passed in to our function at runtime. We then check to see if there is already something equal to that instance in m. If it’s not there, or if it is there and it is already expired, we Call the wrapped function and store the response and the expiration time in ov and store it in m with the instance of the custom struct as the key. We then return the values stored in ov.out for the input values.

And that’s it, we have written a Cacher factory function that wraps nearly any function in Go in a time-limited cache.

So, how do we use this code? Here’s a quick example:

```go
func AddSlowly(a, b int) int {
	time.Sleep(100 * time.Millisecond)
	return a + b
}

func main() {
	ch, err := Cacher(AddSlowly, 2*time.Second)
	if err != nil {
		panic(err)
	}
	chAddSlowly := ch.(func(int, int) int)
	for i := 0; i < 5; i++ {
		start := time.Now()
		result := chAddSlowly(1, 2)
		end := time.Now()
		fmt.Println("got result", result, "in", end.Sub(start))
	}
	time.Sleep(3 * time.Second)
	start := time.Now()
	result := chAddSlowly(1, 2)
	end := time.Now()
	fmt.Println("got result", result, "in", end.Sub(start))
}
```

While a real example would make a database lookup or a web service call, our sample function simply sleeps for 100ms and then adds two numbers together. Since Go doesn’t have generics, we are going to need to cast our cached function back to the proper type. And because we are also checking for errors, this requires a couple of lines of code to put the error and the interface{} representation of the caching function into variables, and then cast the cache instance into its correct type.

If we run this code, we’ll see numbers like this:

```bash
$ go run cacher.go
got result 3 in 100.079405ms
got result 3 in 3.873µs
got result 3 in 561ns
got result 3 in 462ns
got result 3 in 398ns
got result 3 in 100.054602ms
```

The first time we run it, it takes 100 ms (plus some overhead), subsequent calls within the same 2 second window take a few hundred nanoseconds. The final call, after a 3 second pause, takes the 100ms again.

You can look at this code in the Go Playground at <https://play.golang.org/p/GNXG4CpG-E>

### Your New Secret Weapon

There is one last thing to be aware of. Using reflection has a very real performance impact. If you are doing a very intensive mathematical calculation or talking to an external service over the network, adding a layer of code that’s using reflection is not going to result in a significant impact. However, most code is pretty fast. It’s very likely that most methods in your code will take a lot less than a few hundred nanoseconds to run. In those cases, you need to be careful when you enhance your code with reflection and generated functions. There will be a performance penalty and you’ll have to decide if the added functionality is worth the slower performance and more complicated code.

This should give you a taste of the kinds of problems that can be solved with reflection in Go. It’s not a solution that you reach for all of the time, but when you have a problem that seems impossible because there’s no commonality between types, or because the data is dynamic, reflection is your secret weapon.

**DISCLOSURE STATEMENT: These opinions are those of the author. Unless noted otherwise in this post, Capital One is not affiliated with, nor is it endorsed by, any of the companies mentioned. All trademarks and other intellectual property used or displayed are th ownership of their respective owners. This article is © 2017 Capital One.**