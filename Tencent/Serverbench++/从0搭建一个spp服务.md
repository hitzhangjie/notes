# 从0搭建一个spp服务

## 1.创建proto文件

proto文件中必须声明大命令字、小命令字，即：

```
enum BIG_CMD {
    CMD = 0x???;
};

enum SUB_CMD {
    S_CMD1 = 1;
    S_CMD2 = 2;
    ...
};
```

如果不声明大小命令字，即便声明了service { rpc XXX(aReq) returns(aRsp); }，也不会创建出完整的工程，qapp_auto -proto_file=proto-filename创建出的工程中src目录下为空。

>看ilive_wns_proxy代码时发现，请求中的大小命令字可以用于匹配wns转发规则，这里的转发规则在管理后台huayangadmin.oa.com中的“wns转发”模块进行配置，规则中指定了业务类型、大小命令字、协议类型（如ilive_udp、qtalk_udp等）、是否登录态鉴权、预发布&测试地址、L5地址等，管理后台可以将这些规则发布到zk，然后ilive_wns_proxy这个服务回通过ZKUtil工具类定时去拉zk上的配置，并写入到服务的/conf/setting.json中（），并且一旦检测到文件内容发生改变就立即从中reload转发规则。
>
>转发规则被缓存到一个map中，k即cmd_subcmd，v就是规则详情，然后取出规则中的协议类型，调用匹配的协议Handler对包进行后续处理，后续的handler会在转发的时候通过规则中的L5寻址到后台的server。

## 2.创建工程

qapp_auto应被加入搜索路径，因此可以直接执行：qapp_auto -proto_file=filename.proto，创建过程中会输出项目创建进度的提示信息。

如果在service {}中定义了rpc，但是创建工程的时候却看到如下提示信息："move xxxxx_rpc.h to /data/home/spp_proj/......      no such file or directory"，请检查是否定义了命令字。

工程成功生成之后，会包含服务端程序代码、客户端测试代码两部分，应该分别构建。

## 3.编译工程

- 编译server程序，进入工程目录下的build，执行cmake ../src，然后执行make，为了加快编译速度，可以追加参数"-jN"，N表示并行编译的任务数量；
- 编译测试程序，编译测试程序之前，应修改测试程序main.cpp的一些配置，主要包括：请求uin、服务器地址ip:port、服务器L5等，然后cd到test/build下执行cmake ../src & make；

>由于鼓励使用L5寻址，因此qapp_auto构建工具生成的工程代码默认使用L5进行寻址，如何L5初始化失败执行rpc.call的时候会返回错误代码-2&-3，-2可能表示无法寻址，-3可能表示L5地址对应的服务不一致（没有进一步求证）。
>
>如果部署新server，需要申请L5，可以到L5管理系统中申请新增SID，得到分配的L5地址mid:cid，然后将机器ip绑定到分配的L5并下发配置即可。

## 4.部署服务端

spp是以插件的形式进行部署，首先需要安装spp_modules，然后才能将编译好的服务端插件*.so挂到spp_modules中运行。

从/data/home/spp_proj中搜索下载spp_modules.tgz，然后解压到测试环境的某个路径下，记为${spp_modules_path}，进入${spp_modules_path}/conf下，修改几个配置文件：

- service.yaml
   - 修改监听端口号（tcp/udp），修改时需要通过netstat -nlp检查所选端口是否已被其他服务占用
- spp_proxy.xml
   - 修改proxy监听的端口，要与service.yaml中保持一致；
   - 修改proxy要支持的模块，<module/>中添加自己编译好的*.so文件以及要读取的配置文件路径；
- spp_workerN.xml
   - 修改worker组要支持的模块，<module/>中添加自己编译好的*.so文件以及要读取的配置文件路径；

>备注：
>默认的日志级别比较低为0，可以按需修改。
配置文件修改完成之后，准备运行服务端程序：cd ${spp_modules}/bin & ./spp.sh start。

## 5.运行客户端测试

将编译好的测试程序运行之前，假定代码中L5修改正确的话，运行之前应确保所在机器能够正常寻址到服务端程序，在/user/local/services/l5_xxxx这个路径下有个工具L5GetRoute1，可以指定参数mid、cid、count对能否正确寻址进行测试。

假如测试程序运行异常，可以通过上述工具检查是否L5可以正常寻址。

rpc.call(req,rsp)后执行rsp.DebugString()后可以将rsp这个map中的信息打印出来（服务端的rpc接口中需要设置rsp的信息，如果不设置客户端打印的信息是空的，因为pb字段都是
optional，也不会报错）。

>客户端程序执行时，可能会报错：“获取共享内存失败”，这个跟shewang对了一下，可能跟数据上报有关（单台机器上报属性不能超过1000），我strace跟踪了一下看它在访问/data/dcagent的时候出错了，可能确实跟数据上报有关，有待进一步求证。

以前只修改过spp服务的bug、push的小工具，还没有完整地经历过一次创建、部署新server的过程，这次了解到不少东西，感谢小伙伴们的帮助。




