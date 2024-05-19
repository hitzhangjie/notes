---
layout: post  
title: 前端学习ExtJS6
description: ""
date: 2024-05-19 23:21:29 +0800
categories: ["过去的学习笔记"]
tags: ["javascript","extjs"]
toc: true
reward: true
draft: true
---

在校期间开发维护学校一个内部系统，当时使用的是ExtJS3.2~3.4，当时也算是很精通这个框架了，还自己亲自写了很多组件，自己修框架BUG :)

现在Sencha ExtJS6已经支持多端适配了，看上去很不错，所以抽时间了解下。

```
1 创建工程框架
sencha -sdk /var/www/extjs6 generate app AppName DirectoryPath
2 运行js工程
sencha app watch
3 工程文件
1）重要文件
app.json：应用程序build、load说明
app.js：用于启动应用程序Application这个类
index.html：默认的web首页，可以在app.json里面进行修改
build.xml：sencha cmd通过它来访问生成的建立脚本，在这里可以多个处理操作进行整合、调优等。
.sencha目录：这个文件夹包含了生成的建立脚本和配置文件，这个目录下面的文件，在建立应用程序的时候是需要的，这些程序一般可以通过sencha app upgrade进行更新，但是不应该手动编辑。
2）建立过程中重复生成的文件，源代码控制中可以将其忽略
build：这个文件夹下面包含了建立过程中的输出信息，连接后的css文件、js文件都被放在这里进行存储。
bootstrap.*：这些文件是通过sencha cmd的built和watch命令创建的，这些文件可以使应用程序以开发者模式启动。
3）其他文件夹
4 应用程序目录结构
|-app                包含了js代码
     |-model       包含了数据模型
     |-store         包含了数据store
     |-controller   全局/应用程序级别的控制器
     |-view          包含了视图，视图模型和视图控制器

|-overrides        需要自动包含、引入的js代码
|-sass
     |-etc             杂类sass代码，默认引入的是all.scss
     |-var             sass变量和mixin声明
     |-src             sass规则
|-resources       图片、字体等资产文件
|-classic            classic工具包相关，目录结构也遵循前面所述的结构

|-modern           modern工具包相关，目录结构也遵循前面所述的结构
5 还是使用gpl版本的吧，不然后面可能不好办，因为trial版本的界面上都带有一个trial图标，而且，哪个30天试用期之后sencha-cmd可能就没法使用了。
6 现在下载了ext-6.0.0-gpl.zip这个gpl版本的！删除之前的ext-6.0.1吧，这里面没有docs，很操蛋，不知道6.0.0里面又没有，不管怎么样，选择gpl版本的肯定是没有错误的。好的，现在删除6.0.1的所有东西吧！
7 https://docs.sencha.com/extjs/6.0/whats_new/whats_new.html,offline文档，点击导航按钮后，找到6.0的文档，点击右侧的按钮下载。卧槽，这尼玛，不好找啊。
8 下载了一本电子书，计划一天的时间掌握extjs6
```
