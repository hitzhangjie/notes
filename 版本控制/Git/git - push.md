### git push操作



#### push操作就涉及到git remote的设置，请参考git remote.md



-   正常push到远程, `git push <remote> <branch>`

-   如果涉及到回滚类的操作：

```
git reset --hard <commit>,

git push --force origin
```

