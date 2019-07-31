# GoModule学习

## GOPATH与GoModule兼容性

GoModule目前在GO1.11和Go1.12还是一个处于体验的过渡阶段，Go1.13中将作为默认选项，代替GOPATH。

表现在：

- 如果当前工程位于GOPATH路径下，即便工程或者父路径中存在go.mod，启用GOPATH而非GoModule；
- 如果当前工程不在GOPATH路径下，且工程或父路径中存在go.mod，此时启用GoModule；

关于第一点，GO1.13中的表现会有所不同，默认启用GoModule而非GOPATH。

## 创建一个Module

```bash
go mod init git.code.oa.com/hello
```

一般执行 `go test` 的时候，会显示一个临时生成的module名，这个名字是以 "路径名+时间戳+commit版本号” 命名的，但是当像上面这样初始化之后，module名就是 ”git.code.oa.com/hello” 了，如果hello路径下又创建子目录world，那么world对应的module名就是 "git.code.oa.com/hello/world"。

此时会生成两个文件：

- go.mod，第一行是当前模块的名字，后面是依赖的module及其版本信息
- go.sum，依赖的module对应版本的校验和信息

## 添加一个Dependency

写代码的时候，如果import了其他module，那么在import、编译、测试的时候会自动更新go.mod、go.sum。

比如：

```bash
cd hello
go test
```

会自动拉取hello这个module代码中import的其他module，并更新go.mod和go.sum。

## 列出依赖的Dependencies

有时需要查看当前module依赖的所有module及其版本详情：

```bash
go list -m all
```

有时可能想查看某个dependency的所有可用tagged版本，以便更新、废弃某些版本：

```bash
go list -m -versions rsc.io/sampler
```

## 更新一个Dependency

当希望更新一个dependency的时候，可以通过 `go get` 来完成。这里版本构成遵循major.minor.patch这样的格式。

### 更新Dependeny到一个新的Major版本

以更新 “rsc.io/sampler” 为例，假定当前版本是v1，对应 ”import “rsc.io/sampler”，假定有可用版本v3：

```
go list -m -versions rsc.io/sampler
v1.0.0 v2.0.0 v3.0.0
```

更新到v3.0.0，go get会自动更新到最新版本：

```bash
go get rsc.io/sampler
```

更新完后需要 `go test` 一下检测下应用是否能正常构建，假定现在有失败，v1.0.0ok，v3.0.0fail，说不定v2.0.0ok呢？

```bash
go get rsc.io/sampler@v2.0.0
```

假定v2.0.0ok，那么go test将通过，对应的代码中会变成 “import “rsc.io/sampler/v2”，同一个module可能有多个不同的版本，从v2开始，importPath必须以主版本号结束。假如只引用了同一个主版本的话，importName不需要修改，使用的时候直接sampler.XXX即可。

```go
// import版本v2，importName=v2
import "rsc.io/sampler/v2"
```

对主版本划分的一点说明：

- 不同主版本可能有不同的特性，同一个主版本内部的多个副版本、修订版本，功能应该是兼容的；
- 不兼容的特性，应该迁移到不同的主版本中实现、对外发布；

如果同时引用了多个主版本，那么就需要区分一下了，比如：

```go
// import版本v1，importName=sampler
import "rsc.io/sampler"

// import版本v3，importName=samplerV3
import samplerV3 "rsc.io/sampler/v3"
```

### 更新Dependeny到一个新的Minor版本

更新一个副版本的过程，与更新主版本并无二致，如从v2.0.0升级到v2.1.0：

```bash
go get rsc.io/sampler@v2.1.0
```

可能比较省心的是副版本更新，应该很少会出现兼容性问题，但是为了保证我们模块本身的健壮，还是要执行 `go test` 全面测试下，避免因为升级引入bug。

## 包含同一个Dependency的不同版本

前面有引用同一module不同主版本的情况，能否引入同一模块的同一个主版本的不同副版本、修订版本呢？不能！

## 清理不再使用的Dependency或者版本

在升级、替换dependency的过程中，可能在go.mod中引入了很多dependencies，但是有些其实已经不会使用到了，那么为什么 `go build` 和 `go test` 等需要构建的过程中没有及时清理掉这些依赖呢？因为在构建一个package的时候通过import指令可以很容易地判断出要添加什么依赖到go.mod，但是要移除一个依赖却比这个复杂，需要全量扫所有的package才能断定某个依赖是否有被引用到，所以为了提高构建效率，是没有及时从go.mod中清理这些误用依赖的。

这就需要手动清理了，那么如何清理呢？

```bash
go mod tidy
```

## 总结

学习了下GoModule的使用，简单翻译、总结下GoModule使用过程中的一些常用操作。