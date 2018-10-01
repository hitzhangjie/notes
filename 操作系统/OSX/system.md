# 1 进程管理

## 1.1 重启或者登陆时禁止软件自动启动
find the plist within `/Library/LaunchAgents/` or `/Library/LaunchDaemons/`, add following lines:

    ```
    <key>Disabled</key>
    <true/>
    ```
    restart or relogin!

## 1.2 ulimit设置
os x下ulimit命令无法更改ulimit设置，这个好像被禁用了，比如要设置ulimit -n 100001，不管是否是root权限，都无法对其进行正常更改。

os x下通过launchctl对其进行修改。




