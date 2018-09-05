# Code Packages And Package Imports

## Package Imports

### 导入路径

- The official Go tools recommend, and often require, the folder containing a third-party package to be put in the src folder under any path specified in the GOPATH environment variable. The import path of the third-party package is the relative path of the package folder to the src folder. The seperators in the path must be always / and can't be \. For example, if the path of a package is OneGoPath/src/a/b/pkg (or OneGoPath\src\a\b\pkg on Windows), then its import path is /a/b/pkg.  [go101.org]

  > go中package的导入路径分隔符只能用符号“/”，不管是在windows、linux还是其他平台下。导入的第三方库中的包，这个库必须放在GOPATH/src下，导入路径是相对于这里的src的。

### 导入形式

- import importname "path/to/package"  [go101.org]

> package导入的完整形式是这样的，importname是可选的，其默认是导入的包的名字。以fmt为例，假如通过import f "fmt"导入fmt，那么fmt.Println就会报错，必须通过f.Println来调用。 有时可能引入了多个同名包，可以借助这种方式避免歧义。

- The importname in the full form import declaration can be blank identifier (_). Such imports are called anonymous imports. The importing source files can't use the exported resources in anonymously imported packages. The purpose of anonymous imports is to initialize the imported packages (each of init functions in the anonymously imported packages will be called once).  [go101.org]  

> "有时导入时importname定义成blank identifier "_"，这种方式是不想在当前包中使用导入包中的导出变量或函数，只是完成导入包的初始化（执行导入包的init函数）。"

- vendor

  - golang里面引入的第三方库一般是放在GOPATH下的，但是有些三方库并不是全局共享库，可能只会被几个工程用到，这样的话，把这个三方库放在GOPATH下就不是特别合适了，那怎么办呢？  把这个三方库放到工程目录下，rewrite导入路径，但是工程里面可能很多个地方都引用了这个包，全部修改一遍也很麻烦。

    > go 1.5开始提供了vendor支持，将项目独享的依赖放到工程下面子目录中的vendor目录下，goimports及其他go tool会自动搜索这个路径，同时，不需要rewrite包导入路径。

  - 我发现个问题，这里的vendor下面的库，要放到引用它的那个package的目录下。

    > 比如工程结构是：

    ```
    src/
        |- pkga
        |- pkgb
    ```

    > 如果要在pkga中引用这个vendor中的包，就需要将vendor文件夹放置到pkga/这个目录下，那么如果pkga和pkgb都需要使用这个vendor中的包怎么办呢？那就放到src目录下！"

## 命名方式

- A standard package has a higher import priority than a third-party package if their import paths are identical. So please try to avoid using the import path of a standard package as the import path of a third-party package.  [go101.org]

> go标准库中的package import时优先级更高，我们自定义的库尽量不要导入路径与标准库中的相同。

- The name of folder containing a package is not required to be the same as the package name. However, for library packages, it will make package users confused if the name of a package is different from the name of the package folder.  [go101.org]

> 自定义的pkg位于某个文件夹下，应该使得文件夹路径名与pkgname完全一致，避免让使用者产生困惑。

## 加载顺序

- Go doesn't support circular dependency. If package a imports package b and package b imports package c, then package c can't import package a and b, package b also can't import package a.  A package also can't import itself.  At run time, packages are loaded by their dependency orders. A package will be loaded before all the packages which import it. Each Go program contains only one program package, which is the last package being loaded at run time.  [go101.org]

  > go package导入的时候不能存在环形依赖，比如package a不能导入自身；a导入b，b导入c，c不能导入a或b等。运行时包根据package的导入声明构建依赖关系，并决定哪些package先加载哪些后加载（main最后加载）。

## 包初始化

- There can be multiple functions named as init declared in one package, even in one source code file. The functions named as init must have no any input parameters and return results.  The init functions in a package will be called once and only once sequentially when the package is loaded. However, the invocation order of these init functions is not specified in Go specification. So there shouldn't be dependency relations between the init functions in one package.  All init functions in all involved packages in a program will be called sequentially. An init function in an importing package will be called after all the init functions declared in the dependency packages of the importing package for sure. All init functions will be called before invoking the main entry function.  For the standard Go compiler, the init functions in a source file will be called from top to down.  [go101.org]

  > 同一个package下面可以定义多个init函数（即使是同一个go文件下），这些init函数必须不接收参数、也不返回值。每个init函数在包加载的时候执行且执行一次，相互之间也没有明确的依赖关系。同一个go文件中往往是从上往下执行。 调用main.main之前所有的包的init函数必须先执行完。

