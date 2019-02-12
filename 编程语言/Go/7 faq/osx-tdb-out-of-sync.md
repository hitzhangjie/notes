OS X升级到10.14之后，涉及到cgo的编译会报如下错误，这个在旧版的OS X中，是可以通过`xcode-select —install`重装工具链来解决的，新版本的系统不行，据网友们反映从OSX升级到10.13.6之后开始，这个方法就行不通了。


>ld: warning: text-based stub file /System/Library/Frameworks//CoreFoundation.framework/CoreFoundation.tbd and library file /System/Library/Frameworks//CoreFoundation.framework/CoreFoundation are out of sync. Falling back to library file for linking.
>ld: warning: text-based stub file /System/Library/Frameworks//Security.framework/Security.tbd and library file /System/Library/Frameworks//Security.framework/Security are out of sync. Falling back to library file for linking.

那么如何解决上述问题呢？执行下面两行命令就可以了：
```
sudo ln -s  /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/CoreFoundation.framework /Library/Frameworks/CoreFoundation.framework 
sudo ln -s  /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Security.framework /Library/Frameworks/Security.framework
```

现在再次编译就不会再报上述warning信息了，这个warning信息虽然不会影响最终的编译，但是每次都弹出来，很是烦人，不了解各种情况的会以为编译出错了呢。