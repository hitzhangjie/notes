修改repo中历史提交中的author信息，为什么会有这样的需求呢？有时我们可能要与多个团队协作开发项目，如果不注意设置repo中的username、email就有可能会提交与预期不符的author信息上去，对于项目管理者而言看到后会感到困惑。比如我经常活跃在github和公司内的开源项目上，但是github上是一个账号信息，公司内则是另一个账号信息，有时不注意切换，就会将公司外的账号信息提交到公司内的项目记录中，这个是不太好的。

所以，掌握如何修改历史提交记录中的author信息，还是非常有需要的。修改前一次提交（还没push）可以通过`git commit —amend -m “message ….”`来完成，但是对于比较久远的commits（包括已经push的），这种改如何修改呢？

参考文章：https://help.github.com/en/articles/changing-author-info

To change the name and/or email address recorded in existing commits, you must rewrite the entire history of your Git repository.

**Warning**: This action is destructive to your repository's history. If you're collaborating on a repository with others, it's considered bad practice to rewrite published history. You should only do this in an emergency.

### [Changing the Git history of your repository using a script](https://help.github.com/en/articles/changing-author-info#changing-the-git-history-of-your-repository-using-a-script)

We've created a script that will change any commits that previously had the old email address in its author or committer fields to use the correct name and email address.

**Note**: Running this script rewrites history for all repository collaborators. After completing these steps, any person with forks or clones must fetch the rewritten history and rebase any local changes into the rewritten history.

Before running this script, you'll need:

- The old email address that appears in the author/committer fields that you want to change
- The correct name and email address that you would like such commits to be attributed to

1. Open the terminal.

2. Create a fresh, bare clone of your repository:

   ```shell
   git clone --bare https://github.com/user/repo.git
   cd repo.git
   ```

3. Copy and paste the script, replacing the following variables based on the information you gathered:

   - `OLD_EMAIL`
   - `CORRECT_NAME`
   - `CORRECT_EMAIL`

   ```shell
   #!/bin/sh
   
   git filter-branch --env-filter '
   
   OLD_EMAIL="your-old-email@example.com"
   CORRECT_NAME="Your Correct Name"
   CORRECT_EMAIL="your-correct-email@example.com"
   
   if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
   then
       export GIT_COMMITTER_NAME="$CORRECT_NAME"
       export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
   fi
   if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
   then
       export GIT_AUTHOR_NAME="$CORRECT_NAME"
       export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
   fi
   ' --tag-name-filter cat -- --branches --tags
   ```

4. Press **Enter** to run the script.

5. Review the new Git history for errors.

6. Push the corrected history to GitHub:

   ```shell
   git push --force --tags origin 'refs/heads/*'
   ```

7. Clean up the temporary clone:

   ```shell
   cd ..
   rm -rf repo.git
   ```