# Reflections in Go

- Overview Of Go Reflection  [go101.org]

  > "go 1不支持用户自定义函数上的范型，go reflection为go提供了很多动态能力，这一定程度上弥补了范型缺失的尴尬，但是从cpu占用方面考虑还是没有真正的范型高效。go标准库里fmt、encoding等package都大量使用了反射。  通过reflect.Type和reflect.Value我们可以更深入地看下go value的内部表示。go reflection设计的终极目标之一是，go里面任何非反射方式的操作都可以通过反射来完成，但是现在的实现还不能100%支持，不过大多数非反射操作是可以借助反射方式来完成的，比如创建变量、执行chan-select-case等等。  借助反射可以实现某些非反射操作实现不了的操作，下面会介绍下现在的反射支持不到的操作以及可以支持到的操作。"

- The reflect.Type Type And Values  [go101.org]

  > "reflect.TypeOf(val)，只要val不是接口值类型，该方法就可以返回一个reflect.Type值，该值代表了该val的类型信息。其实该方法入参是interface{}，意味着可以接受任何方法，但是这里除去接口值类型，该方法先将val转换为接口值，然后再提取动态类型信息存储到reflect.Type接口值的动态类型部分。  reflect.Type是个接口类型，通过它的方法集可以查看val的类型信息。"

- The reflect.Value Type And Values  [go101.org]

  > "reflect.ValueOf(val)，该方法通过val返回一个reflect.Value值，其中记录了val的动态类型信息，以及值。通过它提供的方法不仅可以查看类型信息，也可以查看值。  reflect.ValueOf(val)与reflect.TypeOf(val)的区别是，前者返回的是一个Value（包含了类型和值），后者返回的是一个纯粹的类型Type（只包含类型）。"

