In the Go programming language, data types refer to an extensive system used for declaring variables or functions of different types. The type of a variable determines how much space it occupies in storage and how the bit pattern stored is interpreted.

The types in Go can be classified as follows −

|   No. | Types and Descriptions |
|:---------:|:---------------------------|
| 1 |**Boolean types**<br>They are boolean types and consists of the two predefined constants: (a) true (b) false|
| 2 |**Numeric types**<br>They are again arithmetic types and they represents a) integer types or b) floating point values throughout the program.|
| 3 |**String types**<br>A string type represents the set of string values. Its value is a sequence of bytes. Strings are immutable types that is once created, it is not possible to change the contents of a string. The predeclared string type is string.|
| 4 |**Derived types**<br>They include (a) Pointer types, (b) Array types, (c) Structure types, (d) Union types and (e) Function types f) Slice types g) Interface types h) Map types i) Channel Types|

Array types and structure types are collectively referred to as aggregate types. The type of a function specifies the set of all functions with the same parameter and result types. We will discuss the basic types in the following section, whereas other types will be covered in the upcoming chapters.

# Integer Types

The predefined architecture-independent integer types are −

| No. | Types and Descriptions |
|:----:|:----------------------------|
| 1	|**uint8**<br>Unsigned 8-bit integers (0 to 255)|
| 2	|**uint16**<br>Unsigned 16-bit integers (0 to 65535)|
| 3	|**uint32**<br>Unsigned 32-bit integers (0 to 4294967295)|
| 4	|**uint64**<br>Unsigned 64-bit integers (0 to 18446744073709551615)|
| 5	|**int8**<br>Signed 8-bit integers (-128 to 127)|
| 6	|**int16**Signed 16-bit integers (-32768 to 32767)|
| 7	|**int32**Signed 32-bit integers (-2147483648 to 2147483647)|
| 8	|**int64**Signed 64-bit integers (-9223372036854775808 to 9223372036854775807)|

# Floating Types

The predefined architecture-independent float types are −

| No. | Types and Descriptions |
|:----:|:----------------------------|
| 1	|**float32**<br>IEEE-754 32-bit floating-point numbers|
| 2	|**float64**<br>IEEE-754 64-bit floating-point numbers|
| 3	|**complex64**<br>Complex numbers with float32 real and imaginary parts|
| 4	|**complex128**<br>Complex numbers with float64 real and imaginary parts|

The value of an n-bit integer is n bits and is represented using two's complement arithmetic operations.

# Other Numeric Types

There is also a set of numeric types with implementation-specific sizes −

| No. | Types and Descriptions |
|:----:|:----------------------------|
| 1	|**byte**<br>same as uint8|
| 2	|**rune**<br>same as int32|
| 3	|**uint**<br>32 or 64 bits|
| 4	|**int**<br>same size as uint|
| 5	|**uintptr**<br>an unsigned integer to store the uninterpreted bits of a pointer value|


