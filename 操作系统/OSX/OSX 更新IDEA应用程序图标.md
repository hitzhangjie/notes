更新IDEA应用程序图标：

1. 打开文件夹/Applications

2. 选中要修改的软件，如IntelliJ IDEA CE.app

3. 右键选择show package contents

4. 进入目录后，进入contents，再进入resources

5. 将图标文件*.icns替换成期望的图标

6. 刷新应用程序图标缓存

   ```bash
   killall Finder
   touch /Application/IntelliJ\ IDEA\ CE.app
   touch /Application/IntelliJ\ IDEA\ CE.app/contents/Info.plist
   ```

7. 查看图标是否已经刷新了，应该可以正常刷新的，屡试不爽！



之前，为wireshark、rar这些程序替换过应用程序图标，又漂亮又直观，后面碰到IntelliJ Idea的Ultimate、Community版本不一致的问题，Community版本的应用程序icon和欢迎界面的logo特别丑，这里也顺便总结下怎么替换着。



IntelliJ Idea图标、logo替换：

- 应用程序图标，替换掉/Application/IntelliJ IDEA CE.app/Contents/Resources/idea.icns；
- 启动界面logo替换，这个藏的深一点，在…/Contents/lib/icons.jar中，先jar xvf解压，然后替换掉welcome…._CE.png以及welcome…CE@2x.png，jar cvf重新压缩成jar，然后替换掉lib/icons.jar；
- 重启IntelliJ IDEA即可，查看是否生效；



IntelliJ不同软件如PyCharm等也同样适用这个方式，但是可能有细微的不同，不经不是同一个产品，到时候自己灵活处理一下就可以了。