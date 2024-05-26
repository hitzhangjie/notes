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

## lp
- submit files and print

## pwd
- print current working directory

## Match pattern in bash
- `?`, `*`, `[]` can be used to match patterns in bash
- Examples:
	- `b{ed,olt,ar}s`
	- `ls *.{c,h,o}`

## I/O
- `cat`: copy input to output
- `grep`: match lines from input
- `sort`: sort lines from input
- `cut`: extract columns from input
- How to set the delimiter to space?
	- Note: `-d' '` only specifies space as the delimiter, not including tab. It's inconvenient when files contain both space and tab.
	- Example: `cut -d' ' -f2 filename`
	- Note: `awk` uses tab and space as the delimiter, which may be more convenient.
	- Example: `cat filename | awk '{print $2}'`
- `sed`: edit the input
- `tr`: convert input characters to others

## Background jobs
- `&`: background jobs have no access to the terminal input, i.e., background jobs can't listen to the terminal input
- `jobs`: list background jobs

## Diff
- Compare files line by line
- Examples:
	- `diff -s -y file1 file2`
	- `diff -q -y file1 file2`

## Modify the priority of jobs
- `nice -n num cmd`

## Control key
- `ctrl-c`: interrupt current command
- `ctrl-d`: end input
- `ctrl-\`: quit
- `ctrl-s`: stop outputting to the current screen
- `ctrl-q`: restart outputting to the current screen
- `ctrl-u`: delete the whole command line
- `ctrl-z`: suspend current command

## Source .bashrc
- Note: After you modify the file `.bashrc` to customize the bash environment, use the command `source .bashrc` to execute the commands in the file. The customized bash environment will be updated!

## Bash Shell Programming and Debug
- Learn it in detail!

## Set the new owner of files
- `chown -R newuser dirname`
- `chown newuser filename`

## Set the new group of files
- `chgrp -R newgrp dirname`
- `chgrp newgrp filename`

## Add and delete users
- Add user to group:
	- `adduser user group`
- Delete user:
	- `deluser user group`
	- `sudo rm -r linux`

## Add and delete groups
- Add group:
	- `addgroup groupname`
- Delete group:
	- `delgroup groupname`

## Password management
- Change password for an account:
	- `passwd user`
- Lock and disable login of a user:
	- `passwd -l user`
	- When the user tries to login, they will get a message 'login incorrect'
- Unlock user account:
	- `passwd -u user`
- Remove password of a user account:
	- `passwd -d user`

## Tar
- Packet and compress files
- Packet:
	- `tar -cvf xxx.tar files`: packet files into `xxx.tar`
- Packet and compress:
	- `tar -zcvf xxx.tar.gz files`: packet and compress files into `xxx.tar.gz` using gzip
- Uncompress:
	- `tar -xvf xxx.tar`
	- `tar -zxvf xxx.tar.gz`
- Note: Similar commands can be used with `.tar.bz2` files using `bzip2`

## Mount/Unmount
- For CD-ROM:
	- `mount -t iso9660 /dev/cdrom /mnt/dirname`
- For USB disk:
	- `mount -t vfat /dev/disk/by-label/diskname /mnt/dirname`
- Unmount:
	- `umount /mnt/dirname`

## Network configuration
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

## At
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

## Process management
- `ps -aux`: display all processes (-a), display users (-u), display background processes (-x)
- `ps -ef`: display all running processes including background processes (-e), display parental process ID (-f)
- `ps`: display processes running on the current terminal
- `pstree`: display process tree in the system
- `pstree -p`: display process tree with their PIDs
- `top`: dynamically display processes in the system

## Kill process
- `sudo kill pid`
- `sudo kill -9 pid`: kill process forcefully
- `sudo kill `cat /var/run/processname.pid``: kill process using the PID stored in `/var/run/processname.pid`

## Date
- `date`: display date and time
- `date -s "20121224 16:40"`: set date and time according to the given string
- `date -d@$timestamp`: convert timestamp to formatted datetime

## Disk space usage
- `df`: display the disk space usage of every file system
- `df -h`: display disk space usage in a human-readable format
- `du`: display the disk space usage of files or directories
- `du -h filename`: display file size in a human-readable format
- `du -h dirname`: display the size of every file or directory within the specified directory
- `du -sh dirname`: display the total size of the specified directory

## Word count
- `wc`: count quantities of new lines, bytes, words, etc.
- `wc -m`: count quantities of characters
- `wc -c`: count quantities of bytes
- `wc -w`: count quantities of words
- `wc -l`: count quantities of lines
