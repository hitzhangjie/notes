1. git tag

   git使用2种类型的tag，**轻量级tag**或者**注解tag**。

   - 轻量级tag，就相当于创建一个不会改变的分支一样，不提供描述信息。

   - 注解式tag，会将repo中的当前的代码进行存储，并包含一些附加描述信息，建议使用这种方式的tag。
     `git tag -a <tag-version> -m <comments>`，创建一个注解式tag。
     `git show <tag-version>`，检查指定版本的tag对应的相信信息。
     `git tag <tag-version>`，创建了一个轻量级的tag，创建轻量级tag的时候不能指定其他的选项，轻量级tag只是做了一次新的提交，提交了一个校验和而已。

     

2. 注意：有的时候我们提交了很多次之后，才会意识到某一次提交之后应该添加tag的，但是忘记了，或者没有发现，这个时候如何在历史提交的基础上添加tag呢？很简单
   注解式tag：`git tag -a <tag-version> -m <comment> <checksum>`
   轻量级tag：`git tag <tag-version> <checksum>`
   这里的checksum可以通过git log进行查看，例如`git log --pretty=oneline`，并且checksum部分可以简写。

   

3. git tag创建的tag默认不会被push到remote repo，如果需要push tag需要手动执行命令：`git push <remote-name> <tag-name>`。如果有很多个tag要提交到服务器的话，上面这种办法比较麻烦，可以在git push后面添加参数--tags来提交所有未提交到服务器的tag。

   

4. 不能够从服务器的repo里面直接得到一个tag，需要先clone下来获得repo的完整信息，然后再`git checkout $tag`。如果我们希望从某个tag拉个新分支出来的话，可执行`git checkout -b $branch <startpoint>`，这里的startpoint参数可以是某个$tag。