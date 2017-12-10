[TOC]

##### 1 切换大小写

切换大小写，不仅可以U/u进行切换，有一种更方便的方式，是通过按键～来进行切换。

举几个使用场景，假如有一个变量名：```int userName = 1;```

- 把变量名全部修改为uppercase，v模式选中变量然后U
- 把变量名全部修改为smallcase，v模式选中变量然后u
- 把变量名大小写反转，v模式选中变量然后~

##### 2 为不同文件类型设定tags搜索路径

```
" 普通文件的话，可以只使用当前文件所在下的tags，或者上级目录中的tags……直到~/tags
set tags=./tags,tags
" 为不同文件类型设置不同tags
" 如果tags路径设置中包含了分号，后面执行+=时会自动追加分号，将新添加路径与旧tags路径分隔
au FileType c setlocal tags+=/path/.../tags
au FileType cpp setlocal tags+=/path/.../tags
```

通过上述方法我为c添加了内核的tags，当然也可以添加cpp stl或者jdk的tags，根据需要设置就可以。

##### 3 tags跳转、搜索

- vim搜索tag的命令“:ts tag或:tselect tag”（需安装etags、cscope）
- vim跳转到声明或者定义，[[
- vim跳转回原来的位置，]]
- vim中跳转到当前位置变量(准确地说是tag)下次出现的位置，*
- vim中跳转到当前位置变量(准确地说是tag)上次出现的额位置，#

##### 4 Markdown preview LaTeX

在Markdown中增加LaTeX数学公式，并实现本地数学公式实时预览，可以通过如下几种方式：
**1) apache中使用mathtex.cgi将数学公式转换为png格式输出**

- 这种方式需要安装各个操作系统上对应版本的TeX发行版，Linux、OSX、Windows上都有对应发行版；
- OSX下对应发行版大约有2.7GB；

**2) apache中使用mimetex.cgi将数学公式转换为gif格式输出**

- mimetex是mathtex的前身，但是公式转换过程中由于采用的算法的问题，转换效果较差；
- mathtex依赖LeX库中的dvipng进行转换，转换效果质量较高；
- mimetex有安全性检查设置，检查referer字段，保证同源策略，建议采用如下编译选项进行编译：
  gcc -DAA -DNOREFCHECK mimetex.c gifsave.c -lm -o mimetex.cgi；



