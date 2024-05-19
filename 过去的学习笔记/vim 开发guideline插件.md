---
layout: post  
title: vim 开发guideline插件
description: ""
date: 2015-11-16 01:57:44 +0800
categories: ["过去的学习笔记"]
tags: ["vim","plugin","extension"]
toc: true
reward: true
draft: false
---

# 如何为vim开发一个guideline插件

Wed Jan 14 20:40:48 CST 2015

## 目标：vim编辑代码时显示guidelines

前几天从小明处看到一个挺不错的插件，它的目的就是能够在写代码时在indent的时
候显示guidelines，这个非常方便，也很人性化，本来我想直接安装这个插件的，但是经
过查看，我发现即使不安装这个插件，也可以在通过tab进行缩进的地方显示guidelines
。

因为我在写代码时才希望显示guidelines，而不是在普通文本文件中也显示
guidelines ，为此我自己写了一个vim的脚本，算不上什么功能强大的插件，但是的确很
实用。

## 实现：实现一个vim guidelines插件

将写好的脚本放置到~/.vim/plugin目录下面，vim会自动加载并执行这个脚本。
顺便说一下吧，通过查看runtimepath可以查看到脚本的搜索顺序，通过scriptnames
可以查看到脚本的加载顺序，通过help scripts可以查看到vim脚本的编写说明。

我写的脚本如下所示。


```vim
"----------------------------------------------------------------------------
" Guidelines  
"
" Introduction
" this plugin is used to dynamically display the guidelines for indent depend
" on the filename's extension. if you want to show the guidelines for
" specified filetype which has extension '*.xxx', then you must put 'xxx' in
" the list s:languages.
"
" that's all, hope you like it.
" ---------------------------------------------------------------------------

if exists('g:show_guidelines')
	if g:show_guidelines == 1
		" show indent guidelines for programming
		let s:current_ft = expand('%:e')
		let s:languages = [
		\		'c', 'cpp', 'cc', 'java',
		\		'js', 'html', 'htm', 'xml',
		\		'php', 'jsp', 'asp',
		\		'sh', 'bash'
		\	]
		let s:existed = index(s:languages, s:current_ft)
		
		if s:existed >= 0
			set list lcs=tab:\¦\  
			hi SpecialKey ctermfg=60 guifg=#000000
		endif
	endif
endif
```

## 总结

本文简要介绍了如何为vim开发一个guidelines插件，vim的扩展性确实非常好。目前这个插件已经放到了我自己的hitzhangjie/Conf/vim/的repo中，实际上我打包了所有常用的vim配置在里面，感兴趣的可以自行取用。
