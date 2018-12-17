1 服务管理

- brew services list，列出已经安装的服务，例如mysql、httpd等；
- brew services <start | stop | restart> formula，启动、停止、重启服务；
- brew services cleanup，清理无用的服务；

2 brew更新

- brew update stuck
  cd "$(brew --repo)" && git fetch && git reset --hard origin/master && brew update

