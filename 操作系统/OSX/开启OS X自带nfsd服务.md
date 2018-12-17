**1 配置网络文件系统服务**

OSX中自带了网络文件系统服务nfsd，只需要简单地进行一下配置就可以使用了，例如希望在Linux虚拟机和host主机之间通过网络文件系统进行文件共享，这是很方便的。

**OSX host配置：**

- 创建文件/etc/exports，并增加如下一行内容：/Users/zhangjie/Shared -mapall=zhangjie:staff
- 启动nfsd服务，sudo nfsd

**Linux guest配置：**

- 修改/etc/fstab文件，挂载网络文件系统：

```bash
10.211.55.2:/Users/zhangjie/Shared  /nfs  nfs  defaults  0  0
```

- 重启机器即可，sudo shutdown -r

**2 利用/nfsd进行数据共享**

可以充分利用网络文件系统在host、guest之间进行数据共享。