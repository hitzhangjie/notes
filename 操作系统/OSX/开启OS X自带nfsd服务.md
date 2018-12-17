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

> 备注：
>
> 现在感觉用Paralles Desktop是OS X下最好用的虚拟机管理软件了，相比于VMWare WorkStation要好多了，但是还是太重了，如果有必要的话可以使用Docker来安装、启动Linux镜像，对于某些短时间要用Linux的场景，比如临时验证下Linux下的某个功能、查看api、手册或者写个测试demo之类的，Docker就是大家的不二选择了！