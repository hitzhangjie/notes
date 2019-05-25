原来Security & Privacy中，允许有一个选项可以允许运行Anywhere下载安装的软件，但是新版本系统中处于安全性方面的考虑，默认禁用了Anywhere这个选项。

![run anywhere missing](assets/gatekeeper-allow-apps-anywhere-macos-2.jpg)



如果想恢复这个选项，可以运行下面的命令：


```bash
sudo spctl --master-disable
```



如果想再次禁用这个选项，可以运行下面的命令：

```bash
sudo spctl --master-enable
```

