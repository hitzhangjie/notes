git-commit常用操作：

```bash
git commit -m 'commit message'            #快速提交方式，命令行中指定注释信息
git commit                                #调用core.editor填写注释信息，包括摘要信息和详细信息

git commit --amend -m 'commit message'    #对上次提交的注释信息进行修订
git commit --amend                        #调用core.editor填写注释信息，对上次提交的注释信息进行修订
```



注意：

”git commit --amend“对已push的commit无能为力，如果需要更加复杂的修订操作，参考“git rewrite history”相关内容。