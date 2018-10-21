##### 0 git的优势在哪里？

版本控制系统的发展经历了从无到有，又从本地版本控制系统（如OSX下的rcs）到集中式版本控制系统（如svn、cvs等）、再到分布式版本控制系统（如git、mercural等）的过程。

- 分布式版本控制系统git相对于集中式版本控制系统，其解决了单点故障的问题；
- git又可以离线工作，即便没有连接网络也可以提交本地修改的代码，有网络连接时再予以提交；
- git repo如果遇到故障，可以借助检出的版本予以恢复；
- 基于分支开发、主干发布的版本控制策略是更被大家认可的方式，git下创建branch更加方便快速；
- ……
- 其他

git是趋势，当全世界的开发人员都在使用github，当来自全世界的Kernel Hackers为Linux贡献代码时，看到这一点，没有理由拒绝学习git了！

##### 1 如何解决git中乱码问题？

- ~/.gitconfig中增加如下配置

```sh
git config core.quotepath false
git config --global gui.encoding utf-8
git config --global i18n.commitEncoding utf-8
git config --global i18n.logOutputEncoding utf-8
```
- ~/.bashrc中增加如下配置

```export LESSCHARSET=utf-8```

##### 2 如何修改代码提交时的注释？

使用git命令行提交代码的时候，习惯性地使用命令 **git commit -m '...'**，然后开始在'...'中填写注释信息，但是在输入中文注释信息的时候可能一不小心多按了几下Enter就提交了不完整的、错误的日志信息。

能不能对提交的注释信息进行修改呢？

1）如果只是git commit了，但是还没有进行push的情况下
执行 **git commit --amend -m '...new-comments...'**，对上次提交的内容进行修订，修订后最后一次提交的注释信息就变成了刚才新填写的注释信息。这种情况只适用于对 **最后一次提交** 的错误注释信息进行修订，之前的均不能适用。

2）如果git commit了，而且还git push了
这种情况的话，只能执行git rebase操作进行修改了。

##### 3 repo被破坏如何重建repo？

假定remote repo遇到了问题，需要利用之前检出的local repo来重建remote repo，怎么做到呢？

复制本地local-repo/.git/*到远程目录remote-repo/，然后删除remote下那些git init --bare不会生成的文件，最终只会保留3个文件4个文件夹。因为这个remote-repo实际上与local-repo是相同的分支，当继续在local-repo进行修改并commit然后push到remote-repo时会报错，提示“push到一个与当前检出分支相同的分支”。

这个时候呢，只需要在remote-repo目录中执行如下命令设置允许向相同分支push就可以了。

```
git config receive.denyCurrentBranch <ignore | refuse>
```

也可以直接修改remote-repo/.git/config文件，增加如下配置：

```
[receive]
denyCurrentBranch = <ignore | warning | refuse>
```

##### 4 删除一个分支

删除本地分支：`git branch -D ${branchName}`
删除远程分支：`git push ${remoteName} --delete ${branchName}`
