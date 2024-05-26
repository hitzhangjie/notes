---
layout: post  
title: Bash常用命令
description: ""
date: 2024-05-19 09:10:25 +0800
categories: ["过去的学习笔记"]
tags: ["unix","linux","shell","bash"]
toc: true
reward: true
draft: false
---

迁移自 hitzhangjie/Study 项目下的内容，本文主要总结的是一些日常高频使用的Linux命令。

## Navigation 
- `pwd`: print current workdir, `print -P` print workdir and resolves symbolic link
- `pushd <dir>`, record current workdir and change to dir
- `popd <dir>`, change to previous recorded workdir
- `cd -`, change to previous path

## Pattern Matching
### Basics 
- `?`: zero or one character
- `*`: zero or more characters 
- `[a-zA-Z0-9,.]`, any character in this range
- `{a|b|c}`, any character in this set, examples: `b{ed,olt,ar}s` or `ls *.{c,h,o}`
### Command: grep
- `grep --color`: output the matching lines, `--color` highlight the matches

### Command: find
- `find <dir> -iname <pattern>`: find matching files in <dir>

## File Operations
### Basics
- `cat`: concatenate files and print on the standard output
- `tac`: concatenate and print files in reverse
- `grep`: search a file for a pattern
- `sort`: sort lines of text files
- `uniq`: deduplicate the lines, combined with `sort`
### Word count
- `wc`: count quantities of new lines, bytes, words, etc.
- `wc -m`: count quantities of characters
- `wc -c`: count quantities of bytes
- `wc -w`: count quantities of words
- `wc -l`: count quantities of lines
### Extract 
- `cut -d, -f1,2`: remove/extract sections from each line of files
  - How to set the delimiter to space?
    - Note: `-d' '` only specifies space as the delimiter, not including tab. It's inconvenient when files contain both space and tab.
      Example: `cut -d' ' -f2 filename`
    - Note: `awk` uses tab and space as the delimiter, which may be more convenient.
      Example: `cat filename | awk '{print $2}'`
- `awk {print $1 $2 $NF-1}`: print the columns 1, 2, the last
- `column -s, -t`: split columns by ',' and output as table
### Edit
- `sed`: `-i` edit the input inplace, `s/a/b/g` or `s|a|b|g` to replace a with b
- `tr`: convert input characters to others
### Compare 
- `diff`, compare files line by line
  Examples:
  - `diff -s -y file1 file2`
  - `diff -q -y file1 file2`
- `diff -r <dir1> <dir2>`, compare folders recursively
### Compress
- `tar cvf[|z|j|J]`, compress files
- `tar xvf`, decompress files
- supported compression format:
	- default, *.tar
	- -z, *.tar.gz or *.tgz
	- -j, *.bzip2
	- -J, *.xz
	- etc.
### Print
- `lp`: submit files and print
### Explorer
mc, 命令行下的文件管理器
除了对文件的相关操作之外，还可以登录ftp服务器。

## Process Management 
### Adjust Priority
- `nice -n num cmd`: modify the priority of jobs
### Terminal Control
- `ctrl-c`: interrupt current command
- `ctrl-d`: end input
- `ctrl-\`: quit
- `ctrl-s`: stop outputting to the current screen
- `ctrl-q`: restart outputting to the current screen
- `ctrl-u`: delete the whole command line
- `ctrl-z`: suspend current command
### Background jobs
- `&`: background jobs have no access to the terminal input, i.e., background jobs can't listen to the terminal input
- `jobs`: list background jobs

## Priviledge Management
### Set the new owner of files
- `chown -R newuser dirname`
- `chown newuser filename`
### Set the new group of files
- `chgrp -R newgrp dirname`
- `chgrp newgrp filename`
### Add and delete users
- Add user to group:
	- `adduser user group`
- Delete user:
	- `deluser user group`
	- `sudo rm -r linux`
### Add and delete groups
- Add group:
	- `addgroup groupname`
- Delete group:
	- `delgroup groupname`
### Password management
- Change password for an account:
	- `passwd user`
- Lock and disable login of a user:
	- `passwd -l user`
	- When the user tries to login, they will get a message 'login incorrect'
- Unlock user account:
	- `passwd -u user`
- Remove password of a user account:
	- `passwd -d user`

## Filesystem Management
### Mount/Unmount
- For CD-ROM: `mount -t iso9660 /dev/cdrom /mnt/dirname`
- For USB disk: `mount -t vfat /dev/disk/by-label/diskname /mnt/dirname`
- Unmount: `umount /mnt/dirname`

ps: read more about **/etc/fstab**.
### Disk space usage
- `df`: display the disk space usage of every file system
- `df -h`: display disk space usage in a human-readable format
- `du`: display the disk space usage of files or directories
- `du -h filename`: display file size in a human-readable format
- `du -h dirname`: display the size of every file or directory within the specified directory
- `du -sh dirname`: display the total size of the specified directory

ps: my mostly used disk usage command: `du -hx --max-depth=1 . | sort -rh`.

## Network Management
- `ifconfig`: show configuration
- Set IP address and netmask for `eth0`:
	- `ifconfig eth0 xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx`
- Disable `eth0`:
	- `ifconfig eth0 down`
- Enable `eth0`:
	- `ifconfig eth0 up`
- Network interfaces:
	- `eth0`: wired Ethernet card
	- `wlan0`: wireless network card
	- `lo`: loopback test network card

## Process management
### List running processes
- `ps -aux`: display all processes (-a), display users (-u), display background processes (-x)
- `ps -ef`: display all running processes including background processes (-e), display parental process ID (-f)
- `ps`: display processes running on the current terminal
- `pstree`: display process tree in the system
- `pstree -p`: display process tree with their PIDs
- `top`: dynamically display processes in the system
### Kill process
- `sudo kill pid`
- `sudo kill -9 pid`: kill process forcefully
- `sudo kill `cat /var/run/processname.pid``: kill process using the PID stored in `/var/run/processname.pid`
### At: jobs for later execution
- Start `atd` service:
	- `sudo service atd start`
- Examples:
	- Run a command at a specific time:
		```
		at 12:10
		at> mpg123 -C -Z dir/*.mp3
		at> <EOT>
		```
	- Run a command after a specific time:
		```
		at now +3 week
		at> ...
		at> ...
		at> <EOT>
		```
	- Note: Press `ctrl-d` to generate an EOT signal
### Session Management: screen
screen, 可以实现在一个终端窗口中生成多个终端，方便实用，尤其是在非x-window工作状态下，screen的重要性就体现的更加明显。
- ctrl+a,c	to create a session
- ctrl+a,p	go previous session
- ctrl+a,n	go next session
- ctrl+a,N	go to the session numbered 'N'
- ctrl+a,'	go to the seesion named by 'ctrl+a,A'
- ctrl+a,"	list all session and choose which to go
- ctrl+a,A	rename current session
- ctrl+a,d	detach current screen's display,leaving current session keeping on running

ps: alternatives to screen: tmux, byobu.
## Package Management
### dpkg debian系包软件工具
dpkg是debian系发行版的包管理工具，apt是在dpkg之上的工具。
#### install *.deb
- `dpkg -i *.deb`
#### backup installed packages
dpkg一个比较实用的方法使用来备份系统已经安装的软件列表，以便重装系统之后，快速恢复系统中需要的软件，相当于对系统的一次克隆。
- 备份软件安装列表：`dpkg --get-selections > installedApp`
- 将安装列表中的软件安装到系统：`dpkg --set-selections < installedApp`
- sudo apt-get dselect-upgrade

也可以如下操作：
```
dpkg --get-selections | grep -v deinstall > installedApp
dpkg --set-selections < installedApp
sudo dselect
```
#### build *.deb
`dpkg-buildpackage` can be used for build deb package.

### update-alternatives
update-alternatives，常用重要选项：--list/--config/--auto/--install/--remove.

The purpose of update-alternatives is to manage symbolic links for commands or programs that have multiple implementations on a Unix-like system. It allows you to choose the default version of a command or program among the available alternatives.
### install from source
软件安装一般过程
- configure	:如果运行成功，将会生成makefile文件；如果失败，需要根据提示信息，调整下系统中的软件依赖，然后再次尝试。
- make		:如果运行成功，会生成可执行文件，便于之后的安装过程。如果失败，当然要继续调整。
- make install 	:安装。
  如果程序设计的比较好的话，可能还会有卸载程序,运行checkinstall, make uninstall卸载程序。

ps: `dpkg-buildpackage` can be used for build deb package.

## Shell Relevant
### Reload Config
- `source .bashrc`: change and update current shell config
### Shell Variables
- `$#`：调用脚本的命令行参数的个数
- `$*` or `$@`：脚本的命令行参数，若参数用括号引起来“two words”，`$*`将其看作两个参数，而$@看作是一个参数
- `$0`：脚本命令中的第一个值，也就是命令的名字
- `$?`：前一个命令的返回值，如果前一个命令返回成功，则返回0；非0表示不成功
- `$$`：当前进程的id
### Shell Redirection
1) command > ~/log.txt 2>&1: stderr and stdout goes to log.txt both
2) command 2>&1 > ~/log.txt: stdout goes to log.txt, but stderr goes to console
Shell resolves the redirection operators from left to right. 
`2>&1 >~/log.txt` means:
- `2>&1` directs the stderr to file descriptor which fd-1 points to (for now, it's console).
- `>~/log.txt` later redirect stdout to file ~/log.txt.
### Tee Redirection
`command | tee -a ~/log.txt`: read from stdin and write to stdout and files

## Other Management
### Date
- `date`: display date and time
- `date -s "20121224 16:40"`: set date and time according to the given string
- `date -d@$timestamp`: convert timestamp to formatted datetime
### Explorer
mc 命令行下的文件管理器
除了对文件的相关操作之外，还可以登录ftp服务器。
### Web Browser
w3m 命令行下的www浏览工具
使用上下左右箭头可以在网页中移动，当移到某个超链接上后，可以通过回车健进行跳转。如果是在页面中的输入框中输入信息，首先敲击回车键，然后就可以输入信息来。
### Web Utility
wget与curl 命令行与后台下载工具
### Documentation
dwww: 利用本地web服务器apache，通过浏览器查看帮助文件。

