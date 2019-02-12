# 1 为什么需要Markdown？

MS Office是比较常用的文字编辑软件，但是其复杂的编排格式严重增加了编辑工作量，对于复杂的文档编辑工作还真的需要类似MS Office这样的高级编辑工具，或者LaTeX之类。然而，对于绝大多数编辑场景，用不着这么复杂的编排能力，与其关注文档格式本身，文字内容是大家更关注的内容。

标题、段落、列表、加粗、强调、引用等等格式化标记，可以使得文章内容、层次、阅读更加有条理，这是不可缺少的。既想要这样的格式化能力，又不想类似MS Office、LaTeX这样的复杂格式化操作，有什么方便使用的方法吗？

> MS Office里面为了简化格式化操作，可以通过QuickStyle或者文件Template来实现，但是每当更换电脑、设备之后，需要在不同版本MS Office、电脑、设备上创建对应的QuickStyle或者文件Template配置，还是很麻烦的。

# 2 Markdown的工作原理？

Markdown解决了这个问题，Markdown是一种符号标记语言，实现也很简单，其语法标记最终会被转换成html语法标记，如Markdown语法标记#Hello会被转换成HTML语法标记<h1>Hello</h1>。然后Markdown文档的渲染，就可以借助CSS进行渲染了，如定义HTML h1标题以指定大小、字体、颜色显示。

Markdown文档的渲染，一般分为两种：

- “原地渲染”这种所见即所得的编辑、预览方式是我认为最好的，这类Markdown编辑器包括Typora、MarkText；
- “非原地渲染”这种需要单独开一个窗口来预览，这类Markdown编辑器包括MWeb、Atom、VSCode等等；

“原地渲染”这种方式，对实现的技术要求比较高。“非原地渲染”方式，每当对Markdown文档进行少许修改后，就需要对整个HTML文档进行渲染，渲染效率低下。而“原地渲染”方式，如Typora、MarkText都是采用了VDOM技术只对需要重新渲染的HTML文档的某个部分进行渲染，因此渲染效率就高多了，用户体验也更友好。

# 3 Markdown编辑器推荐？

我个人推荐的首选Markdown编辑器就是Typora，没有之一！目前Typora还处于Beta版本，暂不收费，后续Stable版本发布后会进行收费。Typora，可以说是Markdown编辑器之神！相信我，我体验过了各种各样的Markdown编辑器，甚至我也自己编写过一个Markdown编辑器iWrite（fork自MarkText然后自定义），也编写过Vim集成的Markdown预览插件，也深度体验过比较流行的MWeb、Atom中Markdown插件等等，没有任何一个可以与Typora媲美！所以我推荐Typora！

# 4 用Markdown编写书籍？

如果是打算用Markdown来编写书籍，或者喜欢这种按照书籍形式组织，可以考虑用gitbook！gitbook-cli是gitbook的一个命令行版本，它能够快速初始化一个新的book目录，并在目录下创建对应的目录结构、必备文件等，后续编辑工作就可以按照Markdown的形式来编写，gitbook-cli还支持book的预览、翻页等能力。

我本人整理《go风格协程库libmill》的时候使用了gitbook-cli来组织，个人感觉还是比较方便的，特别是预览的时候！不过目前我希望专项用Typora来管理所有的Markdown编辑工作。如果想体验一下gitbook-cli的朋友，可以参考下这里的[gitbook-cli教程](https://toolchain.gitbook.com/setup.html)，教程中对如何安装、使用、编辑、导出书籍都进行了非常细致的描述。

