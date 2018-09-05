# Structs

- Consecutive fields with the same type can be declared together. struct { 	title, author string 	pages         int }  [go101.org]

  > "定义struct时，连续的字段如果类型相同，可以在同一行进行定义。"

- The size of a struct type is the sum of the sizes of all its field types. The size of a zero-field struct type is zero.  [go101.org]

  > "struct定义中如何没有包含任何field，这么这个struct实例的大小为0，unsafe.Sizeof返回0。unsafe.Sizeof注释提到这个函数不返回这个参数结构体中引用的其他内存空间，对于一个空的struct来说，很可能其内部表示是空的。"

- Each struct field can be bound with a tag when it is declared. Field tags are optional, the default value of each field tag is a blank string. Here is an example showing non-default field tags. struct { 	Title  string `json:"title"` 	Author string `json:"author,omitempty"` 	Pages  int    `json:"pages,omitempty"` }  [go101.org]

  > "struct中每个field可以为其指定tag，注释最好不要讲tag当做字段的注释来使用。tag默认为空串。在使用encoding/json进行marshal、unmarshal的时候这个tag是很有用的，比如字段名为大写的Title，如果指定了tag `json:"title"`，那么编码成json时字段名就是title，否则就与字段名相同；解码json的时候，如果有tag，就会假定json中字段名是title而非Title。"

- Given a struct type S and assume it has two fields, x int and y bool in order, then the zero value of S can be represented by the following two variants of struct composite literal forms: S{0, false}. In this form, none field names are present but all field values must be present by the field declaration orders. S{x: 0, y: false}, S{y: false, x: 0}, S{x: 0}, S{y: false} and S{}. In this form, each field item is optional to be present. The values of the absent fields will be set as the zero values of their respective types. But if a field item is present, it must be presented with the FieldName: FieldValue form. The order of the field items in this form doesn't matter. The zero value form S{} is used most often in practice.   If S is a struct type imported from library packages, it is recommended to use the second form, for the library maiatainers may add fields for the type S later, which will make the uses of first forms become invalid.  [go101.org]

  > "结构体初始化的方式有两种：
  > 1）不指定字段名，但是需要按照结构体中字段定义顺序依次、全部提供字段的初始值 
  > 2）指定字段名，可以只提供某几个字段的初始值。
  > 如果引用的struct类型是从其他package import进来的，最好使用第二种初始化方式，因为packge的维护人员可能会在原有代码的基础上扩充struct的字段，万一调整了字段顺序，或者是在原有字段之间插入其他字段，使用第一种初始化方式的话势必会引入bug。"

- The last , in a compoiste literal is optional if the last item in the literal and the closing } are at the same line. Otherwise, the last , is required. (For more details, please read line break rules in Go.)  var _ = Book { 	author: "Go 101", 	pages: 256, 	title: "Go 101", // here, the "," can not be ommitted. }  // The last "," in the following line can be ommitted. var _ = Book{author: "Go 101", pages: 256, title: "Go 101",}  [go101.org]

  > "struct字段初始化的时候，为了可读性，有时会一行只初始化一个字段，每个字段后都需要加一个逗号。这里要注意的是golang里面的breakline rules，因为不需要程序员自己手动插入分号作为语句的结束，实际上是编译器来做的这个自动插入分号的工作，那么编译器如何判断是否该插入一个换行符呢？规则有好几条，但是我们只要记住什么时候可以换行就可以了，只在二元操作符、成员操作符.、赋值=、左半开括号后换行就不会有breakline问题。"

- Generally, only addressable values can be taken addresses. But there is a syntax sugar in Go, which allows us to take addesses on composite literals. A syntax sugar is an exception in syntax to make programming convenient.  [go101.org]

  > "一般地只有可寻址的value才可以对其进行取地址运算，golang增加了一种语法糖，允许对复合类型字面量进行取地址运算。如type struct Book{}; b := &amp;Book{}。这种对复合类型字面量进行取地址运算的方式，同样适用于对map、slice。"

- Unlike C, in Go, there is not the -> operator for accessing struct fields through struct pointers. In Go, the struct field acceessment operator for struct fields is also the dot sign ..  [go101.org]

  > "golang里面访问struct中的field使用成员操作符"."，而不是-&gt;。golang里面没有-&gt;这个运算符。"

- Struct Value Conversions  [go101.org]

  > "struct结构体类型转换，必须满足对应字段名称相同、类型相同、tag相同。"