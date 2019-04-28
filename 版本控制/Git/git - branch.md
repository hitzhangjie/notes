删除一个分支

删除本地分支：`git branch -D ${branchName}`
删除远程分支：`git push ${remoteName} --delete ${branchName}`



分支信息同步：`git fetch --prune`

有时remote已经删除了一个分支，如origin/dev_abc，本地git branch -r还是可以看到origin/dev_abc

