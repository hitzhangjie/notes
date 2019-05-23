更新应用程序图标：

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