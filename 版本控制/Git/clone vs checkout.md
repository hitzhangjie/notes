**clone != checkout**

很多git初学者，都会对git的clone产生困惑，可能是受svn checkout的影响吧：

- svn，checkout操作是检出一个完整的repo；
- git，clone操作是克隆一个repo，checkout是在repo里面检出一个branch；

不少开发者接触git之后就会快速地体会到git相比于svn的巨大优势——分支管理方便！

- 快速创建新分支，git checkout -b $branch
- 快速切换分支，git checkout $branch
- 快速删除分支，git branch -D $branch
- 快速提交分支，git push —set-upstream origin $branch
- 快速删除远程分支，git push -D origin $branch
- 快速合并分支，git merge $branch
- 快速选择指定commit并合并，git cherrypick <commit>，或者git cherrypic <merge> -m <1|2|3|...>