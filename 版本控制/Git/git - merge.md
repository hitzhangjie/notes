# git merge

假如现在个repo，当前本地有两个分支master和dev，当前希望将dev分支合并入master，这个时候只要执行`git checkout master; git merge dev`就可以了。

但是实际情况下，代码合并并不是简单的一件事情，可能会变得很复杂，下面列举几个场景，以及对应的解决办法。



# git cherry-pick

假如现在维护了框架，master分支用于合并代码进行全局验证，线上服务构建使用release分支或者特定的tag版本进行构建，dev_$feature分支负责新特性开发。由于是一个框架，各个release分支或者tag版本都可能存在大量用户在使用。

假如现在发现了框架中的一个bug，并且这个bug可能在master、各个release分支以及tag中都存在，我们的bug修复人员，很可能是某个tag版本的一个使用者，假如它在tagv1.0上拉了个分支bugfix进行了修复，并发起了PR，审核通过并成功merge到了master。假如我希望将这此bugfix对应的commit也合并到release分支呢？

可能遇到这样的问题，release分支滞后于master，master中合入了很多待验证的新特性，或者已基本验证通过但是还没有足够稳定，这个时候是不能直接`git merge master`将代码合入release的，那还有什么办法将bugfix对应的commit合入release分支吗？有的！

## cherry-pick一个commit

我们可以选择bugfix对应的这一次commit，将这一次修改对文件所做的修改合并入release，在release分支执行`git cherry-pic <commit>`即可。

## cherry-pick多个连续的commit

`git cherry-pick A..B`，从A到B，不包含A；

如果要包含A，git cherry-pick A^..B。

## cherry-pick多个不连续的commit

`git cherry-pick A1 A2 A3 B1 B2 B3`，这样就可以了，指定多个commit。


当然git cherry-pick可能会遇到更加复杂的场景，这里就不介绍了，具体问题具体分析吧。



# git patch

有的情况下，在本地进行了不少修改，很多次commit，但是这个时候假如希望将这些修改作用到其他分支上，而不想讲这些提交的commit合入最终的提交历史中，这个时候可以通过创建git diff文件作为补丁，然后在希望提交的分支上应用这个补丁生成新的commit即可。

详见git-patch相关的笔记。



# git log master..release

有时也会一些不是特别规范的操作，引入一些问题，比如正常我们只会将代码修改后先合入master，然后才有可能从master合并到release或者cherry-pick到release。但是总有一些比较特殊的场景，如release分支有bug，赶紧从release拉了个bugfix分支修复并且将修改合入了release分支，那么release分支上就有了新的commit记录。但是这些commit可能还没有合入master。

有时我们希望对比下master和release，比如希望查看下master分支没有但是release分支有的commit记录，可以执行命令`git log master..release`来查看，master..release的意思是说列出master分支不存在、但是在release分支存在的commit。

这也是个帮助我们进行分支对比的方法，在代码合并时有时也可以帮大忙。