---
layout: post  
title: vim 开发进阶常用操作
description: ""
date: 2022-06-26 01:58:37 +0800
categories: ["过去的学习笔记"]
tags: ["vim"]
toc: true
reward: true
draft: false
---

# vim使用进阶常用操作

## 文件打开退出

1) open and edit files has several modes as following:
    - vim filename: open this file
    - vim +n filename: open file and position cursor at line n, `n is a number
    - vim + filename: open this file and position your cursor at last line
    - vim +/pattern filename: open file and position at the first match of pattern
    - vim -r filename: open file and recover from swapfile, swapfile on big RAM 	is unnecessary, so I disabled it. then this mode is needless.
    - vim -R filename: open file in mode read-only

2) providing you have edited the file,if you press:
    - :q:  to exit and you'll be warned because you have edited file
    - :q!: force to quit and won't get warning message
    - :w: to store the current modification into current file
    - :wq: to store current modification into current file and quit
    - :w fname: store current buffer content into another file fname,save as
    - :ZZ: store current modification and quit

3) :{n}cq[!] : quit and returns an errcode n, default value of n is 1. you'll need this when you want to abort a `git rebase` operation :)
## 内容插入内容

1) insert modes,if you press:
    - i	:	insert at current position
    - I	:	insert at the beginning of current line
    - a	:	append after current position
    - A	: 	append at the end of line
    - o	:	insert a new line below current line
    - O	:	insert a new line above current line

## 在文件中移动

1. move your cursor in vim:
    - j	:	to next line
    - k	:	to previous line
    - l	:	to right
    - h	:	to left

2. go to specified line:
    - 'line number'+'G'

3. to the beginning of previous line
    - shift +	: 	to the beginning of next line
    - 0	:	to the beginning of current line
    - $	:	to the end of current line
    - w	:	to the beginning of next word,use 'biaodianfuhao' as delimiter
    - W	:	like 'w', but use space as delimiter
    - b	:	to the beginning of previous word, 'biaodianfuhao' as delimiter
    - B	: 	to the beginning of previous word, use space as delimiter
    - e	:	to the end of next word,'biaodianfuhao'
    - E	:	to the end of next word,space
    - (	:	to the beginning of current paragraph 
    - )	:	to the end of current paragraph
    - {	:	to the beginning of previous paragraph
    - }	: 	to the end of next paragraph
    - H	:	to the beginning of current screen,not the file
    - M	:	to the middle of current screen,not the file
    - L	:	to the end of current screen,not the file
    - G	:	to the end of file
    - gg	:	to the beginning of file

4. move current line to top/center/bottom
    - z+enter : move current line to top of window
    - z- : move current line to bottom of window
    - zz : move current line to center of window

## 内容删除操作

1. delete content in vim:
   - x:	delete character of current position
   - X:	delete left character of current position
   - d1:	like 'x'
   - d0:	delete characters from the beginning of line to current position
   - d\$:	delete characters from current position to end of line
   - D:	like 'd$'
   - d^:	like 'd0' but characters to delete doesn't include space and tab
   - dw:	delete chars from current pos to end of word
   - d5w:	delete chars from current pos to end of next 5 words
   - dtc:	delete chars until 'c' is reached
   - dfc: delete chars including next 'c' until 'c' is reached
   - d/word:	delete chars from current pos to the first match of 'word'
   - d3{:	delete from previous 3 paragraphs to current pos
   - d{:	delete from beginning of current paragraph to current pos
   - db:	delete from beginning of current to current pos
   - dW:	delete from current pos to end of word,use 'space' as delimiter
   - dB:	delete from beginning of current word to current pos,'space'
   - d5B:	from previous 5 words to current pos
   - d):	from current pos to the end of current line
   - d4):	from current pos to the end of next 5 lines
   - d}:	from current pos to the end of current paragraph
   - d4}:	from current pos to the end of next 4 paragraphs
   - dd: 	delete current line
   - 3dd:	delete 3 lines from current line
   - dL: 	delete from current pos to end of current screen
   - dH:	delete from beginning of current screen to current pos

## 读写外部文件

1. read file's content into buffer:
   `:[address] r [filename]`
   read content of 'filename',then insert the content into the 'address' position  of buffer.
   if address is 0,then insert content into the beginning of buffer.
   if address is 100,then insert content after line number 100.
   if address is default,then insert content after current cursor position.

2. write buffer content into file on disk
   `:[address] w [!] [filename]`
   because it is rarely used,we neglect it.we usually use command 'w' to store.

3. reload current file content:

   `:e`, press ':e' and enter will reload current file, it means edit current file.


## 文件内容搜索

1. search string

   `/pattern` : press / then input the pattern to search

2. search string1 and substitute by string2
   `:[g] [address] s /searchString/substitueString [/option]`
   usually,we use the command as following format:
   %s /string1/string2/g

   here is an example:

    ```bash
    %s /string1/string2 /g
    ||     |       |     |
    ab     c       d     e
    ```
   a: we can search string1 in all lines in current buffer  
   b: substitue commmand  
   c: the string we want to search  
   d: use string2 to replace string1  
   e: /g allows us to substitue every match in the same line.if we neglected '/g' option,and if multiple matches of string1 occurs,we can only substitue the first match.

3. advanced search and substitute by regexp

   Providing there're many strings ***monitor_"desc"*** in code, we want to replace it with ***cmd_"desc"_succ***，in which the string `$desc` is composed of characters like abc……xyz. So how to do that? In vim command mode, we can press: `:%s/monitor_\([a-z]\{1,}\)/cmd_\1_succ`.  Here `[a-z]{1,+}` is used to match `$desc`，the outerscope `()` is used to capture the first matched group, （notice we do some escaping by `\{1,+}`），the group `\1` will let us reuse the first captured group (that is $desc) . In vim, the captured group number is numbered by the order `(` appears。  
If you think the escape logic is complex, then we can use vim `magic` or `very magic` search mode, ```set magic```, then we can use `:%s/\v/monitor_([a-z]{1,})/cmd_\1_succ` instead. Please refer to ```help magic``` to read more.

## 分屏切换操作

1. split the vim window:
   - horizontally split, `:split` or `:split filename`
   - vertically split, `:vsplit` or `:vsplit filename`

2. change window focus in vim:
   `ctrl+w+w`

​	we can also use shortcuts to change focus but it's inconvenient,so neglect it.

​	but we can define key maps to use `ctrl+hjkl` to move between vim buffers.

3. close windows in vim:
   providing there're several windows splitted existing:
   - :q 	:	to close current window
   - :qall	:	to close all windows
   - :only	: 	to close the other windows

## 执行shell操作

1. start a shell in vim:
   `:sh`
   this is the first method to execute shell commands in vim.
   after you start a shell and execute all commands,you can press 'exit' to quit 
   and go back to vim.

2. execute shell cmd
   this is another method to execute shell commands.
   by this method,you can execute only one shell command.

​	  suggest we use the first method.

3. execute shell cmd and insert the result into buffer

   - :.!command
     if we're in last line mode,we can use '.!command' instead of '!command',like '.!ls -al'.

   - :!!command
     if we're in command mode,we can use '!!command' instead of 'command'.
     please note,when we type '!!command', actually it is '.!command'.

## 标记跳转操作

1. marks 

   - ma : create a mark 'a' at current position

   - 'a : jump to mark 'a'

   - mb : create a mark 'b' at current position

   - 'b : jump to mark 'b'

   - ma : following mark created with the same name will override the ones create before

## 视图类操作

1. mkview/loadview

   we can create a view for current session, like we can fold/unfold some codes, the state will be saved in the view, which is saved under ~/.vim/views/.

   even we save/quit, later we reopen the same file, the view created before will be loaded automatically.

   It's convienient if you're writing some code specially the project is big.

## tags搜索跳转

 1. ctags/etags

    we can generate tags for your file content, no matter it is normal text file or source code, it just generate tags for your files, then we can search by tags to quickly find the position where it is defined, then we can jump there.

    when generating tags, we need install binary tool like ctags/etags, run `ctags -R .` is OK for most cases, it will generate tags in your current folder for all files recursively.

 2. tags search

    by default, it will search tags file under current directory or the same directory which your editing file resides. sometimes we want vim to search other directories, for example, we write linux programs and we need some linux system headers, we want to jump to the system headers by looking up the tags. 

    then we need to generate tags file for system headers, and we should let vim to search through it. we should add the path to that tags file into vim tags search paths.

    `set tags=./tags;tags/;~`，it first find tags file in the same directory which the editing file resides, if not found, then it keep searching in current working directory; if not found it searched the user homedir. if still not found, it stopped.
    
    we can add system headers path into the search paths.
    
    Please read more abount vim tags by `:help tags`.
