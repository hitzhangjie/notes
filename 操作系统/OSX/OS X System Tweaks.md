# 进程管理

## 重启或者登陆时禁止软件自动启动
find the plist within `/Library/LaunchAgents/` or `/Library/LaunchDaemons/`, add following lines:

    ```
    <key>Disabled</key>
    <true/>
    ```
    restart or relogin!

## ulimit设置
os x下ulimit命令无法更改ulimit设置，这个好像被禁用了，比如要设置ulimit -n 100001，不管是否是root权限，都无法对其进行正常更改。
os x下通过launchctl对其进行修改。

## Mojave登录界面修改
OS X升级到Mojave之前，系统登录界面就是管理员用户的桌面，升级后，系统登录界面与管理员账户的桌面不再一致，而是被设置成了Mojave.heic这个动态壁纸，而且没有提供任何修改的GUI选项。

这个动态界面，说真的，真丑，如何修改呢？

首先，网上找个可将普通图片转换成heic格式动态图片的工具，这种工具很多，就不列举了，然后选择一张比较喜欢的桌面壁纸转换成heic。

然后，进入系统恢复模式，具体就是restart的同时按住cmd+r，待屏幕上出现苹果logo即可，系统启动后，进入utilities->terminal，输入`csrutil disable`禁用系统完整性校验SIP，然后进入搜索DefaultBackground.jpg和DefaultDesktop.heic这两个软链接，将其指向自己喜欢的动态壁纸和静态壁纸即可。再次输入csrutil enable恢复系统完整性检查，重启即可生效。

```bash
DefaultBackground.jpg.orig -> /Library/Desktop Pictures/Mojave Day.jpg
DefaultDesktop.heic.orig -> /Library/Desktop Pictures/Mojave.heic

// 这里的Default.jpg实际上是拷贝的Sierra.jpg，Default.heic实际上是通过Sierra.jpg生成的heic文件，
// 由于后续系统更新过程中，这里的文件会被覆盖掉，为了避免重复操作，将其备份到了~/Pictures/Wallpaper中，
// 拷贝过来直接用即可！
DefaultBackground.jpg -> /Library/Desktop Pictures/Default.jpg
DefaultDesktop.heic -> /Library/Desktop Pictures/Default.heic

```

