# 更好地debug libmill？

osx下面通过```brew install libmill```安装的是共享库libmill.so，很多调试信息都已经被优化掉了，调试起来不是很方便，为了更好地进行调试，可以自己从源码构建安装libmill。

```
git clone https://github.com/sustrik/libmill
cd libmill

./autogen.sh
./configure --disable-shared --enable-debug --enable-valgrind

make -j8
sudo make install
```

