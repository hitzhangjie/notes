protobuf开发环境搭建，主要包括两部分内容：

- protobuf compiler的安装
- 对应编程语言的插件安装，如golang依赖的protoc-gen-go插件

protobuf 及 protoc-gen-go安装：
1、https://github.com/protocolbuffers/protobuf
     v3.6.0+以上版本支持map解析，syntax=2、3消息序列化后是二进制兼容的
     git checkout v3.6.1.3
     ./configure
     make -j8
     make install
2、git clone https://github.com/golang/protobuf golang-protobuf
     cd golang-protobuf
     make install
     默认安装到$GOPATH/bin下面，记得将该路径加到$PATH