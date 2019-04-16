1. git配置文件
   1）系统作用域文件，`/etc/gitconfig`
   2）用户作用域，`/home/username/.gitconfig，or，/home/username/.config/git/config`
   3）repo作用域，`${repo}/.git/config`

2. 设置邮箱和用户名，因为每次git中的提交操作，都需要记录提交者的用户名和联系邮箱，所以必须设置。
   ```bash
   git config user.name "xxx"
   git config user.email "xxx"
   ```

3. 配置使用的编辑器，提交代码时需输入提交信息，要指定用什么编辑器来录入提交信息：

   ```bash
   git config core.editor /usr/bin/vim
   ```

4. 查看当前的配置信息

   ```bash
   git config --list
   ```

5. git有多种数据传输协议，可以使用https协议或者ssh协议，比较常用。
   ```bash
   https协议：git clone https://github.com/username/reponame [dirname]
   ssh协议：git clone git@github.com:username/reponame
   git协议：git clone git://github.com/username/reponame
   ```

6. 通过配置别名减少命令行输入时的繁琐：
   ```bash
   git config --global alias.co clone
   git config --global alias.ck checkout
   ```

   如果希望一次性修改大量的配置，也可以直接编辑gitconfig文件，如~/.gitconfig。

   ```bash
   [alias]
         co = checkout
         br = branch
         ci = commit
         ct = commit
         ss = status
         bb = branch
   ```

7. 不同os系统换行符问题

   ```bash
   git config --global core.autocrlf input #input：提交时使用LR，检出时不转换
                                           #true：提交时转换为LF，检出时转换为CRLF
                                           #false：提交时、检出时均不转换
   ```

8. 忽略文件模式改变（chmod）

   ```bash
   git config --global core.filemode false
   ```

9. 解决常见的编码问题

   ```sh
   git config core.quotepath false                     #
   git config --global gui.encoding utf-8              #在git-gui或者gitk中展示文件内容时，使用utf8编码
   git config --global i18n.commitEncoding utf-8       #执行commit操作存储提交的注释信息，使用utf8编码
   git config --global i18n.logOutputEncoding utf-8    #执行git log展示提交的注释信息时，使用utf8编码
   ```

   - ~/.bashrc中增加如下配置：`export LESSCHARSET=utf-8`；
   - 如果是windows系统，先确认下`git —no-pager log`输出编码是否正常，正常的话说明也是less的问题：
     - 如果是临时查看，可以像这样临时禁用git的分页查看特性；
     - 如果是临时查看，也可以`set LESSCHARSET=utf-8`，启用分屏并临时使less使用utf-8编码；
     - 如果想一劳永逸，还是设置环境变量，windows下在环境变量设置对话框中进行设置；

