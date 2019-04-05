# Program Your Next Server in GoNeat

## 框架简介

GoNeat，是一个基于golang开发的面向后台开发人员的RPC框架，目前正在向更完善的微服务框架演进。

## 设计理念

GoNeat，追求“小而美”的设计，是基于golang开发的面向后台开发的微服务框架，旨在提升后台开发效率，让大家摆脱各种琐碎的细节，转而更加专注于服务质量本身。Simple but Powerful，除了高性能的处理能力，也支持服务注册发现、rpc调用、立体化监控、集成常用公司组件，还支持一键快速配置开发环境，支持一键生成服务代码、测试代码让开发、测试变得更简单高效。目前仍然在持续演进中，欢迎体验、加入到我们中来……Try programming your next server in GoNeat！

## 问题答疑

设计理念代表了我们追求的目标，但并未表明它做了什么、如何做的，想必大家有很多问题要问，比如：

- 我们公司内已经有going框架了，为什么又要再造一个轮子？
- 我们已经有比较完善的Tars微服务框架以及一系列的开发、部署、运维工具了，你们的定位是什么？
- C++同学可能会说SPP已经证明了它的价值，有必要在golang方面投入这么大精力吗，而且是重新造一个轮子？
- Java同学可能也会问，难道只是为了借助协程更容易地实现并发，Java也可以基于Kilim、Quasa实现协程啊？
- 其他？

从个人角度来看，真心希望编程只是解决问题的工具，如同用一个科学计算器代替手工演算一般，我们要掌握计算方法，但并不意味着每次都要实施一遍。反观日常开发，重复搬砖的工作每天都在发生，关心cmlb、l5的路由及更新方式，关心传输层tcp、udp收发包的细节，关心各业务方协议头如何设置、命令字是多少、如何编解码，各接口成功、失败、耗时分布情况上报，请求体加refer来区分模块依赖情况……的确是开发应关心的，但真的要亲力亲为？

一个良好的RPC框架会是一个不错的选择，但是，如何选择呢？选择是困难的！

- spp

  spp，是公司内用的比较多的c++服务端框架，其设计思想在前些年应该还是很时髦的，同步框架结合协程“同步编码、异步运行”确实助力不少，谁也不想去写回调，是不是？在其基础上团队也封装了RPC调用的接口来简化日常开发中协议头、命令字、l5路由及更新的重复编码，但毕竟治标不治本，需要解决的也不只是这些问题。内存管理、协程栈大小、阻塞型系统调用等等，能避免这些问题固然可贵，但是寻求更好的方案似乎更值得期待。

- jungle

  jungle，是公司内用的比较多的java服务端框架，其引入了kilim框架，借助字节码增强来对服务代码进行协程化处理，当然也支持多线程、纯异步的方式。因为kilim停止更新，仅支持jdk 1.7的字节码，这也为我们的选择划上了一个问号，为此，我们也尝试基于quasa替换kilim的方案（详见Java版Neat），但面对java官方支持协程的声音，是否真的值得投入呢，也是一个问号。

- going

  going，是目前公司内流行的golang服务端框架，获得了很多golang开发者的认可，为golang在公司内的推广做出了一定的贡献，我们也尝试过基于going开发，相比spp而言，golang本身的优势确实有助于提升开发效率，但设计上，going与spp并没有明显设计上的差异，似乎我只是用go代替c++进行spp式的开发。也有团队尝试在going基础上封装rpc的调用方式，但并不希望将设计一个高性能、稳定的网络库来作为一个框架的开始或者结束。

- tars

  tars，在内部也称为taf（total application framework），它考虑了从开发、部署、运维、监控的方方面面，这是它的优点。现实情况是，当时的团队没有采用tars，对tars的了解、体验、应用也比较缺乏，最近也有在进一步学习、了解tars的设计，因为tars涉及到的东西比较多，开发、部署、运维、监控，短时间内快速掌握tars可能有点难度。

作为一名开发人员，没有什么比写几行代码改变全世界更有成就感的了，仔细考虑下，开发工作中因为处理各种琐碎的细节占据了大量的时间，路由、编解码、请求、响应、上报等等吧，业务逻辑与这些细节处理纠缠在一起，实在难说对每天的编码心怀期待，可心里还梦想着快乐地编码呢？

GoNeat的定位，并不是仅仅成为一个高性能的网络框架，其设计思想来源于日常开发中遇到的各种痛点，通过设计和抽象来提炼、泛化这些问题，并提供一个更加友好的解决方案。

举几个例子感受下：

- 还在写cgi透传请求给后台业务服务？GoNeat，支持将后台接口以http的方式暴露出去并支持鉴权；
- 支持多种业务协议，spp_handle_input区分端口再解包？GoNeat，支持import对应协议handler一行代码搞定；
- 还在手动cmlb、l5获取路由、完成路由更新？GoNeat，支持自动获取路由并根据请求结果完成路由更新；
- 还在手动创建业务包头、设置命令字、编解码？GoNeat，支持rpc调用自动完成相关设置、完成路由处理；
- 请求体里面添加refer字段区分调用方？GoNeat，支持rpc调用自动tracing数据上报；
- 调用服务接口忘记上报monitor总请求、成功、失败以及延时？GoNeat，支持自动上报habo完成相关统计；
- 拷贝服务代码作为新工程？GoNeat，支持通过pb文件一键生成服务模板、测试代码；
- 其他；

我们能做的当然不止这些，目前在尝试的还有运行时metrics、console、更方便友好的pprof、服务注册发现等等。

## 快速开始

在使用GoNeat进行开发之前，我们假定您已经：

- 已经系统学习过golang开发，包括GOPATH环境变量配置、golang基础、编译工具链使用等等，
- 已经配置了go开发环境，安装了go v1.9+；
- 已经安装了make；

好的，现在可以进行GoNeat开发相关的准备了：

- 下载GoNeat开发环境配置脚本：
  `git.code.oa.com/go-neat/core/install.sh`;

- 添加执行权限并开始安装：
  `chmod +x install.sh && ./install.sh`

- 校验安装是否已经ok：
  ```bash
  which gogen
  which protoc
  which protoc-gen-go
  ```

- 试着运行命令gogen来查看命令支持的选项，我们将利用gogen来创建第一个工程：

  ```bash
  
  	how to display help:
  		gogen help
  
  	how to create project:
  		gogen create -protodir=. -protofile=*.proto -protocol=nrpc -httpon=false
  		gogen create -protofile=*.proto -protocol=nrpc
  
  	how to update project:
  		gogen update -protodir=. -protofile=*.proto -protocol=nrpc
  		gogen update -protofile=*.proto -protocol=nrpc
  
  	how to pull/push rpc:
  		gogen pull -protocol=nrpc
  		gogen push -protocol=nrpc
  
  ```

好的，我们选择pb这种自描述的消息格式，来作为服务描述文件（pb类似于jce）：

 -  下面创建一个pb文件*test_nrpc.proto*来描述一个服务：

    ```bash
    	syntax = "proto2";
    	package test_nrpc;
    
    	// BuyApple
    	message BuyAppleReq {
    			optional uint32 num = 1;
    	};
    
    	message BuyAppleRsp {
    			optional uint32 errcode = 1;   
    			optional string errmsg = 2;
    	};
    
    	// SellApple
    	message SellAppleReq {
    			optional uint32 num = 1;
    	};
    
    	message SellAppleRsp {
    			optional uint32 errcode = 1;   
    			optional string errmsg = 2;
    	};
    
    	// service test_nrpc
    	service test_nrpc {
    			rpc BuyApple(BuyAppleReq) returns(BuyAppleRsp);     // CMD_BuyApple
    			rpc SellApple(SellAppleReq) returns(SellAppleRsp);  // CMD_SellApple
    	}
    ```

-  执行gogen命令来完成工程的创建：

    ```bash
    gogen create -protocol=nrpc -protofile=test_nrpc.proto
    ```

-  检查创建的工程目录结构：

    ```bash
    test_nrpc
    ├── Makefile
    ├── README.md
    ├── client
    │   └── test_nrpc_client.go
    ├── conf
    │   ├── log.ini
    │   ├── monitor.ini
    │   ├── service.ini
    │   └── trace.ini
    ├── deploy.ini
    ├── log
    └── src
        ├── exec
        │   ├── exec_test_nrpc.go
        │   ├── exec_test_nrpc_impl.go
        │   └── exec_test_nrpc_init.go
        └── test_nrpc.go
    
    5 directories, 12 files
    
    ```

    > 如果工程没有生成，请加参数`-v`来查看详细地log信息，方便定位问题，常见的问题为目录写权限问题：gogen默认会写/data/home/goneat/…路径，将生成的rpc文件移动到这个目录下，如果希望调整默认路径请修改gogen配置文件调整，详见~/.gogen/protospec.json。

-  构建服务端、测试程序，并对接口进行测试：

    ```bash
    #编译服务端、测试程序
    cd test_nrpc
    make && make client
    
    #启动服务端
    cd bin
    nohup ./test_nrpc &
    
    #启动测试程序
    ./test_nrpc_client -cmd=BuyApple
    ```

    > 相信大家在掌握了工具gogen的使用，并对GoNeat框架执行逻辑做了基本理解之后，快速从零搭建一个GoNeat服务是分分钟就可以搞定的事情，剩下的就是完善服务的业务逻辑了。

-  服务的业务逻辑代码在何处编写呢：

    参考上述生成的工程结构，其中：

    - *src/test_nrpc.go*，是服务入口，并且通过*import _ “exec”*的方式对package exec下的包进行了初始化；
    - package exec下的包通过*default_nserver.AddExec(“BuyApple”, BuyApple)*完成了命令字和接口的绑定；
    - 当通过test_nrpc_client -cmd=BuyApple发起请求时，请求将转发给方法BuyApple进行处理；
    - gogen生成的服务模板中，BuyApple方法实际上会调用BuyAppleImpl方法完成业务逻辑处理，BuyApple内部负责解析请求参数、处理逻辑错误，所以BuyApple的逻辑代码实际上是在BuyAppleImpl方法中实现的。

    > 大家可以在BuyAppleImpl中做些简单的逻辑处理后进行测试，如修改响应结构体rsp中的字段值。

## 服务质量

选择一个框架进行开发、上线的前提是，服务是不是稳定，性能是否满足要求，出问题后是否能快速定位并解决问题。

GoNeat经过了一年多的开发，目前已经趋于稳定，在PCG信息流平台产品部平台产品中心已经推广使用，半年多以来经过广大开发侧同学的反馈建议、讨论实施、新特性开发、bugfix等等，目前使用GoNeat开发的同学越来越多，使用GoNeat开发的服务线上部署也越来越多。

我们也成立了专门的GoNeat Q&A群，来对GoNeat相关问题进行答疑，协助解决GoNeat使用期间遇到的问题。

欢迎大家体验GoNeat，也欢迎大家反馈意见和建议，Try programming your next server in GoNeat！



