go string和c string是有区别的：

- c string使用`'\0'`作为字符串结尾：

  ```c
  char *s = “hello\0world";
  printf("%s\n", s);
  ```

  只会打印出hello，world是打不出来的，c以\0作为字符串的结束标识。

- go string只是将`'\0'`当做普通的不可点字符，而不是字符串结尾：

  ```go
  b := []byte{'h','e','l','l','o','\000','w','o','r','l','d'}
  println(string(b))
  idx := bytes.IndexByte(b, '\000')
  println(idx)
  ```

  会打印出helloworld，而非hello！

  go string的定义可以参考StringHeader结构体的定义：

  ```go
  type StringHeader struct {
  data unsafe.Pointer
  len int
  cap int
  }
  ```




另外要注意，golang里面将\0当做是一个八进制数值的开始标识，不管是在字符串中，还是再byte中，如果定义一个字符串`s := “hello\0world”`会报错：non-octal character in escape sequence，因为\0wo不是一个有效的八进制数值。

\0结尾是c spec规定的，go不认，go里面就是StringHeader {data, cap, len}，go里面不可见字符就是不可见字符，没赋予它截断字符串的特殊含义，这么想，感觉go比c设计的要好一点。

