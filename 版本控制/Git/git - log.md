1. 检查提交历史git log，git log -p can see the imported differences between commits
  ```bash
  git log --stat
  git log --pretty=oneline
  git log --pretty=format:"%h - %an, %ar : %s"
  git log --pretty=format:"%h %s" --graph
  git log --graph
  ```

2. 限制git-log的输出

  ```bash
  git log --author=??? --since=??? --before=?? --no-merges --pretty=???
  ```

  这里是限制git log只输出指定作者、在特定时间范围内的提交，并且不显示merge事件。

  git log提供了丰富的命令选项，可以探索一些有价值的选项，配置成git alias的形式，方便日后使用。


3. 自定义log格式

	```bash
	git log 			\
		--abbrev-commit \
		--graph 		\
		--pretty=format:'%Cgreen%h %C(bold blue)%cr %Creset>>> %C(bold yellow)%<(78,trunc)%s %Creset<<< %Cred<%an>%Creset'
	```


4. 查询内容变更中包含字符串 $string 的提交记录

   ```bash
   git log -S $string
   ```

   这个操作是非常有用的一个操作，当你不清楚某个关键词在哪个源文件中出现（或者文件名变更），导致你无法通过跟踪具体文件的history来追溯关键词相关的调整时。该命令就非常有用，它可以快速筛选出历次commit中 $string 的增加、删除操作，方便你快速定位到对应的commit记录。

   之前goneat由此重构删除了一个监控打点的上报，我就是通过 `git log -S $monitorid` 来快速定位到对应的commit记录进一步确定变更的原因的。

5. 查看指定commit的详细信息，如何前一个commit之间的变化

   ```bash
   git show <commit>
   ```

   

