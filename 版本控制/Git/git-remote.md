1. git remote -v显示remote的详细信息，git remote只显示名字，加上参数-v可以将fetch和pull的url全部都显示出来。
2. git fetch [remote-name]，从指定的remote上面获取最新的信息，fetch只获取不合并，pull既fetch也合并。
3. git push [remote-name] [branch-name]，将本地的branch-name对应的分支提交到remote-name对应的远程库的对应分支中。
4. git remote show [remote-name]，会显示remote-name对应的远程库的信息，注意，git remote show命令会查询git服务器，获取相关信息，为什么要检查服务器呢？比如希望看到新添加的分支信息等！
5. git remote rename,重命名一个remote
6. git remote rm，删除一个remote