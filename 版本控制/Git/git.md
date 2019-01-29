1. git可以对各种文件类型建立版本控制，例如图片等，因为它支持对二进制格式的文件进行版本控制。

2. 

3. git与其他版本控制系统的区别
  **1）看待文件改变的方式，不同**
  其他的版本控制系统，基本上都是记录每个文件的改变，记录repo中文件集合的改变信息；而git相当于将repo看做是一个小型的文件系统，以类似于建立快照的形式记录文件改变，例如如果文件改变了，就重新记录它的改变信息，如果没有改变，则直接建立一个符号链接，连接到之前的版本中去。
  **2）是否支持离线工作**
  git checkout之后的repo记录了所有的历史信息，当检查repo的改变历史，以及希望比较当前修改与历史的不同等的时候，不需要向服务器发送请求，请求历史信息，这大大节省了时间。
  当某些时候，例如不能上网，或者网络无法链接，其他的版本控制系统是很糟糕的，因为他们的提交需要联网才能完成。而git支持离线工作，基本上全都是操作本地文件，速度相当快，而且这种情况下，还可以直接commit，记录在本地，只需要等可以上网的时候，将提交到本地的代码推送（push）到服务上就可以了。
  **3）数据完整性**
  git底层是通过校验和来检测文件是否被修改的，因此不可能通过修改了文件之后，git还检测不到，网络传输过程中如果出现了传输错误，git也可以通过校验和来检测到是否存在问题。因此保证了数据完整性。
  **4）git中操作基本上都是添加操作**
  git中对repo的操作，都会被记录下来。要做一些不可撤销的动作是很难的，当你提交了一个repo的快照，基本上就不会出现丢失的情况，并且如果你是周期性提交的话，基本上就更不可能出现数据丢失的情况。
  **5）git中3种文件状态**
  commited，从.git种checkout出来的一个工程版本，如果对其修改i之后，并且执行了commit，状态就变成了commited，这个时候的版本已经被安全存储到了本地的.git仓库中；
  modified，从.git中co出一个版本，并且进行了修改，并且没有commit、没有stage，那么起状态就是modified。
  staged，如果co了一个版本进行了修改，并且执行了stage，其状态就是staged，这个状态表示当前暂时把对文件的修改进行一次记录，后面提交的时候，就被提交！
  通常使用的时候，要么3个状态之间来回切换，要么完全跳过staged状态。staged通常存储在.git中的一个index文件中。

4. git配置
  1）系统作用域文件，/etc/gitconfig
  2）用户作用域，,/home/username/.gitconfig，or，/home/username/.config/git/config
  3）repo作用域，$repo_path/.git/config

5. 设置邮箱和用户名，因为每次git中的提交操作，都需要使用到你的用户名和邮箱，所以必须设置（这个和使用github无关）。
  git config user.name "xxx"
  git config user.email "xxx"

6. 配置使用的编辑器，提交的时候，需要输入信息，需要用到编辑器：
  git config core.editor /usr/bin/vim

7. git config --list查看当前的配置信息

8. clone不等于checkout
  其他版本控制系统，例如svn是通过checkout表示新检出一个repo；
  在git里面不是，是通过clone来完整地克隆一个库，checkout用来检出某一个分支；

9. git有多种数据传输协议，可以使用https协议或者ssh协议，比较常用。
  https协议：git clone https://github.com/username/reponame [dirname]
  ssh协议：git clone git@github.com:username/reponame
  git协议：git clone git://github.com/username/reponame

10. repo中的工作目录中的文件存在2种可能的状态，tracked和untracked！
  tracked，可能是已经被commit之后的文件，也可能是被stage的文件！
  untracked，是新创建的文件，还没有被commit或stage！

11. git add 与 git stage
   git add具有多个用途，可以添加untracked的文件到tracked文件列表、将修改后的文件放到staged文件列表、标记文件冲突已解决；
   git stage，只是将修改后的文件stage到stage文件列表。

12. git status -s进行简要的状态描述，例如M表示修改后的，??表示untracked的文件等等，git status比较详细，像比如一些ide，为了尽可能显示更多的信息，而工程中文件比较多，通常使用的就是git status -s进行输出，例如android studio中！

13. repo/.gitignore文件中忽略某些文件，通过这个配置文件可以删除某些不应该被追踪的文件！
   \*：匹配任意文件
   dir/：忽略整个目录下面的所有文件
   dir/*.txt
   !flalfa：感叹号表示不忽略这个文件，即反转语义！

14. 如果是之前文件被追踪过了，现在想通过.gitignore来取消对其进行跟踪，可以这么做，假定这个文件是filename：
   1）如果希望保留filename这个文件，只是删除跟踪信息：git rm filename --cached
   2）如果希望将跟踪信息和文件一并删除：git rm filename -f，-f表示强制删除
   也可以分成2步来实现，即先删除，rm filename，然后再执行git rm filename，这样文件也删除了，跟踪信息也被删除了，在工程中是很常用的。

15. git diff
   git diff，未staged的文件与staged文件的比较;
   git diff --staged或者git diff --cached，已经staged的文件与上次commit文件的比较；
   git diff HEAD，当前文件与上次commit文件进行比较；

16. git mv 操作通过git status可以看到这被git当做一个重命名操作，底层实现就是一个符号链接，不同名字的符号链接。

17. 检查提交历史git log，git log -p can see the imported differences between commits
   git log --stat
   git log --pretty=oneline
   git log --pretty=format:"%h - %an, %ar : %s"
   git log --pretty=format:"%h %s" --graph
   git log --graph

18. limit the output of git log
   git log --author=??? --since=??? --before=?? --no-merges --pretty=???
   there're too many useful options, we can try that.

19. git commit --amend, recommit! you can rewrite the commit msg. 注意push之后就不能再指向amend操作了。

20. git reset <file>, undo the stage action
21. git checkout <file>, re-get the file and overwrite\neglect current modification.
22. git remote -v显示remote的详细信息，git remote只显示名字，加上参数-v可以将fetch和pull的url全部都显示出来。
23. git fetch [remote-name]，从指定的remote上面获取最新的信息，fetch只获取不合并，pull既fetch也合并。
24. git push [remote-name] [branch-name]，将本地的branch-name对应的分支提交到remote-name对应的远程库的对应分支中。
25. git remote show [remote-name]，会显示remote-name对应的远程库的信息，注意，git remote show命令会查询git服务器，获取相关信息，为什么要检查服务器呢？比如希望看到新添加的分支信息等！
26. git remote rename,重命名一个remote
27. git remote rm，删除一个remote
28. git tag
   git使用2种类型的tag，轻量级的，或者基于注解的。
   轻量级tag，就相当于创建一个不会改变的分支一样，包含的信息较少，所以叫做轻量级的。
   注解式tag，会将repo中的当前的代码进行存储，并包含一些额外的信息，但是包含的信息全面，建议使用这种方式的tag。
   1）git tag -a <tag-version> -m <comments>，创建一个注解式tag。
   git show <tag-version>，检查指定版本的tag对应的相信信息。
   2）git tag <tag-version>，创建了一个轻量级的tag，创建轻量级tag的时候不能指定其他的选项，轻量级tag只是做了一次新的提交，提交了一个校验和。
   注意：有的时候我们提交了很多次之后，才会意识到某一次提交之后应该添加tag的，但是忘记了，或者没有发现，这个时候如何在历史提交的基础上添加tag呢？很简单
   注解式tag：git tag -a <tag-version> -m <comment> <checksum>
   轻量级tag：git tag <tag-version> <checksum>
   这里的checksum可以通过git log进行查看，例如git log --pretty=oneline，并且checksum部分可以填写完整，也可以只填写一小部分
   为了查看起来方便，应该定制一个良好的pretty=format，我在format.pretty设置选项里面进行了设置，设置为;
   "%Cgreen%h %Cred%cn %Cblue%cr %Cred[Subject] %s%Creset"，这样显示的信息比较全面，又不失简洁。
29. git tag创建的tag默认不会被push推送到服务器，如果确实需要推送tag到服务器，需要手动进行操作，执行如下命令：git push <remote-name> <tag-name>
   如果有很多个tag要提交到服务器的话，上面这种办法比较麻烦，可以在git push后面添加参数--tags来提交所有未提交到服务器的tag。
30. 不能够从服务器的repo里面直接得到一个tag，但clone下来之后，如果我们希望将工作目录中的内容变成某个tag对应的内容的话，可以通过git checkout [- b <new-branch-name>]  <startpoint>
31. 通过配置别名减少命令行输入时的繁琐：
   git config --global alias.co checkout
   [alias]
         co = checkout
         br = branch
         ci = commit
         ct = commit
         ss = status
         bb = branch



