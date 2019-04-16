1. git中3种文件状态

   - commited

     从.git种checkout出来的一个工程版本，如果对其修改之后，并且执行了commit，状态就变成commited，这个时候的版本已经被安全存储到了本地的.git仓库中；

   - modified

     从.git中checkout出一个版本，并且进行了修改，并且没有commit、没有stage，那么起状态就是modified。

   - staged

     如果checkout了一个版本进行了修改，并且执行了stage，其状态就是staged，这个状态表示当前暂时把对文件的修改进行一次记录，后面提交的时候，就被提交！

   通常使用时，要么3个状态之间来回切换，要么完全跳过staged状态。staged通常存储在.git中的一个index文件中。

2. repo中的工作目录中的文件存在2种可能的状态，tracked和untracked！
   - tracked，可能是已经被commit之后的文件，也可能是被stage的文件！
   - untracked，是新创建的文件，还没有被commit或stage！

3. git add 与 git stage
   git add具有多个用途：

   - 可以添加untracked的文件到tracked文件列表；
   - 将修改后的文件放到staged文件列表；
   - 标记文件冲突已解决；

   git stage用途只有一个：

   - 只是将修改后的文件stage到staged文件列表。

4. git status

   `git status -s`，命令选项-s表示只进行简要描述，例如：

   - M表示修改后的；
   - ??表示untracked的文件；
   - 其他等等

   git status，默认显示比较详细的描述信息，某些IDE为了尽可能显示更多文件的状态信息，通常使用简要描述方式，如android studio中。