git clone，克隆下来的repo是一个完整的repo（不同于svn的clone操作），包含了所有的remote branches、tags、history信息，等等。remote repo往往是git init --bare初始化创建的，remote repo目录下不含具体用户创建的文件，但是包含了与文件相关的objects信息。

当我们执行git clone时，会首先clone下来remote repo中的objects信息，然后再git checkout对应的分支和版本，如果repo比较大，执行git clone的时候也可以看到这样的过程：“先创建.git目录，然后再checkout出对应的分支和版本”。



当remote repo因为某些原因被破坏后，可以基于local repo进行还原和重建，那怎么做到呢？

- 复制本地local-repo/.git/*到远程目录remote-repo/，然后删除remote下那些git init --bare不会生成的文件，最终只会保留3个文件4个文件夹。

- 因为这个remote-repo的master分支，充当了local-repo的origin/master分支，但它们实际上是相同的分支，当继续在local-repo进行修改并commit然后push到remote-repo时会报错，提示“push到一个与当前检出分支相同的分支”。

- 这个时候呢，只需要在remote-repo目录中执行如下命令设置允许向相同分支push就可以了。
    ```bash
    git config receive.denyCurrentBranch <ignore | refuse>
    ```
	也可以直接修改remote-repo/.git/config文件，增加如下配置：
    ```bash
    [receive]
    denyCurrentBranch = <ignore | warning | refuse>
    ```

