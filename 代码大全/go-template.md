模板是现在开发中经常使用的一种技术，如Web界面经常采用模板技术来构建页面展示，配合模板解析引擎来将数据和模板融合在一起展示。在自动化代码生成等场景下也有很重要的用途，比如之前我们通过c、c++以及ctemplate模板来自动化生成spp服务工程，java也有类似的velocity等模板引擎技术，golang与它们不同，golang中内置了模板技术。

下面是一个演示如何使用golang模板技术的示例：

```go
package main

import (
	"fmt"
	"os"
	"text/template"
)

func main() {
	testTemplate()
}

// tpl_def中{{.Grade | studentLevel}}：
// 其中符号|表示管道，在这里其含义是将book.Students[i].Grade作为参数传递给函数studentLevel(arg)
func studentLevel(grade int) string {
	switch {
	case grade > 90:
		return "A"
	case grade > 80:
		return "B"
	case grade > 70:
		return "C"
	case grade > 60:
		return "D"
	default:
		return "E"
	}
}

func testTemplate() {

	tpl_def := `
	{{.Count}} students:
	{{range .Students}}
	-------------------
	Name: {{.Name}}
	Age : {{.Age}}
	Grade: {{.Grade}}
	Level: {{.Grade | studentLevel}}
	{{end}}
	`

	tpl, err := template.New("students-summary").Funcs(template.FuncMap{"studentLevel": studentLevel}).Parse(tpl_def)
	if err != nil {
		fmt.Printf("create template error, error = %v\n", err)
		os.Exit(1)
	}

	type Student struct {
		Name  string
		Age   int
		Grade int
	}

	// tpl_def: .Count是book.Count
	//          range .Students实际是range book.Students
	// {{range}} ... {{end}}构建了一个for val,idx := range book.Students {}, 其中{{.Name}}访问的则是val.Name
	type Students struct {
		Count    int
		Students []Student
	}

	book := Students{}
	book.Students = append(book.Students, Student{"zhang", 10, 99})
	book.Students = append(book.Students, Student{"wang", 10, 80})
	book.Students = append(book.Students, Student{"li", 10, 70})
	book.Count = len(book.Students)

	tpl.Execute(os.Stdout, book)
}
```

程序执行时，输出如下：

```shell
3 students:
-------------------
Name: zhang
Age : 10
Grade: 99
Level: A
-------------------
Name: wang
Age : 10
Grade: 80
Level: C
-------------------
Name: li
Age : 10
Grade: 70
Level: D
```

