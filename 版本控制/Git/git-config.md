1. git可以对各种文件类型建立版本控制，例如图片等，因为它支持对二进制格式的文件进行版本控制。
2. 
3. git配置
   1）系统作用域文件，/etc/gitconfig
   2）用户作用域，,/home/username/.gitconfig，or，/home/username/.config/git/config
   3）repo作用域，$repo_path/.git/config
4. 设置邮箱和用户名，因为每次git中的提交操作，都需要使用到你的用户名和邮箱，所以必须设置（这个和使用github无关）。
   git config user.name "xxx"
   git config user.email "xxx"
5. 配置使用的编辑器，提交的时候，需要输入信息，需要用到编辑器：
   git config core.editor /usr/bin/vim
6. git config --list查看当前的配置信息
7. git有多种数据传输协议，可以使用https协议或者ssh协议，比较常用。
   https协议：git clone https://github.com/username/reponame [dirname]
   ssh协议：git clone git@github.com:username/reponame
   git协议：git clone git://github.com/username/reponame
8. repo/.gitignore文件中忽略某些文件，通过这个配置文件可以删除某些不应该被追踪的文件！
   \*：匹配任意文件
   dir/：忽略整个目录下面的所有文件
   dir/*.txt
   !flalfa：感叹号表示不忽略这个文件，即反转语义！
9. 通过配置别名减少命令行输入时的繁琐：
   git config --global alias.co checkout
   [alias]
         co = checkout
         br = branch
         ci = commit
         ct = commit
         ss = status
         bb = branch



