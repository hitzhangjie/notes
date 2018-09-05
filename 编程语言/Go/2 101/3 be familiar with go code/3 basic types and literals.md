# Basic Types And Their Value Literals

- Types can be viewed as value templates, and values can be viewed as type instances.  [go101.org]

> "类型是值的模板，值是类型的实例。"

- Go supports following built-in basic types

> "golang中包括了如下17个基本数据类型，1个bool类型，11个整数类型（包括一个特殊的uintptr）、2个浮点类型，2个复数类型，1个字符串类型。  这些类型名虽然都不是首字母大写，不是导出类型，但是可以不用import任何包就可以使用。这是编译层面做的工作，不需关心。  每种类型都有对应的0值，也就是默认值，对于bool类型是false，对于数值类型是0，对于字符串类型是空串。"

- type definition and type alias

> "type B b，这是定义一个新类型B；type C = c，这是定义一个类型的别名C，与类型c完全是同一个类型。这样定义类型会继承方法吗？好像不会。"