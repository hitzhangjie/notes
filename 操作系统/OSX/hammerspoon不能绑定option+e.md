应该是苹果的一个bug，可以参考我当年提的这个issue，check、uncheck这个系统设置选项(option+e打开finder搜索)、reload hammerspoon配置就ok了！

https://github.com/Hammerspoon/hammerspoon/issues/1961



简要总结：

- 默认情况下，系统里面是keyword-settings-spotlight，这里有个设置项option+e默认打开finder搜索界面；
- 虽然没有勾选上，但是是分配了option+e的，只是没有启用，但是也算是被分配了；
- 解决办法就是将这里的option+e先改成command+e，释放option+e，然后再reload hammerspoon，验证ok后，再将设置的打开finder搜索界面的快捷键禁用就可以了。

