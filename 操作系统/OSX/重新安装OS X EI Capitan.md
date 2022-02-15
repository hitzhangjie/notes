除了BSD超凡的稳定性作为奠基，再加上Apple的倾力优化，硬件也是精挑细选的，这些都让OS X变得更加稳定，用户也可以更加专注于工作，将MBP切实当做一个可信赖的伙伴。但是时间用久了之后，还是有可能会因为误操作搞乱系统的部分配置信息，特别是开发者，对于OS X系统的重装，所以还是有必要掌握的。

1. 开机按**command+option+r**，选择网络恢复，等待下载完成、安装完成；
2. 安装完成之后，先根据自己的使用习惯，对系统中的system preferences进行一下简单的设置；
3. 更改主机名
```bash
sudo hostname knight
sudo scutil --set LocalHostName $(hostname)
sudo scutil --set HostName $(hostname)
```
4. 修改按键频率
```bash
# key重复速率，比如vim hjkl按住不放时移动速度，过大容易引起误输入
defaults write NSGlobalDomain KeyRepeat -int 2

# 按键时的等待时延，过大容易导致误输入，比如不小心碰到一个按键就激活了
defaults write NSGlobalDomain InitialKeyRepeat -int 10
```
5.安装homebrew；

