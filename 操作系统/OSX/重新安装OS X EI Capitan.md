1.开机按command+option+r，选择网络恢复，等待下载完成、安装完成；

2.安装完成之后，先根据自己的使用习惯，对系统中的system preferences进行一下简单的设置；

3.更改主机名

- sudo hostname knight
- sudo scutil --set LocalHostName $(hostname)
- sudo scutil --set HostName $(hostname)

4.修改按键频率

- defaults write NSGlobalDomain KeyRepeat -int 3
- defaults write NSGlobalDomain InitialKeyRepeat -int 10

5.安装homebrew；