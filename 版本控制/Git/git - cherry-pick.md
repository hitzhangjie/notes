# Question

Suppose this is my git history

```
  Z
 /
A -- C -- D
 \  /      
  B
```

My HEAD is currently at `Z`. I want to cherry-pick `B` and `C`. If my understanding is correct, I should do this:

```
git cherry-pick B
git cherry-pick C -m 1
git commit --allow-empty
```

It worked in my case because `C` is a no-op (hence the empty commit afterwards, I needed the commit for other reasons), but I am wondering what the parameter after `-m` does. Here is what I read from [the docs](https://git-scm.com/docs/git-cherry-pick):

> **-m parent-number**
>
> **--mainline parent-number**
>
> Usually you cannot cherry-pick a merge because you do not know which side of the merge should be considered the mainline. This option specifies the parent number (starting from 1) of the mainline and allows cherry-pick to replay the change relative to the specified parent.

In my case, `C` has two parents but how do I know which one is 1 and 2, and more importantly when does it matter when I pick 1 or 2?



# Answer

My understanding based off [this answer](https://stackoverflow.com/a/12628579/2747593) is that **parent 1 is the branch being merged into**, and **parent 2 is the branch being merged from**. So in your case, parent 1 is `A`, and parent 2 is `B`. Since a cherry-pick is really applying the diff between two commits, you use `-m 1` to apply only the changes from `B` (because the diff between `A` and `C` contains the changes from `B`). In your case, it probably doesn't matter, since you have no commits between `A` and `C`.

So yes, `-m 1` is what you want, and that is true even if there were extra commits between `A` and `C`.

If you want to make the new history look a little more like the original history, there's another way to do this:

```
git cherry-pick B
git checkout Z
git merge --no-ff --no-commit B
git commit --author="Some Dev <someone@example.com>" --date="<commit C author date>"
```

(If needed, you can create a new branch for `B` before cherry-picking.)

This will retain the author information, should give you a history that looks like this:

```
    B'
   /  \
  Z -- C'
 /
A -- C -- D
 \  /      
  B
```