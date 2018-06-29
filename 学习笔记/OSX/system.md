# 1 进程管理

## 1.1 重启或者登陆时禁止软件自动启动
find the plist within /Library/LaunchAgents/ or /Library/LaunchDaemons/, add following lines:

    ```
    <key>Disabled</key>
    <true/>
    ```
    restart or relogin!


