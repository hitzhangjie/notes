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

   