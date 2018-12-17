# Xcode 学习笔记

# 1 编辑器
Xcode没有提供像IntelliJ Idea、Eclipse、VS一样集成插件市场的能力，如果想扩展Xcode的功能，就需要自己去搜索插件源码，再构建、安装。比如常见的IDE都提供了vim keybinding操作模式，比如Qt Creator，没有直接提供该vim keybinding的也可以借助插件来扩展这部分能力，比如IntelliJ Idea有插件IdeaVim、Eclipse有插件viplugin、VS也有类似插件。Xcode本身未提供vim keybinding，但可以通过Xcode插件XVim来实现。
## 1.1 XVim
XVim是一群开发者自行开发的Xcode vim keybinding插件，官方repo地址为：[https://github.com/XVimProject/XVim2](https://github.com/XVimProject/XVim2)。
检出项目代码，然后按照文档README.md里面描述的安装步骤进行安装即可，这里简单总结下：
- 使用keychain access.app创建自签名证书"XcodeSigner"
- 对Xcode进行重新签名（特别是Xcode升级之后），```sudo codesign -f -s XcodeSigner /Applications/Xcode.app```
- 检出XVim代码，```git clone https://github.com/XVimProject/XVim2```
- 构建XVim插件，```cd XVim2; make uninstall; make```
- 重启Xcode，启动时会提示是否装载该插件，选择装载，根据提示一路点击直到顺利进入Xcode编辑器界面
- XVim的配置依赖配置文件~/.xvimrc，可以根据需要自定义该配置文件
## 1.2 Theme
Xcode提供了多种配色方案的主题可供选择，开发者可以根据个人喜好进行选择。
## 1.3 Shortcuts
Xcode也提供了预定义的快捷键配置方案，开发者可以根据个人喜好进行自定义，以方便提升Xcode操作效率。Xcode中预定义的快捷键也可能会与用户自定义的系统快捷键产生冲突，需要对快捷键进行调整。
### 1.3.1 如何重置预定义快捷键
修改Xcode快捷键的时候可能会不小心改乱了配置，当想要重置的时候发现Xcode没有提示默认快捷键是啥，这时可以删除用户相关的Xcode快捷键配置文件，然后重启Xcode即可恢复所有预设的快捷键。快捷键配置文件路径为：```~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings```。
### 1.3.2 常用快捷键
这里总结了Xcode开发过程中常用的操作，并将其绑定到了自定义快捷键上。

| 常用操作 | 快捷键 |
|:----------:|:--------:|
|Jump to Definition|⌃+⌘+B|
|Go forward|⌃+⌘+[|
|Go backward|⌃+⌘+]|
|Quick documentation|⌥+left click|
|Show Completion|⌘+J|
|Search in file|⌘+F|
|Search in project|⇧+⌘+F|
|Quick open file|⇧+⌘+O|
|Reformat code|⌃+⌘+L|
|Move focus to editor|⌃+⌘+K|

这是截止到现在我使用的最多的快捷键组合，其他的在使用过程中陆续学习、整理吧。

## 1.4 Completion
### Xcode里面代码自动完成功能，在头文件中是不生效的！定义实现类的时候，将定义放头文件*.h里面，实现放*.m里面，养成好习惯吧。

# 2 调试器
Xcode调试iOS、iPad、AppleTV软件有两种方式，通过真机调试和通过模拟器调试的方式。
## 2.1 真机调试
### 2.1.1 Connect via USB
真机调试，即需要通过USB线将对应的设备与开发机Xcode建立连接，Xcode能够自动识别连接的设备，并显示在```Devices and Simulators```列表中。此时可以选择真机设备，并点击运行按钮。Xcode将自动构建好程序，并完成签名过程，然后将其安装到真机中，并最终在真机上启动程序。
### 2.1.2 Connect via Network
另外，真机调试过程中，有时希望不借助USB线连接，能否通过网络连接进行调试呢？可以！
实际上同一真机设备，只有在第一次真机调试时才需要通过USB线进行连接的方式。后续调试该机器的时候，可以将真机接入同一wifi网络，然后在```Xcode->Windows->Devices and Simulators```中选中对应的真机，勾选上```Connect via Network```。如果设备通过网络连接上了Xcode，设备对应列表项右侧会显示一个网络图标。如果连接不上，可以手动触发连接操作，即选中设备，呼出鼠标右键菜单，选择```Connect via IP Address```，查看待调试的真机对应的ip地址，然后填写ip地址并connect即可。

## 2.2 模拟器调试
模拟器调试，即通过Xcode内置安装的iOS、iPad、AppleTV模拟器进行调试，类似于Android开发过程中使用IDE内置ADT安装的Android模拟器调试Android程序。
以后遇到对模拟器相关的设置、控制、网络模拟等关键操作时再予以补充，这里就不展开了。

# 






