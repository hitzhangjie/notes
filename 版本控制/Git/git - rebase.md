# git rebase -i <commit-hash>

git rebase -i <commithash>，这里的hash是修改前的第一个hash，会弹出一个窗口让选择哪些commit作为一次提交，哪些用来squash（压缩）
pick hash1
pick hash2
pick hash3
比如修改成：
pick hash1
squash hash2
squash hash3
表示将hash2,hash3对应的提交与hash1合并为一个commit

这样框架日志会更加清楚点

# git rebase <branch-name>

如在某个分支dev上进行了开发，此时master上也有合入，希望将master的修改同步到dev上来，有两种方式：

- 在dev分支上 `git merge master`，坏处是会让master的提交历史冲乱dev分支的历史，各种穿插，发起cr的时候也非常不方便；
- 在dev分支上 `git rebase master`，可以保证当前分支的修改一直未予log最顶部，不会穿插master上的修改，发起cr的时候修改也更清晰。