---
layout: post  
title: Linux系统使用杂谈 - 经验技巧
description: "这是一个笔记大杂烩，记录了Linux发行版日常使用过程中遇到的大大小小的问题及解决办法"
date: 2012-01-01 10:25:37 +0800
categories: ["过去的学习笔记"]
tags: ["unix", "linux"]
toc: true
reward: true
draft: false
---

迁移自 hitzhangjie/Study 项目下的内容，本文主要总结的是日常使用Linux发行版过程中遇到的问题及解决办法。

```
/* vim: set ft=text: */
##############################################################################

config codeblocks for wxwidgets

if you want to compile and link wxwidgets project,do as following:
compiler and debugger-->compiler settings-->other options:
	add `wx-config --cflags`
compiler and debugger-->linker settings-->other options:
	add	`wx-config --libs`


note: 
if you want to build normal c/c++ project rather than wxwidgets projects, you
must remove `wx-config --cflags` and `wx-config --libs`.  a better choice is
to set the target project's properties including compiler and linker options
where you can set `wx-config --cflags` and `wx-config --libs`.

##############################################################################

add desktop icon for apps.
create and edit appName.desktop file in /usr/share/applications.

please note,Icon=.../fg,fg is a picture without expanded name.

##############################################################################

install stardict to search words in terminal

1)	install 'sdcv' which is the core of programme.  
	sudo apt-get install sdcv
2)	download the dictionaries from site: 
	http://abloz.com/huzheng/stardict-dic/
3)	extract the downloaded files and extract them into the path
	'/usr/share/stardict/dic'

to use it conveniently,set some alias cmds,which was written in .bashrc,to use
different dictionaries.

##############################################################################

security of GRUB
lock grub interaction
lock start item
lock both grub interaction and start item

##############################################################################

start a program when os started

1)	we can create a symbolic link of actual programme or put that programme in
	the folder /etc/init.d/.

2)	then we should execute command 'update-rc.d' to install links into
	/etc/rcNumber.d,for example:
	sudo update-rc.d name start priorityNum runlevel . stop priorityNum2
	runlevel.

##############################################################################

mpg123 : use shell to play music

now i want to say,it is nice !
##############################################################################

to extract specific column content from result of 'ls -l' or other cmds

cut -d'delimiter' -fFiledNO

example: cat filename | cut -d',' -f2
	-d means delimiter,-f means fields.

	awk '{print $number}' can be an alternate method.
##############################################################################

in text mode:
adjust brightness:
echo number > /sys/class/back_light/intel_backlight/brightness

adjust volume:
run 'alasmixer'
in text mode,when zhcon running,alsamixer interface will be messed up!

##############################################################################

purge all configruation files of the deinstalled packages
dpkg -l |grep ^rc|awk '{print $2}' |sudo xargs dpkg -P 
##############################################################################

how to boot through "GRUB"

here are the three methods to start linux from grub cli:
1)	ls
	linux (hd0,msdos10)/vmlinuz root=/dev/sda10 [...other options]
	initrd (hd0,msdos10)/initrd.img 
	boot

	ls
	linux (hd0,msdos10)/boot/vmlinuz-3.2.0-23-26-generic root=/dev/sda10
	[...other options]
	initrd (hd0,msdos10)/boot/initrd.img-3.2.0-26-generic
	boot

	actully, /vmlinuz,/initrd are symbolic links to /boot/..

 configfile (hd0,msdos1)/boot/grub/grub.cfg
	boot	

for windows os
	
	here are the only method to start windows from grub cli:

    - for grub1:

	rootnoverify (hd0,msdos1)	:this option prevents grub trying to mount
								:partition hd0/msdos1

	chainloader +1				:this option +1 let grub try to load the
								:proper boot-loader for windows from the 1st
								:fan sector of (hd0,msdos1)

    - for grub2: there's no command rootnoverify.

    set root=(hd0,msdos1)
    chainloader +1
    boot

this is useful when you reinstall windows os,windows bootloader will override
mbr and other os boot items will be missing.  then you can use a linux live cd
to boot into grub command line interface,use method above to boot into
linux,then reinstall grub.
##############################################################################

download website
wget -r -p -np -k url
-r :recursively
-p :download picture
-np:don't ascend to the parental directory 
-k :modify the relavant link
##############################################################################

linux core version
major.minor.release-revise
主版本号.次版本号.释出版本-修改版本
主版本号.次版本号为偶数，稳定版本，为奇数，表示开发中版本

linux核心版本号 与 某linux发行版本号，是不同的概念
##############################################################################

acpi call module

sudo apt-get install git
git clone http://github.com/mkottman/acpi_call.git
cd acpi_call/
make
sudo insmod ./acpi_call.ko
uname -r
sudo cp acpi_call.ko /lib/modules/<UNAME -R VALUE>/kernel/drivers/acpi/
sudo depmod

	***
	note: 'sudo depmod',this step is of vital importance because 'depmod'
	generates file 'modules.dep' which can be used by other modules.  if we
	didn't execute 'depmod' before restart,pc will spend more start-up time
	because the dependencies haven't been worked out.

vim /etc/modules,add line 'acpi_call'
run ./test-sh

Trying \_SB.PCI0.P0P1.VGA._OFF: failed
Trying \_SB.PCI0.P0P2.VGA._OFF: failed
Trying \_SB_.PCI0.OVGA.ATPX: failed
Trying \_SB_.PCI0.OVGA.XTPX: failed
Trying \_SB.PCI0.P0P3.PEGP._OFF: failed
Trying \_SB.PCI0.P0P2.PEGP._OFF: failed
Trying \_SB.PCI0.P0P1.PEGP._OFF: failed
Trying \_SB.PCI0.MXR0.MXM0._OFF: failed
Trying \_SB.PCI0.PEG1.GFX0._OFF: failed
Trying \_SB.PCI0.PEG0.GFX0.DOFF: failed
Trying \_SB.PCI0.PEG1.GFX0.DOFF: failed
Trying \_SB.PCI0.PEG0.PEGP._OFF: works!

add 'echo "\SB.PCI0.PEG0.PEGp._OFF" > /proc/acpi/call' into your script file
/etc/rc.local.  

note:
after 'sudo depmod' is run,add 'acpi_call' into file /etc/modules is ok, too.
for my pc,the last cmd works!

use 'cat rate /proc/acpi/battery/BAT1/state' to check current power!
##############################################################################

use mentohust to instead of ruijie(xrgsu)
	
##############################################################################

use Chinese characters in LaTeX

support chinese	:	sudo apt-get install latex-cjk-all
pay attention to the document format:

\documentclass{article}
\usepackage{CJK}
\begin{document}
\begin{CJK}{UTF8}{gbsn}	%gbsn/gkai are supported while GB not supported
...
\end{CJK}
\end{document}

generally,the supported fonts' directory is :
/usr/share/texmf/tex/latex/CJK/

note: 
in current dir,dirName is the encoding name,fonts in it are all supported.
##############################################################################

disable or renable the download bar of chrome
how to disable
	chrome://flags-->disable 'new download gui'
how to get it back
	just delete the config info of current user,'sudo rm -r
	/home/$USERNAME/.config/chrome/Profile 1'
##############################################################################

customize the background image of grub2 and login shell

note:
	after seting up the splash image of grub2,the menu color can't be set.

	if we don't use splash image of grub2,we can use the following way to set
	the menu color on grub2.

	edit /lib/plymouth/themes/default.grub:
		set menu_color_normal=color1/color2
		set menu_color_highlight=color1/color2

1.change background color of Grub
	
	cd /lib/plymouth/themes/
	modify default.grub,substitute the current color r,g,b to your favorite
	one.

  change background image of Grub
	
	cp imagePath /boot/grub/
	update-grub

2.change the background color which appears before login interface.
	
	cd /lib/plymouth/themes/ubuntu-logo
	modify '*.scrpit','vim *.script',
	change the major color and minor color set by function
	'SetBackground...(r,g,b)'.  note that value of 'r' is 'r/255',values of
	'g' and 'b' are calculated as the same method.

3.change the picture or color shown before the login interface appear
	
	cd /usr/share/glib-2.0/schemas/
	record the file name,'grep *greeter* *',then modify its contents.
and background-color(color),if your
	like,change the 'draw desktop background' and 'startup sound'.

	glib-compile-schemas ./

	suggestion: 
	set the schema 'background' as a image rather than color can accerlarate
	the loading speed.
##############################################################################

 mount windows file system in /etc/rc.local or in /etc/fstab.
	
	in /etc/rc.local:
	# mount /dev/disk/by-label/Document /media/document
	# mount /dev/disk/by-label/Multi-media /media/multi-media

	in /etc/fstab:
	UUID=..... /media/... ntfs rw 0 0
	
	note:
		if we want to use 'Trash' mechanism in linux desktop distribution such
		as Ubuntu,'user,gid=1000,uid=1000' must be added to the mount option
		in fstab in the following manner:
		UUID=... /mount-point fs-type defaults,user,gid=1000,uid=1000 0 0

		use command 'blkid' to check the UUID and LABEL for all partitions and
		command 'id' to check the user's group identifier and user identifier.
		only files owned by current user(or you are super user),files can be
		deleted to the trash and restored from there.

		UUID means 'Univerally Unique Identifier'.
##############################################################################
 fix desktop environment

 at times,some essential packages to desktop environment components may be
 removed when we uninstall some gnome based programmes.
 on this occasion,maybe the reason is some unity or gnome components are
 uncarefully removed.
 do as the following to fix this problem:
	1)	install package 'unity-greeter',then we can login into desktop
	environment.

	2)	install package 'unity,unity-2d,unity-2d-shell' to add the
	'unity,unity-2d' display solution besides 'gnome,gnome classic,gnome
	classic(no effect).

	3)install package 'gnome-icon-themes,gnome-icon-themes-full,gnome-mono' to
	install our needed common icons for desktop environment.

	4)install package 'gnome-tweak-tool' to slightly adjust the desktop
	environment components to make it much more beautiful.

	note:
	before uninstalling a package,you'd better use 'apt-cache rdepends' to
	check whether there're other packages requiring it.
##############################################################################
	change the order of buttons 'minimize,maximize,close' and the positon of
	these buttons on windows.

	start app 'gconf' and search branch '/apps/metacity/general' and find the
	item 'button_layout',change its value.

	for example,if the value is ':minimize,maximize,close',then the three
	buttons are on the right side of windows in the order
	'minimize,maximize,close';

	note that this colon ':' control the position of buttons on windows.

	then if we want to set the three buttons on the left side on windows in
	order 'close,minimize,maximize',then we can set item 'button_layout' to
	value 'close,minimize,maximize:'

##############################################################################
	optimize the initramfs

	vim /etc/initramfs-tools/initramfs.conf
	change item "MODULES=most" to "MODULES=dep".
	then "sudo update-initramfs -u"
##############################################################################
	activate 'brightness and lock'

	if we want to activate the feature 'dim screen' and 'lock screen' in
	system settings 'brightness and lock',services 'acpi-daemon' and 'acpid'
	must be enabled.

	ACPI means 'Advanced Configuration and Power management Interface'.
##############################################################################

	solve the encoding mistakes in vim
	
	edit ~/.vimrc and add the following lines:

set the character encoding in buffer
	set encoding=utf-8
set the character encoding when written to files
	set fileencodings=utf-8,gb2312,gbk,gb18030
set the character endoding when output to terminal
	set termencoding=utf-8

	gedit can't handle Chinese encoding,too, install 'Kate' instead of it.
##############################################################################
	ERROR 1045 (28000): Access denied for user 'root'@'localhost'.

	this fault is similar to the previous one. so, how to fix it?

stop process 'mysqld'
		sudo service mysqld stop
start process mysqld_safe with special options to fix it
		sudo mysqld_safe --skip-grant-tables --skip-networking &
launch mysql client to connect to database mysql
		mysql -h localhost mysql
check whether there's something wrong in the user table
		select host,user,password from user;

		it it not allowed to exist user whose name is empty, so first delete
		those users, then change your root password with following cmd.
		
where user='root';
kill process mysqld_safe
		sudo pkill mysqld_safe
restart mysql service
		sudo service mysql start
user mysql client to connect the mysql server again
		mysql -h localhost -u root -p

		all done !
##############################################################################
	can not create user ???

	do it similarly as mentioned above to check whether the user has right
	privileges.

##############################################################################

	enable 'charset auto detect' in chrome browser

	tools->encoding->auto detect
##############################################################################

	remove marks '
' at the end of lines
	press ctrl+V then ctrl+M to generate mark '
',then we can use :%s/
//g
	to delete them.
##############################################################################

	detect and convert file encodings

	'chardet' : detect file encoding
	'iconv'	  : convert file encoding from one to another

	script:{

		step 1: detect charset of specified files

		#!/bin/bash
		for file in 'ls | grep php'
		do 
			chardet $file >> ~/Desktop/tmp/encoding
		done

		step 2: convert charset of specified files from one to another

		#!/bin/bash
		for line in `cat encoding | grep GB2312 | awk '{print $1}'`
		do
			lenght=${#line}
			line=`echo ${line:0:length-1}`
			echo $line
			/usr/bin/iconv -f GB2312 -t UTF-8 /path/php/$line >> ./$line
		done

		echo "convertion finished !"
	}
##############################################################################

	add a new font into system

copy relavent font files that end with *.ttf to
	/usr/share/fonts/customized_dir/.
enter customized_dir,'cd customized_dir_path'
'sudo mkfontscale'
'sudo mkfontdir'
	5)'sudo fc-cache -fv'
	6)'restart os'

	but note,if you want to display the Chinese characters well,you had better
	install the software 'Language Support' from the Software Center.
##############################################################################

	after wine has been installed,windows notepad will be the default text
	editor,but when wine has been uninstalled,option in context menu 'open
	with notepad' is still there,while notepad has been uninstalled,too.

	we can edit file '~/.local/usr/applications/mimeinfo.cache' for current
	user or '/usr/share/applications/mimeinfo.cache' for all users on this
	computer.

	change 'text/plain=...' to 'text/plain=kde4-kate',then kate will be
	default text editor.

	if install program systemwide, then you may check /usr/share/*mime*, too.
##############################################################################

	use 'gnome classic' theme instead of 'gnome' or 'unity' themes when login
	in Ubuntu.

	several techniques:
	1)	'gnome-panel --replace' to restart panel on desktop

	2)	'win+alt' + 'right click' to open menus to remove unnecessary icons on
	bars.

	3)	to remove 'notification area',put the cursor on the left side of this
	area,press 'win+alt' and 'right click' to remove the 'notification area'.

	4)	use	'indicator applet complete' to replace 'notification area' 

to the left of windows
	list on the bottom panel to customize the preferences.
##############################################################################

	source file
	source .bashrc in bash
	source .vimrc in vim

	you can't source .vimrc file in bash.
##############################################################################

	remove style 'unity' and 'unity 2d',just use 'gnome','gnome
	classic','gnome classic(no effect)'.

	apt-get purge unity unity-2d unity-2d-places unity-2d-panel unity-2d-spread 
	apt-get purge unity-asset-pool unity-services unity-lens-* unity-scope-*
	apt-get purge liboverlay-scrollbar*
	apt-get purge appmenu-gtk appmenu-gtk3 appmenu-qt
	apt-get purge firefox-globalmenu thunderbird-globalmenu
	apt-get purge unity-2d-common unity-common
	apt-get purge libunity-misc4 libunity-core-5*

	you'd better use 'apt-cache rdepends' to check whether there're other
	packages depending on the package to be uninstalled.
#######################################///////////

	enable 'localhost/phpmyadmin' to access phpmyadmin

	sudo ln -s /usr/share/phpmyadmin /var/www/phpmyadmin
##############################################################################

	customize notification fade time and position

	Open a terminal window and enter these commands one by one:

	sudo add-apt-repository ppa:leolik/leolik 
	sudo apt-get update
	sudo apt-get upgrade
	sudo apt-get install libnotify-bin
	pkill notify-osd
	This installs a patched version of the notify-osd package. Then you will
	need to install the GUI configuration tool, to do this enter these
	commands one by one into a terminal window:

	sudo add-apt-repository ppa:nilarimogard/webupd8
	sudo apt-get update
	sudo apt-get install notifyosdconfig
	To use the congfiguration tool type "notify" into the dash and launch the
	NotifyOSD Configuration application.
##############################################################################

	restore scripts in /etc/grub.d

	purge all grub* package,then reinstall grub2.
##############################################################################

	change volume icon at the top panel.
	cd /usr/share/icons/
	find -name audio-volume-*

	put the audio-volume-* icons that you like into the target icon theme
	directory to replace the target icons.
##############################################################################

	about the background wallpaper

	i want to put a picture into /boot/grub in order to load background image
	on grub interface, but i also want to use another picture as the desktop
	wallpaper,also,i don't want the grub background wallpaper appear again
	before the desktop wallpaper is loaded,how to i realize it?
	1)firstly,in .bashrc,we use shell commands to access the .gconf
	configuration file which consist the desktop wallpaper information,do it
	as following:

		TEMP1=`cat ~/.gconf/desktop/gnome/background/%gconf.xml`
		TEMP2=`echo ${TEMP1#*//}`
		WALLPAPER=`echo ${TEMP2%</stringvalue>*}`
		ln -sf $WALLPAPER /home/$USERNAME/.background.jpg
		TEMP1=""
		TEMP2=""
	2)secondly,edit  /usr/share/glib-compile-schemas/*greet*:	
		set the schema 'background' to '/home/$USERNAME/.background.jpg'

	now it can automatically load the desktop wallpaper now,we needn't edit
	'*greet*' after we changed desktop wallpaper from now on.

	we can also put the shell cmds mentioned above into a script file,i copy
	the cmds into /usr/bin/update-background.

	####

	in 16.04 lts, there's no %gconf.xml found, but we can get the background
	via gsettings by exec command:
		'gsettings get org.gnome.desktop.background picture-uri'.
	then we can recreate the soft link.

	# update background when login
	BACKGROUND_CONFIG=`gsettings get org.gnome.desktop.background picture-uri`
	BACKGROUND_CONFIG=`echo ${BACKGROUND_CONFIG#*//}`
	ln -sf $BACKGROUND_CONFIG /home/$USERNAME/.background-uri

##############################################################################

	modify ubuntu_logo or progress_dot_on.png

	if you want to change the color,image->mode must be changed from 'index'
	to 'rgb'
##############################################################################

	install oracle java instead of openjdk or icedea version

	1)	First you need to remove openjdk for this run the following command
	from your terminal

	sudo apt-get purge openjdk*

 If you installed java 7 from any other PPA and you are having problem
	with java then you have to do following steps before installing the PPA
	menctioned here

	sudo rm /var/lib/dpkg/info/oracle-java7-installer*
	sudo apt-get purge oracle-java7-installer*
	sudo rm /etc/apt/sources.list.d/*java*
	sudo apt-get update

	3)	Install oracle java 7 in ubuntu 12.04

	sudo add-apt-repository ppa:webupd8team/java
	sudo apt-get update
	sudo apt-get install oracle-java7-installer

	You can check the java version by searching java in dashboard

##############################################################################

	install oracle jdk

	i found a new method, you can leaving openjdk* there, and just download
	the oracle jdk from oracle offical site, then unpack it to
	/usr/local/share/jdkxxxx, then you change work directory to that directory,
	and execute:
		'for item in 'ls .'; do update-alternatives --install /usr/bin/$item
		$item /usr/local/share/jdkxxx/bin/$item 10000; done'
	over!	

	note:
	a better method is to install java as the master link, and install other
	jdk relevant tools as slave link.

##############################################################################

	eclipse can't load swt relevant libraries

	ln -s /usr/lib/jni/libswt-* ~/.swt/linux/x86_64/
##############################################################################
	zhcon --utf8

	if error occurs,check the permission of file /usr/bin/zhcon, 'chmod 4755
	/usr/bin/zhcon', to enable all users to execute this program with root
	permission.
##############################################################################

	change the hostname

	cmd 'hostname':
		display current hostname: 'hostname'
		change hostname temporarily: 'hostname newname'
	
	change hostname forever,edit file /etc/hostname,the modification won't
	take effect until next boot.
##############################################################################

	ftp/ssh/telnet to login in remote server
	
	ftp: need ftp/ftpd to be installed, and its' configuration is within
	/etc/inetd.conf and is controlled by /etc/init.d/openbsd-inetd.

	ssh: need sshd running,install openssh-server to make it.
		 login remote server: ssh username@ip-server
		 to configure ssh client/server, edit the conf file within
		 /etc/ssh/ssh_config and /etc/ssh/sshd_config.

	telnet: need telnetd running,install openbsd-inetd
		 login remote server: telnet username@ip-server
	
    copy file between remote server and local machine,use cmd 'scp'
		scp usrname@ip-src:/path/file1 username@ip-des:/path/file2
##############################################################################

	on my thinkpad x61t,tomcat7 doesn't allow to access the symlinks,but it
	indeed worked on my samsung pc.  i really don't know why.  i have to move
	all the jsp source files to the /var/lib/tomcat7/webapps/ROOT/,and create
	a symlink named ~/Documents/jsp pointing to
	/var/lib/tomcat7/webapps/ROOT/.

	i have found a resolution,that is create a descriptive file within
	/etc/tomcat7/Catalina/localhost/.
##############################################################################

	place window on the proper position,such as 'smart','center','maximized'
	and so on.

	use compiz to customize it.
##############################################################################

	install 'mysql workbench' instead of 'emma'
##############################################################################

	wireshark

	by default,only user in group sudo can capture packets,how to enable
	non-sudo user capture the packets.

	'sudo dpkg-reconfigure wireshark-common'
	choose option 'yes' and press enter to install 'dumpcap'
	then 'sudo chmod +x /usr/bin/dumpcap'
##############################################################################

	in single-user mode,remount fs '/' in order to edit files

	mount -o rw,remount /
	-o: options
	rw: read and write
	remount: umount first,then remount
	/: the root filesystem
##############################################################################

	single-mode reset root passwd

	select 'recovery mode' and press 'e' to change the kernel parameters,i.e,
	change 'ro' to 'rw' to enable write operation on filesystems,and change
	'recovery' to 'single' to enable single-mode that give you the root
	privilege,and ...

	don't forget to add 'init=/bin/bash' to the parameter list in order to
	start bash for emergent recovery operation.

	then you'll get the root privileges and do whatever you want.
##############################################################################

	ps -lax
	ps -aux

	-l : long format
	-a : all processes
	-x : processes that don't have control terminal
	-u : output format is user-oriented
##############################################################################

	strace

	use cmd 'strace' to trace programmes' system calls and signals
##############################################################################

	redirect
	
	for input:
to the right file of
		operator '<'.

	for output:
to the right file of
		operator '>'.
to the right
		file of operator '&>'.
to the right file of operator
		'2>'.
to the right file of operator
		'1>'.
##############################################################################

	fuser/lsof

	fuser: identifying processes that are using specific file
	lsof: list open files by specific process

	df : report disk usage of filesystem
	du : report disk usage of file

	fuser 8080/tcp, can list ther processes that listening on 8080 port.

##############################################################################

	remove dir,cmd 'rm' or 'rmdir'
	remove file,cmd 'rm' or 'unlink'
##############################################################################

	useradd,userdel,usermod

	add a user:
	sudo useradd username	// generate an item in /etc/passwd and /etc/shadow
							// in /etc/shadow,item 'username:*:...',field '*'
							// points out user 'username' can't login because 
							// lack of passwd.

	sudo passwd username	// then set a initial passwd for user 'username'

	sudo mkdir /home/username	// by default,/home/username is the home
								// folder for user 'username'.

	sudo chown username:username /home/username -R	// give user 'username'
													// proper authority to
													// access its home folder.
	
	we can use cmd 'adduser' instead to finish all operations mentioned above.

	delete a user:
		sudo userdel username	// home folder is left that need to be deleted 
		sudo rm -rf /home/username
##############################################################################
	Exception in thread "AWT-EventQueue-0" java.awt.HeadlessException: 
	No config0ost().
	config0X11 DISPLAY variable was set, but this program performed an
operation wxwidgets0Post().
	config0ost0hich requires it.
	config0cp#onPopupPost().

	solution:
		export DISPLAY=hostname:0.0
##############################################################################

	byobu bugs

	when edit files in vim within byobu,the speed is too slowly,especially
	when pressing 'tab' key.

	we'd better close byobu to edit in vim,then all the speed of
	'acp','snippet' and other plugins will be guaranteed
##############################################################################

	command line to operate network connection

	first,stop network-manager,'sudo service network-manager stop'.

	// for open or WEP encrypted access point
	
	sudo ifconfig wlan0 up		// start wlan0
	sudo iwlist wlan0 scan		// scan nearby wireless networks
								// choose wireless network and configure
	sudo iwconfig wlan0 mode ... essid ... key [open | num | s:passphrase]
	sudo dhclient -v wlan0		// to get a dynamic ip

	note:
		iwconfig only supports the wifi networks that are "open" unencrypted
		or "WEP" enabled.

		iwconfig doesn't support wifi networks that using "WPA/WPA2".
	
	// for WPA/WPA2 encrypted access point
	
	sudo ifconfig wlan0 up
	sudo iwconfig wlan0 mode managed
	
	wpa_passphrase ESSID PASSWORD > wpa.conf
	sudo wpa_supplicant -B -D wext -i wlan0 -c wpa.conf &> /dev/null
	sudo dhclient wlan0 -v

	// on ubuntu distro
	
	because the up-start service 'network-manager' take charge of all network
	interface,if we do manually as mentioned above for other distros,some
	exceptions may occur even though the service 'network-manager' has been
	stopped.

	we'd better use network-manager cmdline tools 'nmcli' to finish this task.

	nmcli con list		// list all avaiable network-connections,including
						// wired and wireless conns

	nmcli con up id ...	// id value,actually,is the conn's name
##############################################################################

	environment variable DISPLAY

set default display for current machine,take my thinkpad x61t as an
	example.
	
		i should add lines into /etc/profile,wait next reboot or source it.

			DISPLAY="localhost:0.0"
			export DISPLAY


if i want to run X-appliation that reqire connection with X-server

		if i want to run x-application on remote machine,i should set DISPLAY
		to 'remoteHostname:0.0'.

		example:
			ssh $USERNAME@10.42.0.1
			cd ~/Videos/MV
			DISPLAY=fm:0.0
			export DISPLAY
			totem MvFileName
			
, actually, set DISPLAY to 'hostname:0.0',but when the
	given hostname is current machine's hostname,the hostname will be set to
	'localhost'.

	hostname can be set to IP.
##############################################################################

	desktop environment:
		gnome
		gnome classic
		gnome classic ( no effect )
	
	run cmd 'apt-get install gnome-shell'

	if you want to install gnome classic only,just install
	'gnome-session-fallback'
##############################################################################

	*.jar file 

	mv *.jar *.zip
	unzip *.zip

	or:

	jar xvf *.jar

	then,we can get the *.class file,and use 'javap' we can check the
	className and function from *.class file.
##############################################################################

	disable the notification bubbles

	the best method i found out is :
kill process 'notification-daemon'
sudo apt-get purge notification-daemon

	this method let me remove the package notification-daemon but reserve
	package gnome-fallback-session.
##############################################################################

	cmd_1 && cmd_2	: only cmd_1 is successfully executed,can cmd_2 be
	executed.

	cmd_1 || cmd_2  : only cmd_1 fails,can cmd_2 be executed.
##############################################################################

	/ : slash
	\ : backslash
##############################################################################

	sort -t'delimiter' -kFieldNO -f -r
##############################################################################

	tee 
	copy pipe data stream,one portion will be output to stream 'stdout',the
	other portion will be output to specified file.

	example:
		ls | tee ls_result
##############################################################################

	execute shell script
./filename
bash filename
source filename
##############################################################################

	find findPath -name pattern

	specify findPath before find,you don't have to change work-directory to
	the root '/'
##############################################################################

	a=1
	b=2
	c=$a+$b--->c=1+2--->treat $a+$b as the string operation
	c=$(($a+$b))--->c=3--->treat $a+$b as number operation

	if you want number operation,put the expression within $((...))
##############################################################################

	array in shell script
	
	example:
	array=(aa 'bb cc' dd)
---> aa
equals ${#array[@]}, its value is 3, the length of array.
	${#array[0]),its value is 2,the length of first element 'aa' in 'array'
	note:
		for ele in "array"--->on this case,"array" will reserve the former
		structure of "array",(aa 'bb cc' dd).

		for ele in array--->on this case,array's former structure is
		broken,(aa bb cc dd).
##############################################################################

	update-rc.d serviceName { start | stop } priorityNum runlevels
	
	example:
		update-rc.d cups start 80 2 3 4 5 . stop 80 1 6
##############################################################################

	/etc/sudoers

	example:
		Cmnd_Alias LDAP = /usr/bin/ldapadd, 
						  /usr/bin/ldapdelete, 
						  /usr/bin/ldapmodify
		Host_Alias = 
ip address
ip/netmask
		User_Alias = bob, tom, lucy
		Runas_Alias = 
			it is similar to User_Alias
		
		format:
Cmd1,Cmd2,...,Cmdn
	
	note:
		we must set a passwd for account 'root',then modify user privileges
		within file '/etc/sudoers':
ALL 
		then we can use 'visudo -cf /etc/sudoers' to parse this configuration
		file to check whether it is syntax right.  'su' is allowed now.
##############################################################################

	ls --hide=pattern
	ls --ignore=pattern (or ls -Ipattern for short)

	doesn't list the file entries that match the pattern
##############################################################################

	umask is used by open and mkdir
##############################################################################

	harddisk volume < 2TB : install Windows MBR partition table
	tools: cfdisk or fdisk

	harddisk volume > 2TB : install GPT partition table
	tools: parted
##############################################################################

	format Udisk

sudo fdisk /dev/sdb
'd' to delete specified partition
'n' to add new partiton
'w' to write partition table
'q' to quit
##############################################################################

	dump: bakup files or filesystems for ext2/3/4
	restore: restore files or filesystems backuped with dump
##############################################################################

	ipcalc: calculate the network and host

	example:
		ipcalc 192.168.1.1 255.255.0.0
		or
		ipcalc 192.168.1.1/16

	output:
		Address:   192.168.1.1          11000000.10101000. 00000001.00000001
		Netmask:   255.255.0.0 = 16     11111111.11111111. 00000000.00000000
		Wildcard:  0.0.255.255          00000000.00000000. 11111111.11111111
		=>
		Network:   192.168.0.0/16       11000000.10101000. 00000000.00000000
		HostMin:   192.168.0.1          11000000.10101000. 00000000.00000001
		HostMax:   192.168.255.254      11000000.10101000. 11111111.11111110
		Broadcast: 192.168.255.255      11000000.10101000. 11111111.11111111
		Hosts/Net: 65534                 Class C, Private Internet
##############################################################################

	for ssh issue 'refused to connect'

	solution: remove /home/USERNAME/.ssh/known_hosts,then retry again
##############################################################################

	LVM means what?
	no volume groups found?
##############################################################################

	thindpad x61t:
	press "F1" to enter BIOS configuration when startup
	use "USB-HDD" to boot up the machine when using Udisk
##############################################################################

	how to identify the dependencies and reverse dependencies

	use 'apt-cache'
	apt-cache depends packagname
	apt-cache rdepends packagename
##############################################################################

	set cursor blink frequency:

	cursor_blink_time	: gconf-editor,set its value to 300 miliseconds
##############################################################################

	set text-mode terminal font:

	sudo dpkg-reconfigure console-setup	: choose font 'VGA'
##############################################################################

	reinstall package:

	sudo apt-get --reinstall install packagename
##############################################################################

	libpeerconnection	: modify /opt/google/chrome/google-chrome

	# create libpeerconnection within directory /tmp
	cd /tmp

	exec -a "$0" "$HERE/chrome"  "$@"
##############################################################################

update-alternatives
sudo update-alternatives --config "masterLinkName"
sudo update-alternatives --install "link" "masterLinkName" "path" priority

maybe,to change the environment variable PATH in .bashrc is a better way.
##############################################################################

install java plugins for chrome:
bad way:

	ln -s /usr/lib/jvm/jdk-1.7.0_25-oracle/jre/lib/i386/libnpjp2.so
	~/.mozilla/plugins

good way:

	cd /opt/google/chrome
	mkdir plugins
	cd plugins
	sudo ln -s /usr/lib/jvm/jdk-1.7.0_25-oracle/jre/lib/i386/libnpjp2.so
	./plugins/

best way

add-apt-repository to install oracle java.
this method will modify the default jre which other packages may depend on
from openjdk to oracle java.

this way may come more up to our want.
##############################################################################

LaTex /leiteks/

it is a document markup language,not refer to an application
#######################################/////////

qBittorrent : 
 
in fact,this software uses search engine btdigg.org
##############################################################################

	ctags generate tags for c/c++/qt4

	ctags --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++

	for c glibc/kernel:
		ctags --C-kinds=+dfgm --language-force=C -R .
	for user c files:
		ctags --C-kinds=+dfglm --language-force=C -R .

	note:
		please don't use ctags Ctrl+] to refer to header files. it doesn't
		work well, but we can use TTlistToggle to browse the headers and open
		it, then we can use Ctrl+\ to jump back.
##############################################################################

	format codes

	tool: indent
	indent -kr -i4 filename.c
##############################################################################

	gdb common cmds:

	start
	run
	quit

	finish			-- continue running until current function finishes
	backtrace(bt)	-- list function calls as stack frame
					   bt cmd is usually used to fix segmentation fault

	frame(f)		-- select stack frame
locals	-- list local vars and their values

	list(l)			-- list following 10 lines
	list lineNO.
	list funcName

	next(n)			-- next
	step(s)			-- step(into)
	continue(c)		-- continue running until a breakpoint is encountered

	print(p)		-- print value of var for this time
	display			-- print value for the following every time
	undisplay
	x/7b			-- one byte one group,print 7 groups
					   x cmd print memory info

	watch			-- display old and new value when var's value changes
					   this kind of vars are called watchpoints
	info watchpoints
		
	break(b)
	break if(b if)
	info breakpoints	
	delete breakpoints
	disable breakpoints
	enable breakpoints


	set Var			-- change value of var
##############################################################################

	objdump -dS ObjFile

	note: 
		this ObjFile must be compiled with -g option,-g option need the source
		code existing.  -S option implies that -d option is specified,and this
		-S option need the source code existing,too.

	display assembling language and c language in mixed mode.
	this is a good way to learn assembling language

	*****************

	gcc -S filename.c

	this method also lets you view the matched assembling language code.
##############################################################################

	nm, list symbols of object files

#######################################//////////

	1)check linux kernel version:  uname
	2)check linux distribution version: lsb_release
	  or you have to check file content:	
	  /etc/*-release or /etc/issue
##############################################################################

	manual bootparam is an introduction to all boot parameters;
	manual X is an introduction to X Window System.
##############################################################################

	centos,add parameter vga=0x34C to change vga resolution to 1366x768 when
	bootup
##############################################################################

	c programming,macro definition

# and ##
	#value --> "value"
	a ## b --> ab
length-variable parameter list
	...			: length-variable paramter list,used in function macro
	definition.
	__VA_ARGS	: reference to length-variable parameter list,used in function
	macro definition body.
	3)not all macros must be defined in *.c file
	using 'gcc -D' to define a macro
##############################################################################

	centos,install 'ncurses-devel',because 'make menuconfig' requires this
	package

	using 'make menuconfig' to generate '.config' file,
	using 'make' to compile needed modules into kernel, besides, it generates
	configuration info which is stored in autoconf.h,'autoconf.h' will be
	included in 'config.h'.

	ubuntu,install 'libncurses5-dev' instead of 'ncurses-devel'.

	note:
		when on different distros, some required packages' names may be
		different.
##############################################################################

gcc -E	:	stop after preprocess,generate *.i from *.c
gcc -S	:	stop after compile,generate *.s from *.i
gcc -c	:	stop after assemble,generate *.o from *.s
gcc		:	stop after link,generate executable file from *.o
##############################################################################

gcc -MM automatically generates the dependencies for all object files

how to build Makefile ?
gcc -MM *.c > Makefile	
	: this method only generate the dependencies for "headers"
   gcc -M  *.c > Makefile	
	: this method will generate the dependencies for <headers> and "headers"

recommend to adding lines:
|	all: main
|	main: obj1.o obj2.o obj3.o
|		gcc $^ -o $@

or

|	main: *.o
|		gcc *.o -o main
##############################################################################

make
make all
make install
make clean
		|---|
			|- we'd better declare 'clean' as a phony target, why need we do 
			|- this ? because target 'clean' has no prerequires, and, if a 
			|- file named 'clean' exists, cmds following 'clean:' will not be
			|- executed. add '.PHONY clean' to declare 'clean' as a phony 
			|- target.
.PHONY clean
make distclean

make -n : list cmds that will be executed but not execute them
make -C : entering directory and execute the Makefile within it
##############################################################################

linux assemble language,there're two types:
	AT&T,used by gcc.
	intel,used by official intel documentation and Microsoft.

differencies between AT&T and Intel formats:
AT&T,should add prefix % before registers.
AT&T,should add prefix $ before immediate operand. 
AT&T,should put source operand on the left,while destination operand on
	the right.  ...

linux assemble language compiler:
	NASM,using intel format

	nasm -f elf filename.asm
	ld -s -o filename filename.o
	./filename
##############################################################################

	system call 'open(pathname,flags,mode)' to create file,actually the
	created file's privilege is 'mode & (~mask)'.

	touch --> value of mode is 0666.
	gcc   --> value of mode is 0777.

	how to prove ? umask 0.
##############################################################################

	evince, a programme to view pdf, enable 'evince' to display Chinese
	characters

	install package 'poppler-data'
##############################################################################

	od
	dump files in octal or other formats

	example:
		od -t x1c filename

##############################################################################

	in-band and out-of-band transmission

	in-band:
		data flow and control flow are transmitted through the same
		connection.
	out-of-band:
		data flow and control flow are transmitted througn respective
		connections.
##############################################################################

	one network-adaptor can bind several IP address.
	several network-adaptors can be bond to one IP address.
##############################################################################

	install 2.6.32.61 kernel

	download linux-2.6.32.61.tar.xz
	tar xvfJ linux-2.6.32.61.tar.xz
	cd linux-2.6.32.61
	make menuconfig
	make
		:this step generates the 'vmlinuz'
	make modules 
		:this step build up modules and its dependencies
	make modules_install
		:install kernel modules
	make install
		:install kernel and generate initrd.img and update grub.cfg

	done!
##############################################################################

	dmesg

	use dmesg to view the info stored in kernel ring buffer.
##############################################################################

	uptime

	tell you how long the system has been running from startup
##############################################################################

	split: 分割文件，这个比较实用。
		  split -b 1m srcfile prefix,这条命令表示将文件srcfile以1m为约定尺寸，
		  将 其进行分割，分割后的文件将以prefix加上自动追加的编号命名。 split
		  -l，将按照行数进行分割。 split -c，与-b类似，按照字节数进行分割，但
		  是分割的时候尽量保持行的完整性。
##############################################################################

	dd： 主要是从文件或者设备读取信息，然后输出到设备或者文件。功能相当强大，
		 可以用来拷贝文件/备份磁盘数据/备份恢复mbr等等。
##############################################################################

	ps aux | grep zhcon
	pgrep zhcon

	note:
		pgrep can get the pid of specified process
##############################################################################

	add hotkeys to run a new shell in vim

	add line in ~/.vimrc:
	map <Leader>r :sh<CR>
	
	note:
		<Leader>r, this manner, after you type in <Leader>r, vim will keep
		waiting for some more typed 'keys', so you can obviously feel there' a
		delay before 'sh' is executed.

		why ? 

		because in vim default configuration, some combinations of <Leader>r
		and other keys have been defined, so vim has to wait to avoid
		neglecting some hotkeys.

		how to solve this problem ?	--|
									  |
	map <Leader>rr :sh<CR>	<---------|

	if you don't want to display the cmd, add <silent> as following:
	map <silent> <Leader>rr :sh<CR>
	
	done!
##############################################################################

route -n
.../.. | .. gw ... metric .. device
.../.. | ..
####################################################

/etc/passwd:
	loginname:password:uid:gid:username:homefolder:shell
	password field is set to x.

/etc/shadow:
	loginname:encryptedpassword:lastchange:.......
##############################################################################

ping : send ICMP echo_request to network hosts and wait for the echo_reply.

-c :count
-f :flood ping
-i :interval
-D :time
-s :packet size
	why 8 bytes added to the specified size ?
	because size of ICMP header data is 8 bytes.

	ICMP header format ???
-t :time to live,>=1
-b :allows ping a broadcast address
##############################################################################

tcpdump : dump packets on interface

-D
-d
-e
-i :interface
-K
-l
-q
-S
-X :it's very handy
-A :display data in ascii

-w :store captured packets into file
-r :read packets data from file

filter options:
dst host
src host
host
port
tcp
udp
...

how to extract the username and password or other something ?

when we submit something, for example, a username, the server side will
respond to the client side with status code.  around the status code, there
may be something which you will be intersted in.
##############################################################################

convert from ascii to hex:
	
	hexdump -x
	od -x

convert from hex to ascii:

	echo -e "\xHH\xHH\xHH\xHH"

convert hex to decimal:
	
	echo $((0xaa))
##############################################################################

cache dns records

in ubuntu 12.04, dnsmasq is built into network-manager and it'll be started
when network-manager is started.  but dnsmasq defaultly is set to disable the
dns-cache function, you can find the evidence from /var/log/syslog.
##############################################################################

w3m hotkeys

H:		display help messages
U:		go to url
B:		back to previous buffer
s:		pop up buffer selection window
v:		show html source code
Esc-s:	save current html source file into file
S:		save buffer into file, the buffer refers to the terminal
C-l:	redraw screen

##############################################################################

dig: to lookup dns record

dig hostname [option list]

+short
+nocomments		+comments
+noauthority	+authority
+noaddtional	+additional
+nostats		+stats
+noanswer		+answer
+noquestion		+question
+noall

"dig hostname +nocomments +noauthority +noaddtional +nostats +noquestion"
is equivalent to
"dig hostname +noall +answer".

-t soa
-t a
-t ns
-t mx
-t any
-t cname ??? acutally, non-existent

-x ptr, reverse lookup for PTR record
   how does reverse lookup works ???
   what does AAAA record mean ??? a record resolves hostname to a IPv6 address
   in DNS

@dnsserver to use a specified dns server for lookup
example:
	dig @202.12.27.33 redhat.com -t ns +noall +answer
	202.12.27.33 is one of the 13 root domain name servers, and it's deployed
	in Japan.

-f to use data file to query several websites
example:
	dig -f filename -t ns +noall +answer

you can also query several websites in one command line, do it as following:
	dig hostname1 -t type1 [option list] hostname2 -t type2 [option list]
example:
	dig redhat.com -t ns +noall +answer centos.org -t a +answer

~/.digrc
	add options within this file to set the default query options.
example:
	append text '+noall +answer', then next time when you start dig, options
	'+noall' and '+answer' will be automatically appended to the cmd option
	list, but these options won't be displayed.

##############################################################################


nslookup, using interactive mode to lookup is very convenient.

common interactive cmds:

server: specify a domain name server
host  : spefify a hostname that you want to lookup, usually host cmd can be 
		neglected, i.e, you can directly type in the hostname.
set q=type:
		set the query type, ns/a/cname/mx/ptr/soa.

set q=ns, then type '.' to display all 13 root domain name servers.

exit  : exit programme
##############################################################################

for CNAME record:

usually we think the format of CNAME record is :
|| Alias Hostname | CNAME | Canonical Hostname ||
but actually, it may be not set as you supposed, for example, the right-hand
field 'Canonial Hostname' may not a canonical name but another alias hostname,
this leads to so-called 'alias chain' or 'alias cycle'.

so, you may not be able to use one single lookup through all CNAME records to
find out the canonical hostname.  but, among all presented alias chains, we
can pick out the right side hostnames and put them together, all of them must
appear in the alias chains in some order, so we can find out which of them is
the canonical hostname by comparison.

if 'alias cycle' among CNAME records occurs, CNAME type query should respond
an error message.
##############################################################################

for PTR record:

the best option is to resolve the IP address to the Canonical Hostname.

rfc doesn't point out dns must implement the reverse query, it is optional.
if the dns receives an unsupported query request, it should respond an error
message.

rfc doesn't require we must set only one PTR record for the same one IP address.
so, some people may set multiple PTR records on the same on IP address.
it is not reccommended !
why ?
first, if we set multiple PTR records for the same one IP address. amony of
the multiple PTR records, several alias hostname and canonical hostname are
contained. when an PTR type request comes, dns works in round-robin for
load-sharing, and the PTR records matched are resorted in round-robin and then
responded to your client programme. usally, the programme select the first PTR
record and resolve the IP address to the hostname.
if the resolved hostname is an alias hostname, when we access it, something
wrong may happen if some other hosts has an same alias hostname. it leads
to a problem, Hosts : IP = n : 1, it is unacceptable.
so, as mentioned above, one IP should always be resolved to the canonical
Hostname.

so, dig -x, usally can  resolve the IP address to the Canonical Hostname.
while, nslookup -cname, can process ordinary "alias | cname | canonical"
format CNAME record, 'alias chain' and 'alias cycle' format CNAME records
to find out the Canonical Hostname.

dig can't directly lookup the Canonical Hostname with the Alias Hostname
through CNAME type records.  you have to lookup the A type record to find out
the IP address, then lookup the PTR type record to find it.

note:
	one IP address should have only one PTR record.
	but one domain, such as 10.in_addr.arpa, can have several PTR records,
	because one domain, i.e, one network, can have multiple gateways.

##############################################################################

A checksum or hash sum is a small-size datum computed from an arbitrary block
of digital data for the purpose of detecting errors that may have been
introduced during its transmission or storage.  The actual procedure that
yields the checksum, given a data input, is called a checksum function or
checksum algorithm.

checksum can be used to check the data's integrity, but it can't be used to
check data's authentication.  we should use hash function to check whether
data has been changed.

if data is changed, maybe the checksum stays the same, but the hash value is
largely sure to change.

checksum tools:
	cksum

hash tools:
	'md5sum'
	is equivalent to
	'openssl dgst -md5'
##############################################################################

	shell script

	num=1
	num=$((${num}+1))
##############################################################################

match in vim:

.	match only one character
.*	match characters more than one
##############################################################################

	nm: list symbols from object files.
	gdb: disas /m
	objdump -S
##############################################################################

	64-bit computing

	in computer architecture, 64-bit computing is the use of processors that
	have datapath widths, integer size, and memory addresss widths of 64 bits. 

	also, 64-bit CPU and ALU architetures are those that based on registers,
	address buses, or data buses of that size. 

	from the software perspective, 64-bit computing means the use of code with
	64-bit virtual memory address.

	computer artechture    : function
	computer composition   : logical implementation
	computer implementation: physical implementation

	uname -m: machine hardware name 
	uname -p: processor type
	uname -i: hardware platform ( supported hardware platform by current
			operating system, implicitly indicating the current operating
			system type )

means the cpu family, 'cat /proc/cpuinfo',
	if the 'cpu family' is 6, it is i686, similar for 3, 4, 5.

	process type means the same as the machine hardware name.
##############################################################################

tcp_wrapper,what's this?tcpd?	*
it's a facility for access control of internet services

inet,what's inetd?
there's no /etc/inetd.conf file.
after you install iputils-inetd, you can use 'update-inetd' to configure
/etc/inetd.conf to control the Internet Services.
##############################################################################

how to configure /etc/hosts.allow and /etc/hosts.deny?	
daemon-list : client-list [ : shell command list ]
##############################################################################

shell redirect
1>&2
2>&1
&>/dev/null
##############################################################################

ssh-keygen

generate rsa public and private keys
##############################################################################

ssh redirect

local port redirect, aims to access remote host through local port

ssh -L localPort:remoteHost:remoteHostPort remoteHost
telnet localhost localPort

note:
ssh -p specifies the port that will be used by the ssh server on remote host.
ssh -D specifies the port that will be used by the ssh client on local host.

	providing ssh server on remote host uses port PORT-R, and ssh client on
	localhost uses PORT-L, then ssh local port redirect works as following:

	ssh creates a connection between PORT-L and PORT-R to communicate with ssh
	protocol.

	ssh on the local host redirects input from stdin to 'PORT-L', and
	encrypted the message, then send the message to PORT-R on the remote host,

	ssh on the remote host receives the message from PORT-R, and unencrypted
	the message, then redirects the message to remoteHostPort.

remote port redirect, aims to access local host through remote host
ssh -R remoteHostPort:localhost:localPort remoteHost
on remote host:
telnet localhost remoteHostPort
##############################################################################

lo, loopback interface

loopback is used to test local host' IP stack to check whether it is normally
initialized.
##############################################################################

cmd:

echo zzjie_scu | base64
enpqaWVfc2N1Cg==

echo justdoit9497 | base64
anVzdGRvaXQ5NDk3Cg==

when i telnet the smtp.163.com and request the authentication, i always
failed.
why?
i used the online base64 app to code the string zzjie_scu and the result was
enpqaWVfc2N1.
by comparison, i found 'Cg==' was appended when i executed 'echo zzjie_scu |
base64'.
then i wanted to see what did 'Cg==' mean.
i executed 'echo Cg== | base64 -d', then i found out it means a newline
character.
so i realized i should add option '-n' to delete the trailing newline
character when using echo.
the right cmd is 'echo -n zzjie_scu | base64'.
##############################################################################

telnet, send emails

telnet smtp.163.com 25
helo hhhh
auth login
base64-username
base64-passwd
mail from:<username1@163.com>	: can't masquerade
rcpt to:<username2@domain>		: one recipient, one 'rcpt to:<...>'
data
from:							: masquerade from, to and subject for
								: inexperienced computer users
to:
subject:
hhhhhhhhhhhhhhhhhhh
.								: end input
quit

note:
	for experienced computer users, they may check the source content, where
	they can check the 'Sender' to identify whom this mail comes from on
	earth.

telnet, receive emails

telnet pop3.163.com 110
user username
pass password
stat								: check mail status
list								: list emails
top emailNum lines					: display email's header
retr emailNum						: display email's content
dele emailNum						: delete email
quit
##############################################################################/

uninstall specified package and ignore the dependencies.

using dpkg, add option '--ignore-depends=packageNameIgnored'
example:
	gnome-tweak-tool depends on gnome-shell, if i want to uninstall
	gnome-shell and reserve gnome-tweak-tool, do as following:
	sudo dpkg -P --ignore-depends=gnome-tweak-tool gnome-shell
##############################################################################/

	lightdm and kdm	

	sometimes, lightdm can't login, then you can try kdm, then change the
	/etc/X11/default-display-manager to let the lightdm serve as the default
	one.
##############################################################################/

get the pid of specified process

cat /var/run/processName.pid
##############################################################################/

	ddrescue
	with the help of 'ddrescue/gddrescue', i rescued the video data in dvd
##############################################################################/

	in codeblocks environment configuration:

	gnome-terminal -t $TITLE -x
	instead of
	xterm -T $TITLE -e
##############################################################################/

	check tty configurations

	stty -a
##############################################################################/

for static archive:
ar
	c: create
	r: insert into archive with replacement
	v: verbose
	q: quick append

	ar crv lib-name *.o
	note:
		the archive name must be prefixed by 'lib', or the lib won't be found 

	example:
		main.c add.c minus.c headers.h
		
gcc -c add.c
		   gcc -c minus.c
		   gcc -c main.c
ar crv libfunc.a add.o minus.o
gcc -o main main.o -L. -lfunc	(when linking)
		   gcc -o main main.o libfunc.a		(when linking)

		   gcc -o main main.c -L. -lfunc	(when compiling)
		   gcc -o main main.c libfunc.a		(when compiling)
		4)./main


for dynamic archive:
ldd:
	to check the shared libraries that needed by specified programme
gcc -shared
	to generate the *.so
	
	example:
	main.c add.c minus.c headers.h

gcc -c add.c
	   gcc -c minus.c
	   gcc -c main.c
gcc -shared -o libfunc.so add.o minus.o
gcc -o main main.o -L. -lfunc		(when linking)
	   gcc -o main main.o libfunc.so		(when linking)

	   gcc -o main main.c -L. -lfunc		(when compiling)
	   gcc -o main main.c libfunc.so		(when compiling)

	   before running, set the environment variable LD_LIBRARY_PATH
	   you'd better set it up within .bashrc
	
gcc:
	-L: the lib directory that to be searched
	-l: link the lib-name

##############################################################################/

	notify-send	"msg"
##############################################################################/

	ns2: Network Simulator 2

	nam: Network AniMator
##############################################################################
	disable event sound

	edit *sound*xml	in /usr/share/glib-2.0/schemas.
##############################################################################
disable animation on panel-bar

by default, the animation is displayed. for example, i put a chrome icon on
the panel-bar in order to launch it more conveniently, but when i launch it,
it will display an animation which sometimes makes me sick.  

how to disables it ?
edit file /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml,
to disable 'enable-animation', don't forget to exec 'glib-compile-schemas .'.
##############################################################################
	install and configure LXR	

	LXR is short for 'Linux Cross Referencer', it is a nice tool to read source
code, it worths trying.

	install:
download the lxr-<x.x.x>.tar.gz.
unpack the tar.gz file.
read the 'INSTALL' file within directory lxr-<x.x.x.>/doc, and do as it
	says.

	ok, i will simply summarize the points that you have to pay attenttion.

install perl interpreter (>=5.10), then exec 'perl -v' to check whether
	you have installed it correctly.

intall exuberant	ctags (>=5.0), then exec 'ctags-exuberant --version'
	to check whether you have installed it correctly.

install a relational database, such as mysql, so you should try to
	install several packages, including mysql-client, mysql-server, ...  after
	installed, try to check whether you can connect to mysql server normally,
	and the privileges of user root.

install a web server, such as apache2. after installed, fire your
	browser at http://localhost to check whether it works normally.

	install apache mod_perl, sudo apt-get install mod_perl.

install swish-e for freetext searching, you can download the package
	from offical site and install it manually, or you can use apt package
	manager to finish that, you just need exec 'sudo apt-get install swish-e'.
	then exec 'swish-e -V' to check whether it runs normally.

	or:
	download and manually install it, pay attention to its dependencies.

can be installed instead of swish-e.

	remark:
	if you just want to browse source code, you needn't installing swish-e or
	glimpse, but if you want to search some keyword or references, swish-e or
	glimpse should be installed to help building the index.

and relevant drivers
	(database driver, DBD). you can download it from the offical site and
	install it manually.  or, you can use apt package manager to install them.
	just exec 'sudo apt-get install libdbi-perl' and 'sudo apt-get install
	libdbd-odbc-perl'. i used the first way, if you fail, try the other one.

	or:
	sudo yum install 'perl-DBI.x86_64'
	sudo yum install 'perl-DBD-MySQL.x86_64'
	sudo yum install 'libdbi-mysql.x86_64'


install perl file mmagic module, download it from official site, or use
	CPAN, or use apt to exec 'sudo apt-get install libfile-mmagic-perl'.

download the lxr-<x.x.x>.tar.gz from the offitial site.

unpack it to /usr/local, and rename it from lxr-<x.x.x> to lxr.

cd /path/lxr, and exec './genxref --checkonly' to check whether the
	nessessary components have been installed and detected.

configure LXR and the database.
	after installation, this step is also frequently used, so you must pay
	attention to master it.
exec './scripts/configure-lxr.pl', it is an interactive script, so
		you can configure it conveniently, sometimes, you may be confused,
		don't be upset, try it again and again until you make it.

		
after configuration, some configuration files will be generated
		according to the template files within /path/lxr/templates, these
		configuration files will be put into /path/lxr/custom.d, and .htaccess
		will put into /path/lxr.

		as i have checked, file .htaccess doesn't need to be modified, but
		file 'apache-lxrserver.conf' and 'lxr.conf' need modifying. maybe it
		is a bug of /path/lxr/genxref, why do i say so? 
		when it prompt for the hostname, you type '//localhost' or
		'//127.0.0.1', but the configuration is "hostname==>http://l" or
		"http://1" both in the two files listed above. check it and correct it.

		after modification, put /path/custom.d/lxr.conf to /path/lxr, and put
		/path/custom.d/apache-lxrserver.conf to /etc/apache/conf.d.

also, you must change the line 'NameVirtualHost *' to
		'NameVirtualHost localhost', and the line '<VirtualHost *>' to
		'<VirtualHost localhost>', and the line 'ServerName l' or 'ServerName
		1' to 'ServerName localhost' or 'ServerName 127.0.0.1'.

		or you can adopt other more intelligent techniques, reference 'Apache
		Configuration' in my QZone.

ok, all modification is done, then issue './custom.d/initdb.sh', it
		will create the database user $dbuser with root, then create the
		tables with $dbuser.
	
generate the index. fire the following command, this process of
		building index may takes a long time, so sit down and play something
		else.
		'./genxref --url=http://$hostname/$sectionname --treename=$treename',
		you can add other options, such as '--version=$version', actually,
		'$version' is the name of subdirectory  of your source directory.
		'--reindexall' may be another useful option.

after the process of building index finished, fire your browser at
		'http://$hostname/$sectionname/source' to check your source tree. you
		can browse the code now.

		pay attention, accessing 'http://$hostname/$sectionname' will throws
		an error of 'do not have  permission to access $sectionname on this
		server'. 
		please and be sure to use 'http://$hostname/$sectionname/source'
		instead.

Enjoy !
##############################################################################
/etc/motd, motd, is short for 'Message of The Day'.
login message /etc/motd is regenerated based on file /etc/motd.tail. by
default, this file doesn't exist on system, so create /etc/motd.tail manually.
##############################################################################
change the preprompt message before login, edit /etc/issue and /etc/issue.net.
##############################################################################
time 'program' to check 'realtime, userspace-time, kernelspace-time'
##############################################################################
	vim:
	1. verbose set fo
		list last configuration for option 'formatoptions'
	2. ~/.vim/after/[ftplugin]/filetype.vim will be executed by vim. a text
	file without specifying modeline or extension name, then it will be
	treaded as 'conf' filetype, so /usr/share/vim/vim72/ftplugin/conf.vim will
	be executed.

		a better method is, we specify modeline at the top or end of file to
	specify the filetype, then we put a new configure file into 
	~/.vim/ftplugin/filetype.vim, in filetype.vim, we can do some settings.

		if we specify // vim: ft=text in file, then vim will search and 
	then execute:
	/usr/share/vim/vim72/ftplugin.vim, 
	then:
	/usr/share/vim/vim72/ftplugin/text.vim,
	then:
	~/.vim/after/ftplugin/text.vim.

	pay attention, it is ~/.vim/after/ftplugin rather than ~/.vim/after/plugin.

	3. modeline has 2 forms:
		such as:
			// vim: ft=text
			/* vim: set ft=text: */


#############################################################################

RHEL Configuration:

	1. install acpi_call module
	tar acpi_call-master.zip
	cd acpi_call-master
	make
	cp acpi_call.ko /lib/modules/.../acpi
	sudo depmod
	sudo vim /etc/sysconfig/modules/acpi_call.modules
		content:
			#!/bin/sh
			
			if [ ! -c /sys/module/acpi_call ] ; then
				exec /sbin/modprobe acpi_call >/dev/null 2>&1
			fi
	sudo chmod a+x /etc/sysconfig/modules/acpi_call.modules

	2. replace rhel repo with centos repo
	sudo rpm -qa | grep yum | xargs rpm -e --nodeps
	sudo rpm -e python-iniparse

	download python-iniparse, yum-metaparser, yum-3.xxx, and
	yum-plugin-fastestmirror.xxx.

	sudo rpm -i python-iniparse
	sudo rpm -i yum-metaparser
	sudo rpm -i yum-3.xxx yum-plugin-fastestmirror...
	
	sudo rpm -i Packagekit-...
	
	troubleshooting 'subscription manager':
	sudo rpm -qa | grep subscription | xargs rpm -e --nodeps

	copy CentOS repos, rpmforge repos, ... into /etc/yum/yum.repos.d/.
	yum makecache

	troubleshooting 'YumRepo Error: All mirror URLs are not using ftp, http[s]
	or file': edit /etc/yum/yum.repos.d/*, change $basearch to x86_64, change
	$releasever to 6.  then yum makecache, ok.
	
	download and import the gpg public key, yum will use it after downloading
	and installing packages.

	3. add thirdparty repos
	rpmforge
	epel
	rmi

	4. win+e, open places 'home'
	edit->preferences->behavior->check on 'always open in browser window'.

##############################################################################
RHEL: dracut
Ubuntu: update-initramfs

dracut, update-initramfs will replace of mkinitrd to generate
initramfs-<version>.img, but the kernel dump file is still the form
initrd-...-kdump.img.
##############################################################################
RHEL httpd:

1.
run hostname: it displays localhost.localdomain, but in /etc/hosts, it wrote:
127.0.0.1 localhost localhost.localdomain, localhost.localdomain should be 
the alias of canonical hostname, but why 'hostname' cmd displays the latter one.

actually, /etc/sysconfig/network, in this file, there's one configuration options,
HOSTNAME=localhost.localdomain, so i think, priority of this file is larger than
/etc/hosts.
so edit /etc/sysconfig/network, change from localhost.localdomain to localhost.

2. when making httpd autostart when system bootup, it says 'temporary failure
in name resolution www.dev.com', i don't know why? i have add it into
/etc/hosts, like:
127.0.0.2 www.dev.com, but why?
this failure occurs when i add 'Listen www.dev.com:80' in httpd.conf, so i
changed it to 'Listen 127.0.0.2:80', but the failure is still there.

there're several 'Listen' cmds in /etc/httpd/conf/httpd.conf, so i changed it
to 'Listen 80', after this modification, httpd start normally.

oh, i nearly forget, 'ServerName' must be unique.
##############################################################################
6. vim modeline

##############################################################################
RHEL install openshot

1. Download the *latest* nux-dextop-release rpm from
http://li.nux.ro/download/nux/dextop/el6/

2. Install nux-dextop-release rpm:
	rpm -Uvh nux-dextop-release*rpm
3. Install openshot rpm package:
	yum install openshot

4. update your ffmpeg
sudo yum install ffmpeg, ffmpeg will be updated because of the dependencies
to nux-dextop.

what a pity! openshot can't start successfully, ah, forget it!
##############################################################################
RHEL loglevel

when rhel boots, it will generates an warning or error message on the console,
just like 'pnp,...cannot evaluate crs 8', it is relevant to the acpi. i can't
figure it out how to fix it, so i just disable the message output, how do
realize it? 
append loglevel=N to the kernel boot parameters to control which kind of
messages can be logged. i set it to loglevel=3, then loglevel 3,4,5,6 will be
logged.
what is intereting is that rhel loglevel is contrary to the log4j.
in rhel, higher priority loglevel has a lower number, for example, 3<4,
loglevel 3 has a higher priority than loglevel4. when you set loglevel=3,
messages of loglevel4 will also be logged.
while in log4j, FATAL has a higher priority than INFO, when you set log level
FATAL, messages of INFO will be ignored.
##############################################################################
RHEL generate splashimage *.xpm.gz

there's a cmd tool called 'convert', it can convert an image to xpm format,
for example:

	convert palm.JPG 
		-resize 640x480 -colors 14 -depth 16 -normalize -verbose palm.xpm
then compress it:
	gzip palm.xpm
put 'palm.xpm.gz' to /boot/grub, and change the splash option in grub.conf.
reboot to see the effect!
##############################################################################
RHEL snmpconf

using cmd tool snmpconf to configure snmp.conf\snmpd.conf\snmptrapd.conf, it
is very convenient!
##############################################################################
when exec 'git commit', 'Error detected while processing
/home/$USERNAME/.vimrc', unknown options ....

	git config --global core.editor vim
##############################################################################
exec vim, type ':help', it reports an error, 'no help for help.txt'.
reinstall all vim relevant packages, then it will be solved.
i think, maybe, this error is caused by bleachbit cleaning.
##############################################################################
gnuplot
using gnuplot to draw, such as drawing following functions:
log2(x), x^0.5, x, x^2, x^3, 2^x, x!

exec gnuplot, enter interactive mode:
> set xrange [1:25]
> set yrange [1:10000]
>
> log2(x)=log(x)/log(2)
> set sample 1000
title 'log(n)'
> replot x**0.5 title 'n^0.5'
> replot x ttle 'n'
> replot x**2 title 'n^2'
> replot x**3 title 'n^3'
> replot 2**x title '2^n'
> set sample 25
> replot floor(x)! title 'n!'
>
> set yrange [1:500]
> replot
##############################################################################
/etc/yum.repos.d/xxx, enabled=1 is default value.
##############################################################################
file cmd, can be used to determine file type.
##############################################################################
install Gnu binutils to operate binary files, such as we can use 'readelf' cmd
to read and display elf part of Binary Object Files.
##############################################################################
install gtk+-2.24.23.

recently, i found a very good programme named gtkqq on github, i want to study
it and the webqq protocol.
so i clone it, but when i build it, i found there's no apropriate gtk+
installed. it requires at least gtk+-2.24.23, rhel 6.5 has gtk+-2.20.1
installed, and there's no proper rpm package to install, i have to manually
installed from the source.

from the INSTALL file of gtkqq, we know it needs following prerequisites:
	1)glib 2.28.0					: manually install
	2)pango 1.20					: rhel repo
	3)atk 1.29.2					: manually install
	4)gdkpixelbuf 2.21.0			: manually install
	5)cairo 1.6.0					: rhel repo
	6)gobject-introspection 1.6.0	: rhel repo

	please install the prerequisites as the listed order mentioned above, when
	installing, maybe some other packages you should install.

has been installed, configure your .bashrc to export
	environment variable:
	PKG_CONFIG_PATH=/opt/gtk/lib/pkgconfig:$PKG_CONFIG_PATH 
	LD_LIBRARY_PATH=/opt/gtk/lib:$LD_LIBRARY_PATH
	export PKG_CONFIG_PATH
	export LD_LIBRARY_PATH

	then configure\make\make install gtk+-2.24.23.

	ok, gtk is installed successfully, and gtkqq is compiled successfully, but
	it can't run successfully.

##############################################################################
configure ANT_HOME env var.

my rhel has installed eclipse IDE from repo, and ant is installed with
eclipse. version of ant is 1.7.1, but i want to install a higer version of
ant, so i download 1.9.4 from apache offical site, then i unpack it to
/opt/apache/ant, and add /opt/apache/ant/bin to PATH env var.
i am sure /opt/apache/ant/bin appears before the /usr/bin, so i am sure
/opt/apache/ant/bin will be run when i type ant in terminal. but when i type
'ant -version', it still output 1.7.1, but i can see /opt/apache/ant/bin/ant
has been run with the help of cmd 'hash', so i use strace to trace the open
files, i find it open /etc/ant.conf to read ANT_HOME var's value, i realized
maybe i have to configure ANT_HOME env var in ~/.bashrc, after i did that, it
works.
##############################################################################

vim, change from lowercase to uppercase:
1)enter visual mode and select text
2)U/u

vim, jump to the matched brace: %

##############################################################################

搜索字符串用的是正规表达式(Regular expression)，其中许多字符都有特殊含义：
\        取消后面所跟字符的特殊含义。比如 \[vim\] 匹配字符串“[vim]”
[]       匹配其中之一。比如 [vim] 匹配字母“v”、“i”或者“m”，[a-zA-Z] 匹配任意字母
[^]      匹配非其中之一。比如 [^vim] 匹配除字母“v”、“i”和“m”之外的所有字符
.        匹配任意字符
*        匹配前一字符大于等于零遍。比如 vi*m 匹配“vm”、“vim”、“viim”……
\+       匹配前一字符大于等于一遍。比如 vi\+m 匹配“vim”、“viim”、“viiim”……
\?       匹配前一字符零遍或者一遍。比如 vi\?m 匹配“vm”或者“vim”
^        匹配行首。例如 /^hello 查找出现在行首的单词 hello
$        匹配行末。例如 /hello$ 查找出现在行末的单词 hello
    括住某段正规表达式
\数字    重复匹配前面某段括住的表达式。例如 \(hello\).*\1 匹配一个开始和末尾都
		 是“hello”，中间是任意字符串的字符串

对于替换字符串，可以用“&”代表整个搜索字符串，或者用“\数字”代表搜索字符串中的某
段括住的表达式。

举一个复杂的例子，把文中的所有字符串“abc……xyz”替换为“xyz……abc”可以有下列写法：
:%s/abc\(.*\)xyz/xyz\1abc/g
:%s/\(abc\)\(.*\)\(xyz\)/\3\2\1/g
其它关于正规表达式搜索替换的更详细准确的说明请看 :help pattern

例如：在文本中搜索所有包含amount大于0的以[ ] 括住的字符串的行，如 “amount[123]
“,  ”amount[200]“ 等：

首先按 ：进入命令 模式，然后输入下面的串再回车开始查找：
/amount\[[1-9]\([0-9]*\)\+\]

解释如下：

/  表示进行串搜索, 其它字符为 正则表达式的内容

amount  表示匹配串包含amount

\[  转义字符，表示匹配左中括号 [

[1-9]  表示匹配一位1到9之间任何数字

  转义的左右括号，表示括住某段正则表达式，

表
	示 任意个0-9之间的数字

\]   转义字符 ]

分组匹配:
s/\(.*\)=\(.*\);/\2=\1;/g。
其中s/ / /g为搜索并替换的语法。\2,\1是引用用正则表达匹配到的分组。\( \)括起来
的是正则表达式分组匹配项，我这里将“=”之前的内容设为\1，将“=”号好“;"之间的内容
设为\2。

##############################################################################

想安装linux内核函数手册页，一般安装的时候，软件仓库中是不会提供这个包的，可以
下载linux内核源代码然后手动建立该manual。

1. 准备工作
1)下载内核源代码,或者直接yumdownload --source kernel下载rpm包,然后从中提取出
linux-4.1.xz;
2)安装xmlto,这个工具可以用来生成man格式的文档;

2. 开始建立手册
cd $linux-source-path
make mandocs
make installmandocs
这里也可以生成其他格式的手册,例如pdf格式的或者html格式的,分别执行命令make
pdfdocs或者make htmldocs即可.
手册会被安装到/usr/local/man/man9中去,然后就可以通过man 9来查看内核提供的函数
的帮助文件了。

3. 如何卸载呢?
如果不需要该内核man手册文档了,如何卸载呢?man格式的会被安装到
/usr/local/man/man9目录下,直接删除该目录就可以了.

##############################################################################

bakup/restore linux system

自从上了大学，买了电脑一共5个，其中一个台式机，4台笔记本，哈哈哈，当然了，4台
笔记本中有3台是二手，买来不是玩的，当然是为了学习。由于偏好ilnux操作系统，于是
乎在各个系统上安装配置linux就成了一件乐趣，但是慢慢地觉得配置系统是一件记为麻
烦的事情，于是我想了些办法，为的就是能够避免这种重复性的安装配置操作。

最初的时候我通过将配置文件进行备份，来解决复杂的配置问题，例如将vim、bash等的
配置文件上传到github上进行备份，以后每当重新安装系统之后就可以及时的将配置文件
恢复，这也算是一种巧妙的办法。

但是，后面发现即便是这样，重新配置系统也是非常低效的，于是，我希望能够将我现有
的系统做成iso文件，然后将其做成可以引导的启动盘，例如刻录到u盘里面，或者更大容
量的移动硬盘里面，这样每次换电脑时，或者希望在不同的硬盘间进行系统的安装配置时
，就可以通过安装直接完成。这样做的优势是，将常用的应用软件、配置文件都集成在一
起了，装上之后就是自己期望的操作系统，有点类似与windows下的gho文件，但是比较起
来，安装的速度仍然是稍微慢些，不过也可以接受。主要是同股remastersys进行，但是
这个程序也有些bug，对不同的发行版支持的程度不一样，备份出来的iso文件可能有错。

一段时间之后,发现系统的备份还原依旧是个问题，尤其是时间比较紧急，希望快速的完
成系统的备份、恢复时。也是为情势所迫，逼着我学习了下linux系统的备份、恢复，实
践证明效果是非常好的，赞一个！
具体的就是通过linux系统下提供的dump、restore这两个工具。
我当前学习的比较浅显，只是学习了文件系统的备份、还原，构造一个情景阐述下如何进
行操作，假如现在有两个硬盘，分别为A、B，现在A里面已经有一个linux操作系统了，但
是B里面没有，假定B里面现在有一个windows操作系统，我们现在希望将A里面的linux操
作系统拷贝到B中，我们可以按照如下步骤进行操作：
1）首先，我们需要将A中的linux操作系统备份，这里我们可以选择“文件系统备份”，这
样我们通过这个备份文件还原到B中的时候，原有的文件系统中的文件属性信息都会被保
留，这正是我们所希望的。假定A中的linux系统在/dev/sda3中，我们通过如下命令进行
文件系统级别的备份:

	首先通过这条命令检查下生成的备份文件的尺寸，以便于我们决定将这个备份文件存
	储到哪个位置:
	sudo dump -0S /dev/sda3	
	然后开始备份：
	sudo dump -0u -f path/os.dump /dev/sda3

备份完成之后，我们就要准备进行还原了，必须保证硬盘B上有足够的空间，我们先从
B上分出两个分区，一个用来挂载/分区，一个用来做swap交换区。
	这个可以通过安装盘完成，或者在其他的linux操作系统里面完成。

	然后假定这个即将挂在/分区的分区为/dev/sdb4,我们就可以这样对其进行还原操作：
	sudo mount /dev/sdb4 /mnt
	cd /mnt
	restore -r -f path/os.dump
	如果希望排除某些文件，不对其进行备份，可以通过-E选项指定要排除的文件对应的
	inode，inode可以通过ls -i进行查看。
	这样备份的文件系统就会恢复到/dev/sdb4中去了，时间可能会长一些。

	在恢复的过程中，用户可能区查看恢复的情况，这个时候看到的文件的属主基本上都
	是root的，包括/home/anyuser下的文件也都是root的，这个不要怕，当你恢复成功
	后，引导进入/dev/sdb4中的操作系统时，文件属性就是正确的了。

恢复成功之后，就要准备进行重新引导了，但是这个时候，grub没有安装，是无法引
导B中的双系统的，所以需要在当前linux系统中先将grub装上，通过命令：

	pwd is /mnt.
	grub-install --boot-directory=/mnt/boot/grub/ /dev/sdb
	这个时候已经将grub安装到sdb上了，但是由于grub之前认分区的时候可能是通过
	uuid的，这样换了硬盘之后，uuid不同了，所以grub在引导的时候会出错，不能够自
	动引导，我们需要手动修改grub引导配置，或者通过命令手动引导。也就是说我们在
	grub引导界面通过configfile引导的时候会出错，因为uuid变了，找不到对应的分区
	了，我们可以在grub引导界面上，通过ls查看对应的分区信息，并通过linux装载内
	核配置root，通过initrd装载初始ram盘，然后boot启动就可以了。
	这样系统就可以启动了。

然后，我们不能一直这样修改吧，我们必须修改配置文件，包括/etc/fstab中的uuid
，uuid可以通过blkid进行查看，还有必须更新grub，让grub更新配置文件中的引导参数
，这样就可以引导windows、linux双系统了。
windows有个100mb的系统保留分区，里面可能包含了某些引导性的代码，因为之前B中已
经有4个主分区了，为了建linux分区，我把它删掉了，然后才可以建扩展分区，然后将
linux分区、swap建立在扩展分区中。
这样，如果不安装grub的话，把windows7自带的系统保留分区删掉，windows7就没法启动
了，所以我猜测里面包含了引导性的代码，经过验证发现，这100mb的分区里面果然是安
装了启动的代码。如果安装win7的时候就手动删除了这个保留分区，那么启动代码
bootmgr以及启动配置Bot/BCD等均会安装在c盘下，而如果是保留分区没有删除，则安装
在该保留分区中。如果安装了win7之后再删除保留分区，由于之前启动相关文件在保留分
区里面，这样安装了grub之后，进入系统之后再执行下grub-update也是找不到win7所在
分区的，这个时候就是要用系统盘进行修复。

##############################################################################

使用opengl进行渲染，不要使用xrender进行渲染

##############################################################################

添加内核参数video.brightness_switch_enabled=0到grub ，不要添加
acpi_backlight=vendor，在某些笔记本电脑上，必须添加参数acpi_backlight=vendor才
可以让系统通过快捷键调节亮度，比如在我的samsung q460 js02这台笔记本上就是。但
是在thinkpad品牌的电脑上，就不需要添加这个参数，添加、不添加这个参数，亮度都可
以通过快捷键进行调节，但是如果添加了该参数，快捷键调节亮度的时候，对应的指示器
没有显示出来，去掉这个参数的话，就可以正常显示了。

##############################################################################

备份、备份，还是备份！
dump\restore是备份还原的利器！

##############################################################################

安装搜狗词库到ibus-pinyin，也就是替换词库android.db，但是要删除
ibus-pinyin-db-openphrase

##############################################################################

安装搜狗输入法，真是太爽了，详细参考sogou官网，里面有详细的说明

##############################################################################

using synergy to control several pc.

when i set 'ctrl+alt+k' as the hotkey, i saw the error log, it says 'cannot
register hotkey ctrl+alt+k', i realized maybe there has one hotkey
'ctrl+alt+k' existing in the kde desktop environment. i checked the keyboard
and shortcuts settings from system settings, indeed it's been registered to
switch keyboard layout, i found it and unregistered it, then restart synergy,
every thing goes ok!

##############################################################################

in VirtualBox, don't use left ctrl key as the host key, if you do that,
ctrl+c,ctrl+\,ctrl+d signal will not be generated and sent to the guest
terminal. you can try left win as the host key instead of right ctrl.

##############################################################################

To register Nessus, fire your browser at the following url:
	http://www.tenable.com/products/nessus/
		nessus-plugins/obtain-an-activation-code

Nessus website doesn't block the access from China. Regarding to blocking
China access, it's nonsense.

if you uninstall and reinstall nessus, you have to get a new activation code.
the same email can be used to register more than once.

/opt/nessus/sbin/nessus-update-plugins all-2.0.tar.gz，在nessus一分钟内处理完
成之后，这个压缩包就不需要了，但是还是放在某个位置备份一下比较好。注意，这一分
钟之内，不要重启nessus，也不要移动all-2.0.tar.gz，否则可能处理失败，而又不给出
错误提示，最后使用nessus的时候，就会出现奇怪的问题。

##############################################################################

/etc/xdg/autostart/fcitx-autostart.desktop to enable fcitx autostart.

##############################################################################

squid3 搭建http代理服务器

##############################################################################

apt-get update to find the checksum is mismatched.

why and how to fix ?


Wait a few hours. This is caused by the download site being behind a CDN, and
the caches for Release and Packages.gz being mismatched. It'll clear itself up
within a few hours.

After ~12 hours it has not fixed itself, but a new error arose:

W: A error occurred during the signature verification. The repository is not
updated and the previous index files will be used. GPG error:
http://download.mono-project.com wheezy Release: The following signatures were
invalid: BADSIG A6A19B38D3D831EF Xamarin Public Jenkins (auto-signing)
<releng@xamarin.com>

W: Failed to fetch
http://download.mono-project.com/repo/debian/dists/wheezy/Release

W: Some index files failed to download. They have been ignored, or old ones
used instead.  After 14 hours the repository was parsed successfully and the
problem has been resolved.

##############################################################################

The following signatures couldn't be verified because the public key is not
available: NO_PUBKEY 16126D3A3E5C1192.

sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 16126D3A3E5C1192

apt-key, cmd 'adv' can pass advanced options to gpg, for example, adv with
option --recv-keys can be used to download public key from keyserver specified
by --keyserver.

##############################################################################

install 'xrdp' to make your pc works as a rdp server.

##############################################################################

install 'kde-config-touchpad' to switch off touchpad when in keyboard
activity.

##############################################################################

eclipse 'install new software', add 'viPlugin/http://viPlugin.com', after
pending select 'viplugin' to install, create file viPlugin2.lic, and write
'q1MHdGlxh7nCyn_FpHaVazxTdn1tajjeIABlcgJBc20' into it, then put it under
/opt/eclipse, restart.

##############################################################################

grub-install --boot-directory /dev/sda
here, --boot-directory should point to the /path/boot directory rather than
/path/boot/grub directory, or when you restart, grub will not find relevant
mods.

and in manual, it is described clearly as following:
--boot-directory=DIR: ... points to DIR/grub ...

##############################################################################
/etc/X11/X

when kdm failed to start, i swithed to text mode, then i check the
/var/log/kdm.log, it says there's no /etc/X11/X, then i create a symlink 
/etc/X11/X which points to /usr/bin/Xorg. then restart kdm, ok.

maybe linux distros and communities are so ... free.
##############################################################################

i remove the bug report packages, apport*

##############################################################################

install several display managers, conflict!

after i install several display managers, some conflicts occur.
i installed kdm, lightdm, gdm in order, then only gdm can start normally, kdm
and lightdm will stuck when start them.

so i delete logs in /var/log, then i restart kdm, and deep into
/var/log/kdm.log, it says no X in /etc/X11/, then i recreate a symlink points
to /usr/bin/Xorg, now kdm can start normally now.

then i tried lightdm, in /var/log/lightdm/lightdm.log, it says failed to start
greeter, then i check /var/log/lightdm/x-1-greeter.log, it says no authority
to access /var/lib/lightdm/.Xauthority.
then i check the mode of file .Xauthority, then i saw its owner user and group
is 'gdm'. what a suck! it clearly belongs to 'lightdm', why you set it to
'gdm'.

what a suck! what a bug!

then i checked /etc/passwd, kdm\lightdm\gdm entries exist. then i know display
managers run as the kdm\lightdm\gdm rather than root. when i installed them,
they changed the modes of some files which are belonged to by kdm\lightdm\gdm,
so only the last installed one works normally. the previous can't be sure.

even though you uninstall the last installed one, the previous installed must
be reinstalled to enable it normally.

i changed the owner:group of /var/lib/lightdm/* to lightdm, it works!

restart! ok!

##############################################################################

Unknown media type in type 'all/all'
Unknown media type in type 'all/allfiles'
Unknown media type in type 'uri/mms'
Unknown media type in type 'uri/mmst'
Unknown media type in type 'uri/mmsu'
Unknown media type in type 'uri/pnm'
Unknown media type in type 'uri/rtspt'
Unknown media type in type 'uri/rtspu'

cd /usr/share/mimeinfo, mv kde.xml kde.xml.bakup, sudo update-mime-datebase

over!

##############################################################################

12.04 latest kernel 3.13.0-40 is not compatible with latest virtualbox and
relevant components in main repo.

remove it and reinstall 'virtualbox virtualbox-dkms', must add '--reinstall'
parameter.

then ok.

guest screen resolution can't be changed, install 'virtualbox virtualbox-dkms
virtualbox-guest-additions virtualbox-guest-dkms virtualbox-guest-utils', must
add '--reinstall'
parameter.

sudo service virtualbox restart, then test

still not works.
#############################################################################

删除符号链接的时候，最好使用unlink，删除符号连接的时候，也会删除所指向的文件

#############################################################################

apt-get update, checksum mismatch

原因：
Wait a few hours. This is caused by the download site being behind a CDN, and
the caches for Release and Packages.gz being mismatched. It'll clear itself up
within a few hours.
After ~12 hours it has not fixed itself, but a new error arose:
W: A error occurred during the signature verification. The repository is not
updated and the previous index files will be used. GPG error:
http://download.mono-project.com wheezy Release: The following signatures were
invalid: BADSIG A6A19B38D3D831EF Xamarin Public Jenkins (auto-signing)
<releng@xamarin.com>

W: Failed to fetch
http://download.mono-project.com/repo/debian/dists/wheezy/Release
W: Some index files failed to download. They have been ignored, or old ones
used instead.

After 14 hours the repository was parsed successfully and the problem has been
resolved.

#############################################################################

ubuntu里面没有plymouth-set-default-theme，使用如下命令代替：
update-alternatives --list/config default.plymouth来代替

#############################################################################

原来带有PAE标识的32位系统是支持扩展内存，最大支持64GB内存或者在32位系统上安装
pae内核模块

#############################################################################

vim treaks:
shortcut: zz, put the current line under cursor to the center of screen.
command: %Tohtml, convert current document to html.

#############################################################################

ssh-keygen 生成的公钥必须要放置在被管理服务器的root账户中才可以，才可以实现无
密码登录. I don't know why?

#############################################################################

 byobu\tmux升级之后，解决某些annoying problems:
 1)byobu配置问题，每次f2新建窗口之后，下方tab上显示的title特别长，开的窗口数量
 多了之后，切换起来眼花撩换，搞得整个人心情都不好了，这就是一个坑爹的配置方案
 。解决办法如下：
 修改/usr/share/byobu/profile/tmux中的配置信息，进行如下修改：
 set -g default-terminal screen --> set -g default-terminal xterm-256color
 2)tmux升级之后的问题，启动tmux的时候有一个起始目录，再f2新建窗口之后，这个新
 增窗口的shell提示符显示，pwd显示其位置为按f2时，shell所在的目录的位置，看上去
 这个功能很方便，其实不然。窗口多了之后，容易引发混乱，还是统一为起始目录位置
 要更好些。个人看法，个人使用体验决定的。解决办法如下：
 修改/usr/share/byobu/keybindings/f-keys.tmux，进行如下修改：
 对下行内容进行修改：
 bind-key -n F2 new-window -c "#{pane_current_path}" \; rename-window "-"
 修改为：
 bind-key -n F2 new-windows -c $PWD \; rename-window "-"

 当然了，再次升级之后，上述配置信息会被覆盖，一种更好的办法是，将上述配置信息
 写入到~/.byobu中的相关配置文件中。这样就不用每次升级之后，重新对其进行配置.

#############################################################################

 fedora 21, enable fan control:
create conf file /etc/modprobe.d/thinkpad_acpi.conf, and add the following
 lines in it:
	options thinkpad_acpi fan_control=1
reboot.

 now you can use echo xxx > /proc/acpi/ibm/fan to control the fan speed, pay
 attention not to damage your hardware.

#############################################################################

 install input method: sogoupinyin, sogoupinyin-skins

	[myrepo]
	name=Sensor
	baseurl=https://gitcafe.com/sensor/myrepo/raw/master/fedora/$releasever/$basearch/
	skip_if_unavailable=True
	gpgcheck=0
	enabled=1

 add aboved repo into /etc/yum.repos.d, yum install sogoupinyin sogoupinyin-skins.
 before doing this, you'd better remove all fcitx* to remove plugins that may
 conflict with sogoupinyin.

 and before yum install, remove ~/.config/fcitx to remove configuration files
 that may conflict with sogoupinyin.

 after yum install, you may find that sogou skins can't be set. copy all skins
 from /usr/share/sogou-qimpanel/recommendSkin/skin/ to
 ~/.config/sogou-qimpanel/skin/, this will solve the problem.

#############################################################################

vim编写doc-like的文件:

简化版:
filename.txt
modeline, <Leader>h1, <Leader>h2
*tagname*
|tagname|
helptags `pwd`, <Leader>hh
[[\]] to jump

详细版：
最关键的只有2步，一个是将待编辑的文件的文件类型在模式行modeline中设置为help类
型；一个是通过*tagname*定制标签，然后在文档中的其他地方或者其他文档中引用的时
候，通过|tagname|来引用实现跳转（这部分实际是参考的add-local-help）。
上述2步是在编辑过程中比较重要的部分，另外一个，最最重要但是重要的不用提你也不
会忘记的就是，打开文件之后，记得运行helptags `pwd`为文件生成tags。也不要忘记开
启语法高亮等。说道这里的helptags `pwd`不得不提vim的运行方式，即vim只为扩展名为
txt的文件生成tags文件，所以记得将文件的扩展名修改为txt;

为了简化上述工作流程，我在vimrc里面定义了几个inoremap映射，分别是<Leader>h1和
<Leader>h2，h1表示help-begin，h2表示help-end。
之后在编辑文档的时候，按照前面锁提的2个关键点进行编辑就可以了。
为了更新tags文件，我自定了一个命令<Leader>hh用来更新tags文件，执行的实际上是命
令helptags `pwd`。
一般情况下，我们不希望使用vim的help命令之后的响应方式，那种方式的时候文件是只
读的、不可修改的，而且是以文档的方式半vim屏幕打开，看起来不方便，这种方式是通
过set helpfile=xxx来设置的，默认不设置的！

##############################################################################

caj转换为pdf
cnki下载下来的论文大部分都是caj格式的，linux上使用wine运行cajviewer进行查看，
查看效果不佳，而且我现在都是使用mendeley对pdf格式论文统一进行管理，也便于查看
、注释等操作。
网上提供了一种方式，虚拟打印机，我在linux上面通过配置cups、cups-pdf来进行虚拟
pdf打印机管理，可以结合cajviewer中的打印功能，将caj格式的论文打印成pdf格式的，
然后导入到mendeley中，很方便！
cups管理web界面http://localhost:631。

##############################################################################

cnki网站使用asp.net进行开发，有的代码需要在用户端浏览器中进行运行（类似于java
applet），需要java支持，但是linux版的chrome浏览器在38之后的，就已经移除了对旧
的java api接口的支持。所以打开某些asp页面的时候并没有打开页面，而是下载了页面
。
例如下载论文的链接，在chrome中点击了之后，是下载了asp页面文件，而不是对应的论
文。
解决办法：使用其他浏览器代替，例如使用firefox！

##############################################################################

chmod u+s/g+s，设置可执行位；
chmod o+t/o-t，设置粘贴位，粘贴位主要是用来限制其他用户删除的，所以用o!

如果是对目录设置s、t，则ll显示权限的时候是小写的s、t，如果是目录的话，显示的是
S、T.

需要注意的是，由于s、S是设置的可执行位，因此目标文件应该由可执行权限才可以，否
则ll显示的时候，终端里面有红色背景色提示设置错误；粘贴位，再给目录设置了粘贴位
之后，其内部的所有文件的删除都只能由当前用户删除，其他无权限的用户不能删除、重
命名（当然root啥都可以）。

##############################################################################

vim配置相关：
centos7中the-nerd-commenter的nerdtree不能够显示出来，提示说，NERDTreeToggle不
是一个vim的编辑命令。相同的配置在fedora21中是正常的。
后来在centos7下面的vim中又安装了一个新的插件，叫做The-NERD-tree的插件，安装好
之后，就可以显示了。
Something Strange!

##############################################################################

ibus背景色问题：
ibus输入框中的背景色，这个是在kde的相关颜色主题设置中进行的，具体地就是在系统
设置面板中的color部分进行设置的，修改某个颜色schema的selection background属性
对应的背景色即可。

##############################################################################

安装nvidia官方驱动程序:
我的笔记本中是双显卡，通过optimus技术进行控制，图像渲染负载小的时候，直接使用
集成显卡（集成在intel处理器芯片内部的）进行渲染，但负载重的时候，使用独立显卡
进行渲染，并将计算后的数据送往集成显卡，集成显卡负责显示。
目前在双显卡的笔记本中安装nvidia驱动程序，当前有两个办法，比较好用。
1）只想使用集成显卡，那么可以通过安装acpi call禁用独立显卡。
2）如果只想使用独立显卡，那么可以通过bios禁用集成显卡，安装nvidia官方驱动强制
使用独立显卡；或者安装bumblebee，按需使用独立显卡。
当前看来，2）是一个不错的选择，但是使用2）的话，基本上平时都是使用的集成显卡，
如果要开启独立显卡，需要手动通过optirun yourprogram来运行，目前bumblebee还不能
够通过计算渲染负载来自动启动独立显卡。

针对此，我写了一篇博文,请在ChinaUnix下搜索《linux推广1:双显卡切换》。

##############################################################################

在fedora21里面，不知道怎么回事，估计是plymouth自身的问题，我执行
plymouth-set-default-theme <theme-name> -R之后，并没有正确生成initramfs，为此
我自己手动生成。安装了一个hotdog主题之后，说什么也修改不了了，估计还是
plymouth-scripts自身的问题。

在/sbin目录下面添加了一些常用的脚本，例如update-grub2、update-initramfs。

##############################################################################

安装pavccontrol对音量进行控制，非常好用的工具，可以调节每个程序的音量、虚拟机
的音量等等。

###############################################################################

pmap, 显示进程使用的内存映射！

##############################################################################

cherrytree中文汉化文件有误，我自己修改了一下：
下载cherrytree源代码，由于我之前已经向作者反应过存在的问题并提交了修改后的汉化
文件，作者也予以了合并但是现在还是没有被打包到官方源里面，官方软件源中仍然存在
错误。
我重新安装了系统，再次安装了cherrytree，发现还是存在相似的问题，于是将修改方法
重新记录了一下。
git clone https://github.com/hitzhangjie/CherryTree.git cherrytree
cd cherrytree/locale
./i18n_pot_to_mo.py zh_CN.po
然后会生成很多的mo文件，并分别按照语言区域进行了划分，比如zh_CN\en\es等。
cd zh_CN/LC_MESSAGES
sudo cp -f cherrytree.mo /usr/share/locale/zh_CN/LC_MESSAGES/cherrytree.mo
重新启动cherrytree即可！直接修改程序安装时的mo文件，cherrytree启动会失败，可能
是检查了某些校验和相关的信息吧！

##############################################################################

当希望从系统中删除某个文件，而又不能确定该文件是否是某些软件残留的垃圾文件时，
可以通过yum provides $(file-path/file-name)来查看一下，如果检索结果不能显示该
文件所属的软件包，那么该文件就是垃圾文件无疑，可以直接删除，如果能检索到对应的
软件包的话，就需要慎重考虑一下了，有可能配置文件的删除会影响该软件包中软件的正
常运行。

##############################################################################

ImageMagic contains some tools to manipulate images.

example: convert pdf to images
	/usr/bin/convert 100pages.pdf -append 1page.jpg

##############################################################################

关于安装了simsun字体之后，某些网站默认的字体族显示宋体为默认字体，konsole中也
是，其他某些应用程序中也是，这些字体在网页、konsole中看起来特别糟糕。但是在wps
或者某些其他中文程序又想通过明确指定simsun的方式来使用该字体，只是不希望默认使
用宋体作为显示。为此通过查阅man fonts-conf手册，对系统默认设置进行了修改，主要
包括如下几个地方：
/usr/share/fontconfig/conf.avail/40-nonlatin.conf
/usr/share/fontconfig/conf.avail/65-nonlatin.conf
将其中的跟simsun、nsimsun相关的字体描述注释掉，这样当某些希望请求中文字体的程
序请求serif、sans-serif、monospace时，就不会默认使用宋体来作为默认字体显示了，
因为找不到该字体的描述信息了，但是在某些特定的应用，例如wps中，我们明确指定使
用simsun字体作为字体的时候，不是通过serif、sans-serif、monospace来向系统请求获
取一个最佳匹配字体。
这种情况下，就满足了两种情况，即，明确指明使用simsun字体的程序依然可以使用
simsun字体，通过serif、sans-serif、monospace来请求一个最佳匹配的中文字体的时候
，不能使用宋体。

##############################################################################

之前搜索、批量删除文件的时候，一直使用的是find、xargs配合使用，前者完成搜索，
输出每一个匹配的文件，后者呢，则针对前者的每一行输出执行命令。但是刚才发现，这
样是有风险的，并且确实也已经对我造成了损失。我希望删除mendeley相关的内容，所以
使用find ~ -iname "*mendeley*" 进行搜索，然后将其通过管道输入给xargs rm -rf。
结果我发现命令执行之后，把我的Desktop文件夹给删除了，卧槽。原因是为什么呢？原
因就是前面的find命令再执行之后，匹配到了一个文件名Mendeley Desktop，因为文件名
中包含空格，xargs对其执行rm -rf指令的时候，实际上是执行的rm -rf Mendeley
Desktop，而我刚好在～目录下，所以将Desktop文件夹删除了，坑爹吧！！！！！

对啊，就是这么坑！以后希望批量删除的时候，先确认下有没有空格分割的文件名，免得
造成损失。后者，更靠谱的，利用find的-print0参数，文件名结束之后输出null结尾的
符号，同时xargs使用-0参数，以null作为分隔符进行处理，即：

find ~ -iname "*mendeley*" -print0 | xargs -0 rm -rf 

吃一堑长一智。
##############################################################################

linux相关的一些权威论坛：
cpan.org:权威的perl模块库
freshmeat.net:linux/unix的软件的海量索引库
kernel.org:linux内核的官方网站
linux.com:linux论坛,适合新用户
linux.org:linux一般信息交换地
linux.slashdot.org:技术新闻巨头slashdot针对linux的网站
linuxhq.com:有关内河的信息和补丁的汇编 
lwn.net:linux和开放源代码方面的通讯社
securityfocus.com:计算机安全方面的一般信息
serverfault.com:针对系统管理问题而分工协作编辑的数据库
serverfiles.com:网络管理软件和硬件的目录
slashdot.org:各类技术新闻
ugu.com:unix guru universe(unix高手大世界)--所有内容都好系统管理有关

##############################################################################

<<<<<<< HEAD
<<<<<<< HEAD
apt & yum，类似的操作，总结：

 1. Simple conversions:

 * apt-get install ~= yum install
 * apt-get upgrade ~= yum upgrade
 * apt-get remove ~= yum remove
 * apt-get --reinstall install ~= yum reinstall
 * apt-get install foo=1.0 ~= yum downgrade foo-1.0
 * apt-get clean ~= yum clean
 * apt-get build-dep ~= yum-builddep
 * dpkg -l ~= yum list installed
 * apt-cache search ~= yum search
 * apt-cache search --names-only ~= yum list ~= repoquery
 * dpkg -L ~= rpm -ql
 * apt-file list ~= repoquery -l

 2. Not so Simple conversions:

 * apt-cache show ~= yum info ~= repoquery -i
 * apt-get purge ~= yum remove
 * apt-get dist-upgrade ~= yum upgrade ~= yum distro-sync
 * apt-get source ~= yumdownloader --source
 * dpkg --get-selections ~= yum-debug-dump
 * dpkg --set-selections ~= yum-debug-restore
 * dpkg -S ~= repoquery --installed -f ~= rpm -qf 
 * apt-file search ~= repoquery -f ~= yum provides 
 * apt-get --simulate upgrade ~= yum check-update ~= yum --assumeno upgrade
 * apt-get --simulate install ~= yum --assumeno install
 * sbuild ~= mock

##############################################################################

use alien to convert a *.deb package to *.rpm package.

for example, I download a xmind.deb, then I want to convert it to rpm, why?
Because official site does not package the software to rpm. How to?

1 install alien、rpmrebuild
2 alien -r --scripts xmind.deb, the xmind.rpm will be generated
3 after step 2, I tried to install it, but it said:
  file /usr/bin/, /usr/lib/ conflicts with the files in package
  filesystem.rpm, we can fix it by rpmrebuild.
4 rpmrebuild -pe xmind.rpm, then it will use vim to edit configuration, I
commented out the line 'attr .... /usr/bin' and line 'attr .... /usr/lib',
save and exit, and continue rebuild.
5 after step 4, new rpm package will be generated under ~/rpmbuild directory.
Try to install it and enjoy yourself.

##############################################################################

apt-get没有提供类似于yum history的命令选项，那么我们如何查看历史信息呢？可以通
过/var/log/apt/history进行查看，然后通过一些方法对其历史信息进行处理，比如批量
删除已经安装的软件等等。

##############################################################################

mbuntun可以将基于unity的ubuntu进行深度定制，将界面打造成osx一样的风格，其中
synapse可以配合xdotool来提供快捷键支持。

##############################################################################

kwin cool effect avoid one frame blinking

 1. fedora21:
 replace isfadeWindow with following definition:
{
	 return !window.deleted && !window.desktopWindow && window.onCurrentDesktop
		 && window.visible && !window.skipSwitcher && !window.utility
		 && !effect.isGrabbed(window, Effect.WindowAddedGrabRole)
		 && !effect.isGrabbed(window, Effect.WindowClosedGrabRole)
		 && !CoolEffect.isLoginWindow(window);
 }
 2. CentOS7:
	 ...

##############################################################################
mount Mac OSX hfsplus filesystem on Linux
mount -t hfsplus -o force,rw /dev/osx-partition /mount-point
##############################################################################

当遇到wifi/bluetooth rfkill的问题的时候，直接关闭wifi的硬件开关，然后重新启动
电脑，重新启动并进入系统之后，再打开硬件开关，如果此时执行rfkill list all显示
设备仍然被soft block，则执行rfkill unblock all即可，如果已经显示没有软锁，那么
就ok了。

linux内核在启动的时候，好像是期望hard block/soft block为true！

rfkill list all
rfkill unblock all

备注：奇葩！在火车上通过笔记本给手机充电的时候，笔记本开着为了减少电量消耗，关
闭了wifi硬件开关，之后笔记本没电休眠了，后来重新接上电源之后，不管是windows下
还是linux下，都打不开无线网卡。后来，把外接电源拔掉，笔记本电池也拆掉，再安装
上电池，重新启动，蓝牙、wifi就可以打开了。
这是联想的问题吗？联想，联想个蛋蛋！

##############################################################################

dolphin里面搜索文件，如果文件名中包含空格的话，就搜索不出来，这个问题的原因可
能是由于Desktop Search功能导致的，直接通过系统设置里面，禁用Desktop Search功能
就可以解决这个问题。

不确定具体的原因是什么，现在也无法对其进行补丁修复了，后续版本的fedora或者kde
中可能修复这个问题。

补充：后来我发现Desktop Search里面可以通过配置哪些位置禁用Desktop Search来实现
，这样Dolphin也可以正确进行搜索。

##############################################################################

移除kde桌面右上角的desktop toolbox，这个玩意没有什么用，因为在右键菜单里面、面
板上都可以调出类似的工具箱来。留着它，一不小心点到了就挺啰嗦，还需要再点一下才
能取消对应的操作。

如何移除呢？将/usr/share/kde4/services/plasma-toolbox-desktoptoolbox.desktop重
命名一下就可以了。我习惯性地将其重命名为${previous-name}.bak。

##############################################################################
2016-03-11 01:41:49 AM

今天笔记本thinkpad t420s出了个怪事，就是我一用力按c壳右下角，无线网卡、蓝牙就
被关掉，松开一会就又重新被打开。我猜可能是线路接触不良，于是拆开之后重新接了下
线，问题解决！

##############################################################################
2016-03-12 02:23:31 PM

kdemenuedit对菜单进行配置，有时更换菜单图标之后，如果图标完整路径+图标名称与之
前旧的图标相同的话，菜单的图标还是以前旧的图标，而不是最新的图标，这个问题是由
于kde使用kbuildsycoca4对系统中的图标等资源进行增量配置，一个最好最简单的办法就
是直接进入/var/tmp/kdecache-${username}目录下，直接删除icon-cache.kcache，然后
logout、login即可解决图标缓存的问题。
这个也从侧面说明了bleachbit等清理工具的不靠谱!

##############################################################################
2016-03-12 11:40:58 PM

mendeley desktop中对文档进行批注之后，如果不小心改变了文档所在的文件夹的名称，
就是路径变动之后，mendeley就会找不到原来文件的情形，点击也打不开文档，这个时候
只要重新点击details->添加文档就可以了，千万不要点击移除文档，然后再添加，因为
一点击移除文档，mendeley就会删除对应的批注信息！！！！！
##############################################################################

字体配置的时候,有几个地方需要特别注意，konsole中显示中文不正常，这个问题是因为
缺乏必须的字体导致的，从windows下面复制必要的中文字体粘贴到当前用户的.fonts目
录下，或者点击直接安装，然后到/usr/share/fontconfig/conf.avail/目录下将simsun
字体屏蔽即可！

其实有一个更好的办法，可以在终端中使用WenQuanYi Micro Hei字体来显示中文，具体
设置方法就是修改/usr/share/fontconfig/conf.avail/65-nonlatin.conf，在所有的
simsun、nsimsun前面添加<family>WenQuanYi Micro
Hei</family>，这样就可以在使用各个字体族的时候，中文都默认使用WenQuanYi Micro
Hei来显示了。

其实关于字形、字体、字体族的概念，还是很容易混淆的，还有就是系统对字体的搜索、
替换过程，可能更让人摸不着头脑，不管怎么样，这都是小事，自己改成自己需要的配置
就可以了。

##############################################################################
2016-03-17 01:03:39 PM

关于vim的详细配置过程，请参考当前的vimrc配置说明进行一下总结，最好能够整理成文
档的形式，整理好之后，会在此处进行一下说明，并把其中的关键插件进行一下描述！

##############################################################################
2016-03-17 03:51:10 PM

cherrytree的工具栏不显示的问题，图形界面中没有找到可以从哪里进行设置，直接修改
.config/cherrytree将其中的toolbar 是否visible修改为True即可。

##############################################################################

rpmdb altered outside ...

这个问题可以直接通过yum clean all解决。

这个问题的原因是由于有的程序直接使用了rpm或者用户直接使用了rpm进行操作，没有通
过yum提供的操作接口。为什么要加这个提醒呢，这是因为如果直接通过rpm进行修改，
yum中是看不到修改记录的，yum history sync之后也是看不到的，为了防止电脑被黑后
rpmdb被篡改植入恶意软件，为了让用户能够尽快看到这个rpmdb被修改的情况，所以yum
中加入了这个检查！当然你可以关掉这个，在/etc/yum.conf中添加history_record=0，
但是这样之后，yum history相关的所有的命令就都不能使用了。

##############################################################################
2016-03-18 04:06:59 PM

安装了maya2016之后，启动的时候无法启动，一个是要安装libXp这个库，然后提示缺少
libtiff.so.3，通过yum list libtiff，检查了一下，只有4.0.3的包了，没有3.x的包，
所以直接创建了一个符号链接ln -s libtiff.so.5.0.2 libtiff.so.3，然后maya就可以
成功启动了。

##############################################################################
2016-04-13 02:01:22 AM

kde菜单中的程序启动的时候，是不会加载.bash_profile或者.bashrc中的变量的，因为
前者是给登陆shell用的，后者是给非登陆shell用的（当然对于登陆shell，先source前
者再source后者），而kde中的gui程序启动的时候，如果直接从菜单中启动而非从shell
中启动，那么是不会获得在上述两个脚本中的环境变量的。
kde中的这部分环境变量应该在~/.kde/env/xxx.sh中进行设置，在里面直接协商export
xxxx=xxx将变量导出即可.

##############################################################################
2016-04-17 02:15:11 AM

in vim, ':scriptnames' can list the sourced scripts in order, which will help
us judge where problem occurs. ':help initialization' can also help us realize
the detailed initialization process when starting vim.

##############################################################################
2016-04-17 02:39:03 AM

vim misunderstand *.md files as modula2 filetype?

edit /usr/share/vim/vim74/ftplugin.vim:
change from 'README.md' to '*.md' for markdown;
delete '*.md' from filetype modula2!
##############################################################################
2016-04-18 01:45:19 PM

delete duplicate 'places' in dolphine save file dialog

".kde/share/apps/kfileplaces/bookmarks.xml"
delete this file or manually remove dupliate 'places' entries, remove
bookmarks.tbcache.

then you should restart 'display manager', then login again.

remember, just logout/login may not work!

##############################################################################
2016-04-24 12:01:41 AM

增加VBox中虚拟机的磁盘容量：
1. 创建新的数据盘，这种容易操作，可以直接在VirtualBox图形用户界面中完成；
备注：
这种方式重新创建新的数据盘是可以的，但是假如我们把系统等所有的东西安装一个分区
中，系统要升级，就得占用一定的新的空间，例如Mac OS X升级，实际上我也是在这个时
候碰到这个问题的，这个时候创建新的数据盘是没有用的。
而且很多时候，我们只是希望扩展现有的磁盘空间的容量，而不是重新增加新的数据盘，
那么怎么修改呢？VBox v4.0以上的版本可以灵活地对其进行修改。
VBoxManage modifyhd "filename.vdi" --resize ${nnnn}，其中${nnnn}的单位是MB。
重新启动VirtualBox就可以看到虚拟机对应的最大磁盘容量的大小发生了变化。

##############################################################################
2016-04-24 02:48:59 PM

/usr/src/Kernels下的源代码，在安装文件kernel-devel-$(uname -r).rpm中，而不是在
kernel-$(uname -r).src.rpm中。

另外关于kernel-headers-$(uname -r).rpm，官方库中没有的时候，虽然系统运行不怎么
受影响，因为已经编译好了嘛，但是新的需要重新构建内核模块的程序，仍然希望
kernel-headers与当前运行内核版本一致，所以应该通过搜索某些repo或者直接搜索rpm
包来安装匹配的版本。

##############################################################################
2016-04-24 05:28:40 PM

谷歌浏览器有一个配置文件叫做Local State，里面有个protocol_handler定义好了处理
特定协议的方式，例如"thunder"，当希望重新设置对其处理方式时，可以将浏览器关闭
，然后删除该配置文件中的相应条目，重启浏览器再点击一下这种类型的链接就可以了。

##############################################################################
2016-05-07 12:56:18 PM

vim *rawhide*
:zz
it outputs: one more file to edit?
:next or :prev to move between differenet files being edited.

##############################################################################
2016-05-08 04:58:16 PM

fedora 21中将桌面背景设置为marble，结果一直报错；但是新建一个用户，在这个新用
户下进行这种操作，就没有问题。这是一个好办法，在解决桌面环境相关问题时，通过新
建一个用户，在干净的环境里面进行配置容易发现问题。最后我将现在用户中的
.kde/share/config/plasma-desktop-appletsrc直接删除，然后重新登陆，问题解决。

##############################################################################
2016-05-08 05:02:20 PM

kde中的activity，好像是专门为设置不同的电源管理模式而准备的，因为我在看kde的相
关帮助手册的时候仅发现了activity与电源管理设置相关。activity相关的设置仅仅出现
在系统设置的电源管理部分。
之前，我还以为activity有什么大的作用呢？原来是为了设置不同的电源管理模式。

补充：不对啊，还是之前理解的对，activity确实是虚拟桌面的一个超集，activity就是
相当于一个活动，你可以在里面设置希望用到的程序等等。不过我不喜欢这种东西，太过
复杂了也不好，我觉得虚拟桌面已经差不多够用了，而且，我们很难把工作分的那么清楚
，例如一边听歌一边工作。特别的工作可能需要另当别论，比如协作或者编程。根据自己
情况选择吧。针对不同的activity，可以指定不同的电源管理模式。

##############################################################################
2016-05-10 01:02:32 PM

HIBERNATE MODE Vs SLEEP MODE

While sleep puts your work and settings in memory and draws a small amount of
power, hibernation puts your open documents and programs on your hard disk,
and then turns off your computer. Of all the power-saving states in Windows,
hibernation uses the least amount of power.

也就是说睡眠模式，是将当前系统状态驻留到内存中，仍然会耗费一定的电力；休眠模式
会将当前系统状态保存到磁盘，并关机，当按了开机按键之后，系统读取磁盘上保留的系
统状态，并恢复到内存中。

##############################################################################
2016-05-14 06:07:19 PM

使用vim-instant-markdown的时候，如果文件中引用了图片，浏览器也存在缓存的问题，
如果要替换一个图片文件的话，最好是通过修改文件名，这样立即就可以生效，你不可能
说是让浏览器禁用缓存功能吧，那以后访问网页就太慢了。另外如果确实还是希望使用跟
以前相同的文件名，清理一下浏览器图片缓存就可以了。

##############################################################################
2016-06-13 05:30:27 PM
update-grub2 generates wrong UUID for 'linux16 ... root=UUID=xxxxx'.

why? when modify disk partitions, new uuid will be generated! but where is it
stored, some people say uuids will be stored into superblock of partitions.
after that, blkid can inspect it, and update-grub2 also can inspect it.

but why in grub.cfg, 'search xxxxx uuid=xxxx' is right, but 'linux16 ...
root=UUID=xxxx' is wrong. I am still confused.

it is more likely that grub2-mkconfig contains a bug.

how to resolve it?
mannually edit the file 'grub.cfg', and boot system, then re-install grub to
/dev/sdx, then reboot into another system and exec update-grub2 again.

##############################################################################
2016-06-17 08:24:06 PM

安装cscope之后，当通过vim查看源代码并根据tag进行跳转的时候，cscope插件会将定义
这个tag的所有文件以列表的形式显示出来，让用户选择然后再跳转；ctags是直接跳转到
第一个中去。很明显cscope这种方式更加友好。

##############################################################################

2016-07-14 07:33:55 AM

markdown中预览的时候经常该发现vim编写的文件中不同的字符之间如果存在一个断行操
作则在markdown中进行预览操作的时候，常常会在newline前后的字符之间出现一个空格
，经过测试，这个问题出现在“汉字-newline-汉字”这种情形之下，英文的时候不会出现
问题。应该与vimrc中的换行操作无关。

根本原因是，vim中会将newline当做一个空格来进行处理，这对于英文单词之间的
newline来说当做换行进行处理是完全没有问题的，而且是相当好的处理方式，但是对于
中文来说就不是这样了，因为我们中文习惯中，中文的每个字符之间都是没有空格进行分
隔的。

总结一下，这个问题是vim对中文字符处理的问题，以及vim对markdown支持的问题，不是
什么大问题，在写文档的时候依然可以继续使用这种编辑方式，希望以后vim能够改进这
一功能。

备注：
另外，对于markdown文件，可以安装discount命令行工具，利用命令discount-mkd2html
将markdown文件转换为html文件。

##############################################################################

2016-08-10 12:14:47 AM

CentOS common repos:
official:
	CentOS-Base.repo
	CentOS-Debuginfo.repo
	CentOS-fasttrack.repo
	CentOS-Sources.repo
	CentOS-Vault.repo
	CentOS-fasttrack.repo
	CentOS-CR.repo
	epel.repo
	epel-testing.repo
3rd:
	nux-desktop.repo
	elrepo.repo
bad:
	rpmfusion-free-updates.repo
	rpmfusion-free-update-testing.repo
	rpmfusion-nonfree-updates.repo
	rpmfusion-nonfree-update-testing.repo

##############################################################################

2016-08-10 08:25:36 AM

install java master and slave links.

#!/bin/bash

update-alternatives --install /usr/bin/java java /usr/java/jdk1.7.0_71/bin/java 1000 \
--slave /usr/bin/appletviewer appletviewer /usr/java/jdk1.7.0_71/bin/appletviewer \
--slave /usr/bin/apt apt /usr/java/jdk1.7.0_71/bin/apt \
--slave /usr/bin/ControlPanel ControlPanel /usr/java/jdk1.7.0_71/bin/jcontrol \
--slave /usr/bin/extcheck extcheck /usr/java/jdk1.7.0_71/bin/extcheck \
--slave /usr/bin/idlj idlj /usr/java/jdk1.7.0_71/bin/idlj \
--slave /usr/bin/jar jar /usr/java/jdk1.7.0_71/bin/jar \
--slave /usr/bin/jarsigner jarsigner /usr/java/jdk1.7.0_71/bin/jarsigner \
--slave /usr/bin/javac javac /usr/java/jdk1.7.0_71/bin/javac \
--slave /usr/bin/javadoc javadoc /usr/java/jdk1.7.0_71/bin/javadoc \
--slave /usr/bin/javafxpackager javafxpackager /usr/java/jdk1.7.0_71/bin/javafxpackager \
--slave /usr/bin/javah javah /usr/java/jdk1.7.0_71/bin/javah \
--slave /usr/bin/javap javap /usr/java/jdk1.7.0_71/bin/javap \
--slave /usr/bin/java-rmi.cgi java-rmi.cgi /usr/java/jdk1.7.0_71/bin/java-rmi.cgi \
--slave /usr/bin/javaws javaws /usr/java/jdk1.7.0_71/bin/javaws \
--slave /usr/bin/jcmd jcmd /usr/java/jdk1.7.0_71/bin/jcmd \
--slave /usr/bin/jconsole jconsole /usr/java/jdk1.7.0_71/bin/jconsole \
--slave /usr/bin/jcontrol jcontrol /usr/java/jdk1.7.0_71/bin/jcontrol \
--slave /usr/bin/jdb jdb /usr/java/jdk1.7.0_71/bin/jdb \
--slave /usr/bin/jhat jhat /usr/java/jdk1.7.0_71/bin/jhat \
--slave /usr/bin/jinfo jinfo /usr/java/jdk1.7.0_71/bin/jinfo \
--slave /usr/bin/jmap jmap /usr/java/jdk1.7.0_71/bin/jmap \
--slave /usr/bin/jmc jmc /usr/java/jdk1.7.0_71/bin/jmc \
--slave /usr/bin/jmc.ini jmc.ini /usr/java/jdk1.7.0_71/bin/jmc.ini \
--slave /usr/bin/jps jps /usr/java/jdk1.7.0_71/bin/jps \
--slave /usr/bin/jrunscript jrunscript /usr/java/jdk1.7.0_71/bin/jrunscript \
--slave /usr/bin/jsadebugd jsadebugd /usr/java/jdk1.7.0_71/bin/jsadebugd \
--slave /usr/bin/jstack jstack /usr/java/jdk1.7.0_71/bin/jstack \
--slave /usr/bin/jstat jstat /usr/java/jdk1.7.0_71/bin/jstat \
--slave /usr/bin/jstatd jstatd /usr/java/jdk1.7.0_71/bin/jstatd \
--slave /usr/bin/jvisualvm jvisualvm /usr/java/jdk1.7.0_71/bin/jvisualvm \
--slave /usr/bin/keytool keytool /usr/java/jdk1.7.0_71/bin/keytool \
--slave /usr/bin/native2ascii native2ascii /usr/java/jdk1.7.0_71/bin/native2ascii \
--slave /usr/bin/orbd orbd /usr/java/jdk1.7.0_71/bin/orbd \
--slave /usr/bin/pack200 pack200 /usr/java/jdk1.7.0_71/bin/pack200 \
--slave /usr/bin/policytool policytool /usr/java/jdk1.7.0_71/bin/policytool \
--slave /usr/bin/rmic rmic /usr/java/jdk1.7.0_71/bin/rmic \
--slave /usr/bin/rmid rmid /usr/java/jdk1.7.0_71/bin/rmid \
--slave /usr/bin/rmiregistry rmiregistry /usr/java/jdk1.7.0_71/bin/rmiregistry \
--slave /usr/bin/schemagen schemagen /usr/java/jdk1.7.0_71/bin/schemagen \
--slave /usr/bin/serialver serialver /usr/java/jdk1.7.0_71/bin/serialver \
--slave /usr/bin/servertool servertool /usr/java/jdk1.7.0_71/bin/servertool \
--slave /usr/bin/tnameserv tnameserv /usr/java/jdk1.7.0_71/bin/tnameserv \
--slave /usr/bin/unpack200 unpack200 /usr/java/jdk1.7.0_71/bin/unpack200 \
--slave /usr/bin/wsgen wsgen /usr/java/jdk1.7.0_71/bin/wsgen \
--slave /usr/bin/wsimport wsimport /usr/java/jdk1.7.0_71/bin/wsimport \
--slave /usr/bin/xjc xjc /usr/java/jdk1.7.0_71/bin/xjc

##############################################################################

2016-08-24 14:05:34

in OSX, how to speed up your input?
defautls write NSGlobalDomain KeyRepeat -int 1				: repeat rate
defaults write NSGlobalDomain InitialKeyRepeat -int 8		: repeat delay

then logout/login again!

##############################################################################

2016-10-08 00:53:29

osx下面没有提供像linux中update-alternatives的软件多版本控制软件，但是homebrew
提供了一个可以管理多个jdk版本的工具jenv，jdk的安装还是要自己安装，只是通过jenv
add来注册当前系统中可用的jdk版本，然后必要的时候可以通过jenv local ${ver}或者
jenv global ${ver}来设置当前shell或者系统全局使用的jdk版本。

为什么要安装多个版本呢？必要性自不必提。我需要安装多个版本，为啥？jdk1.8是趋势
，但是很多框架尤其是依赖于字节码底层操作的框架对jdk版本依赖性很强，比如kilim，
主要是其依赖asm这个字节码框架。kilim必须使用jdk1.7进行编译、测试，1.8会抛异常。

##############################################################################

2017-04-02 22:32:50 +0800

之前安装的vim的markdown预览插件，不能很好地对特殊字符&和<进行处理，通过修改文
件/usr/local/lib/node_modules/instant-markdown-d来修复这个问题。

{
  var body = '';
{
    body += data;
{
      throw new Error('The request body is too long.');
    }
  });
{
    // 自动转换markdown中的特殊字符&和<，Enjoy it！
    body = body.replace(/&/g, '&amp;');     // 转换&
    body = body.replace(/</g, '&lt;');      // 转换<
    output.emit('newContent', md.render(body));
  });
}
```

##############################################################################

od: to check the ascii and its relevant hexidemals

```bash
od -tx1 -tc filename
```

##############################################################################


