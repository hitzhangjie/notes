# Strings

- String datatype in Go

  > "string类型定义，其内部包括起始byte指针以及bytes数量len。
  > type _string struct { 	
  >  	elements *byte // underlying bytes 	
  >  	len      int   // number of bytes 
  > }"

- String features in Go

  > "string类型的特点：
  > 1）string可被用作常量；
  > 2）go支持双引号和反引号括起来的两种形式的字符串，前者可以带转义字符，后者表示的字符串是所见即所得，不存在转义；
  > 3）string的零值是空串；
  > 4）可以通过+或者+=进行字符串连接；
  > 5）可以通过==或者!=进行比较，也可以通过&gt;,&lt;,&gt;=或&lt;=进行大小比较；"

- More facts about string types and values in Go

  > "string的其他特性：
  > 1）像java中的string一样，string一旦创建就是不可变的，包括内部的elements和len都是不可以单独修改的，只能通过赋值操作来修改；
  > 2）string类型没有实现方法，但是可以通过strings这个package来对其进行操作；string中的elements是不可寻址的，也不能对内部元素element[i]进行寻址，更无法修改；aString[i:j]可以用于创建一个子字符串；
  > 3）标准的gc，字符串赋值操作后，src、dest string将共享相同的内部存储。"

- Each string is actually a byte sequence wrapper. So each rune in a string will be stored as one or more bytes (up to four bytes). For example, each English code point stores as one byte in Go strings, however each Chinese code point stores as three bytes in Go strings.  [go101.org]

  > "golang里面string实际上是封装了一个byte序列，string是utf-8编码的，每个utf8码点用rune表示（int32类型），一个rune占据一个或者多个byte。例如每个英文字符占据一个byte，每个中文字符占据3个byte。"

- Here introduces two more string related conversions rules in Go: a string value can be explicitly converted to a byte slice, and vice versa. A byte slice is a slice whose underlying type is []byte (a.k.a, []uint8). a string value can be explicitly converted to a rune slice, and vice versa. A rune slice is a slice whose underlying type is []rune (a.k.a, []int32).   [go101.org]

  > "string可以转换为[]byte、[]rune，反之也可以，如果要将一个[]byte转换成[]rune，需要借助string做中转。"

- Deep copy happens when a string is converted to a byte slice, or vice vesa

  > "注意，将string转换为[]byte时，实际上是深拷贝了string的elements中的byte序列；将[]byte转换为string时，也是深拷贝了一份[]byte到string的elements。深拷贝需要开辟新的内存空间，为什么要深拷贝呢？因为slice中的元素是可变的，但是string中的字符要求是不可变的，所以为了使用过程中不互相影响，只能新开辟一块新的内存来深拷贝。"

- Please note, for conversions between strings and byte slices, illegal UTF-8 encoded bytes are allowed and will keep unchanged. the standard Go compiler makes some optimiazations for some special cases of such conversions, so that the deep copies are not made. Such optimiazations will be introduced below.   [go101.org]

  > "注意string和[]byte之间的转换，非法的utf8编码bytes是允许的，转换过程中会保持不变；标准的恶go编译器会在上述转换发生时采取某些优化措施避免发生深拷贝（只是在某些特定情境下）。"

- How to convert between byte slices and rune slices

  > "[]byte和[]rune之间的相互转换不能通过显示类型转换来完成，可以通过三种方式完成：
  > 1）借助string作为转换媒介来完成；
  > 2）使用unicode/utf8这个package下的工具函数DecodeRune来完成；
  > 3）使用bytes包下的Runes函数将[]byte转换成[]rune。其中第一种方式使用比较简单但是不够高效，涉及到内存深拷贝，后面两种用起来啰嗦，但是比较高效。这里是一个操作示例：

  ```
  s := "大家好,hello world"  	
  bs := []byte(s) 	
  fmt.Println(bs)  	
  rs := []rune(s) 	
  fmt.Println(rs)  	
  // 通过unicode/utf8下工具函数转换 	
  for idx := 0; idx &lt; len(bs); { 		
     r, w := utf8.DecodeRune(bs[idx:]) 	
     fmt.Printf("%v ", r) 		
        idx += w 	
  } 	
  fmt.Println()  	
  // 直接使用bytes包下Runes函数完成转换 
    fmt.Println(bytes.Runes(bs))
  ```

- Compiler Optimizations For Conversions Between Strings And Byte Slices

  > go v1.10会在如下场景下string和[]byte之间转换时做优化，避免转换过程中发生深拷贝:
  > 1) a conversion (from string to byte slice) which follows the range keyword in a for-range loop.
  > 2) a conversion (from byte slice to string) which is used as a map key. a conversion (from byte slice to string) which is used in a comparison.
  > 3) a conversion (from byte slice to string) which is used in a string concatenation, and at least one of concatenated string values is a non-blank string constant.

- The for-range loop control flow applies to strings. But please note, for-range will iterate the Unicode code points (as rune values), instead of bytes, in a string. Bad UTF-8 encoding representations in the string will be interpreted as rune value 0xFFFD.  [go101.org]

  > "for-range遍历string时，for idx, c := range aString {...}，遍历时是按照utf8码点进行遍历的，其中的idx表示的是第几个byte，遍历过程中输出的idx不是连续的，因为utf8码点占据可能多个byte，c是对应的rune码点，通过string(c)将其当做字符串输出。"

- How to iterate bytes in a string?

  > for-range遍历string时是按照rune进行遍历的，那么如何按照byte进行遍历呢？因为len(aString)返回的aString中的byte的数量，因此可以借助一般形式的for循环for i:=0; i&lt;len(aString); i++ {...}，这样来按照byte进行遍历。

- How to concatenate strings?

  > string的连接操作，除了使用+之外，也可以使用fmt.Sprintf、strings.Join、bytes.Buffer、strings.Builder等来完成。strings.Builder相比于其他三种方式效率更高，因为它尽可能避免了存储result string时内置bytes数组的拷贝。

- Syntax Sugar: use string as byte slice

  > "这里有个语法糖，正常使用方式append(hello, []byte(world)...)，但是语法糖形式更精炼append(hello, world...)。"

- More about string comparisons

  > "字符串比较是比较内置数组中的byte序列是否完全相同，但是实际比较时，会采取其他优化措施，例如：如果两个字符串长度不同，那么肯定不同，没必要逐一比较内置bytes数组中的byte；再者，如果两个字符串指向的内置数组指针elements相同，那么说明其引用的也必然是同一个字符串（字符串只有赋值操作时才可以更新elements、len字段）。"