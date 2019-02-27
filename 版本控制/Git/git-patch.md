经常存在在错误的分支1上进行了开发，并且已经提交，希望将当前这次修改内容同步到另一个分支2，但是又不想通过merge、cherrypick的方式来完成，这个时候可以通过`git format-patch -n <sha>`创建补丁文件，然后再切到分支2上应用这个补丁。

这么做的好处是，git版本记录比较干净，没有那么多merge、cherrypick记录。

在当前分支上，针对<sha>这个commit创建一个相对于之前一次commit的补丁，然后在master分支上应用这个补丁。

Try:

```
git format-patch -1 <sha>
```

or

```
git format-patch -1 HEAD
```

According to the documentation link above, the `-1` flag tells git how many commits should be included in the patch;

> -<n>
>
> ​     Prepare patches from the topmost commits.

------

Apply the patch with the command:

```
git am < file.patch
```