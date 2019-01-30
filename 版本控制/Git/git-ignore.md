repo/.gitignore文件中忽略某些文件，通过这个配置文件可以删除某些不应该被追踪的文件！

```bash
*：匹配任意文件
dir/：忽略整个目录下面的所有文件
dir/*.txt
!flalfa：感叹号表示不忽略这个文件，即反转语义！
```

如果是之前文件被追踪过了，现在想通过.gitignore来取消对其进行跟踪，可以这么做，假定这个文件是filename：

- 如果希望保留filename这个文件，只是删除跟踪信息：git rm filename --cached
- 如果希望将跟踪信息和文件一并删除：git rm filename -f，-f表示强制删除
- 也可分成2步，先删除`rm filename`，再清空历史跟踪信息`git rm filename`。

在工程中，经常存在误添加文件到git版本控制中的情况，需要将其从版本控制中清除，这个操作可能经常被用到，比如用IntelliJ IDEA开发，可能不小心将IDE生成的工程描述信息.idea/*给错误提交了。