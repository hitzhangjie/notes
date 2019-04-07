# GoNeat Design

GoNeat，追求“小而美”的设计，是基于golang开发的面向后台开发的微服务框架，旨在提升后台开发效率，让大家摆脱各种琐碎的细节，转而更加专注于服务质量本身。Simple but Powerful，是GoNeat的不懈追求，也是我们始终追求的设计理念。

本文从整体上介绍GoNeat的设计，希望能让大家从全局上认识GoNeat是如何运行的，运行期间涉及到哪些处理流程，处理读者对某部分感兴趣，可以自行阅读对应部分的源码，或者与我们开发者交流，都是可以的。

## GoNeat 整体架构

下图展示了GoNeat的整体架构设计，为了能简单直观地介绍GoNeat的整体工作流程，在下图中省略了部分细节。省略掉的部分细节也是比较重要的，我会提到它们，篇幅原因不会过多描述。

![GoNeat](assets/GoNeat-Arch.png)

GoNeat整体架构设计中，包括如下核心组成部分:

- NServer，代表一个GoNeat服务，一个NServer可以插入多个NServerModule；
- NServerModule，代表一个服务模块，其实现包括StreamServer、PacketServer、HttpServer、HippoServer；
- Codec Handler，代表一个协议Handler，其实现包括nrpc、ilive、simplesso、sso、http等编码的协议Handler；
- 不同port上可以分别提供不同协议的服务，如8000端口提供tcp/udp的nrpc服务，而8080提供http服务；
- 不同port上到达的请求，经协议Handler解析出请求报文，并根据请求报文中的命令字，找到注册的CmdHandler；
- NServer将请求以函数参数的形式递交给注册的CmdHandler处理，处理完毕返回结果给调用方；

介绍完框架的核心组件及作用之后，下面结合一个示例服务的执行流程，介绍下服务启动、处理请求、服务退出的详细流程及设计细节。

## GoNeat 服务示例

我们仍然使用“*test_nrpc.proto*”作为示例服务pb：

```protobuf
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

使用gogen来创建一个新的go-neat服务：

```bash
gogen create -protocol=nrpc -protofile=test_nrpc.proto -httpon
```

与“*Program Your Next Server in GoNeat*”一问不同的是，这里多加了一个参数“*-httpon*”，目的是介绍多协议的处理细节。运行上述命令后，应生成如下目录结构的服务模板。

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

## GoNeat 内部设计

一直没想清楚，该以什么样的方式来描述GoNeat的设计细节，我

## GoNeat - 初始化

#### 初始化：配置说明

GoNeat框架读取的配置文件，包括：

1. service.ini，包括框架核心配置项，以及rpc相关配置项，也添加自定义配置项：

   **[service]** 框架核心配置项：

   - 日志相关：日志级别，保留日志文件数量，单日志文件的大小；

   - 性能相关：允许的最大入tcp连接数，允许的最大并发请求数，

   - 内存调优：workerpool允许创建最大协程数，udp收包buffer大小；

   - 服务质量：服务接口的超时时间，处理请求时进行全局超时控制；

   - 服务名称：分布式跟踪时用于追踪span节点；

     ```ini
     [service]
     name = test_nrpc               			 #服务名称
     
     log.level = 1                        #框架日志级别,0:DEBUG,1:INFO,2:WARN,3:ERROR
     log.size = 64MB                      #日志文件大小,默认64MB,可以指定单位B/KB/MB/GB
     log.num = 10                         #日志文件数量,默认10个
     
     limit.reqs = 100000                  #服务允许最大qps
     limit.conns = 100000                 #允许最大入连接数
     
     workerpool.size = 20000              #worker数量
     udp.buffer.size = 4096               #udp接收缓冲大小(B),默认1KB,请注意收发包尺寸
     
     BuyApple.cmd.timeout = 5000          #服务接口BuyApple超时时间(ms)
     SellApple.cmd.timeout = 5000         #服务接口SellApple超时时间(ms)
     ```

   **[habo]** 哈勃监控配置项：

    -  是否启用哈勃监控；

    -  申请的dcid，dc上报数据同步到habo；

    -  dc上报测试环境，还是线上环境；

       ```ini
       [habo]
       enabled = true                       #是否开启模调上报
       caller = content_strike_svr          #主调服务名称
       dcid = dc04125                       #罗盘id
       env = 0                              #0:现网(入库tdw), 1:测试(不入库tdw)
       ```

   **[nrpc-service]** 协议handler配置项：

    -  nrpc协议handler监听的tcp端口；

    -  nrpc协议handler监听的udp端口；

       ```ini
       [nrpc-service]
       tcp.port = 8000                      #tcp监听端口
       udp.port = 8000                      #udp监听端口
       ```

   **[http-service]** 协议http配置项：

   - http协议监听的端口；

   - http请求URL前缀；

     ```ini
     [http-service]
     http.port = 8080                     #监听http端口
     http.prefix = /cgi-bin/web           #httpUrl前缀
     ```

   **[rpc-test_nrpc]** rpc配置项：

    -  rpc调用地址，支持ip://ip:port、l5://mid:cid、cmlb://appid（服务发现能力正在开发验证中）

    -  传输模式，支持UDP、UDP全双工、TCP短连接、TCP长连接、TCP全双工，TCP/UDP SendOnly

    -  rpc超时时间，包括默认的timeout以及细化到各个接口的超时时间；

    -  rpc监控monitorid，包括总请求、成功、失败、耗时分布monitor id；

       ```ini
       [rpc-test_nrpc]
       addr = ip://127.0.0.1:8000           #rpc调用地址
       proto = 3                            #网络传输模式,
                                            #1:UDP,
                                            #2:TCP_SHORT,
                                            #3:TCP_KEEPALIVE,
                                            #4:TCP_FULL_DUPLEX,
                                            #5:UDP_FULL_DUPLEX,
                                            #6:UDP_WITHOUT_RECV
       timeout = 1000                       #rpc全局默认timeout
       BuyApple.timeout = 1000              #rpc-BuyApple超时时间(ms)
       SellApple.timeout = 1000             #rpc-SellApple超时时间(ms)
       
       monitor.BuyApple.timecost10 		= 10001 		#耗时<10ms
       monitor.BuyApple.timecost20 		= 10002			#耗时<20ms
       monitor.BuyApple.timecost50 		= 10003			#耗时<50ms
       monitor.BuyApple.timecost100 		= 10004			#耗时<100ms
       ...
       monitor.BuyApple.timecost2000 		= 10005		#耗时<2000ms
       monitor.BuyApple.timecostover2000 = 10006		#耗时>=2000ms
       ...
       ```

2. monitor.ini，用于监控服务接口本身的总请求量、处理成功、处理失败量，以及处理耗时分布情况：

   **[test_nrpc]** 服务接口本身监控打点monitor id：

   ```ini
   [test_nrpc]
   
   //服务接口-BuyApple
   monitor.BuyApple.timecost10=0                #接口BuyApple延时10ms
   monitor.BuyApple.timecost20=0                #接口BuyApple延时20ms
   monitor.BuyApple.timecost50=0                #接口BuyApple延时50ms
   ...
   monitor.BuyApple.timecost2000=0              #接口BuyApple延时2000ms
   monitor.BuyApple.timecost3000=0              #接口BuyApple延时3000ms
   monitor.BuyApple.timecostover3000=0          #接口BuyApple延时>3000ms
   
   //	服务接口-SellApple
   monitor.SellApple.timecost10=0                #接口SellApple延时10ms
   monitor.SellApple.timecost20=0                #接口SellApple延时20ms
   monitor.SellApple.timecost50=0                #接口SellApple延时50ms
   ...
   monitor.SellApple.timecost2000=0              #接口SellApple延时2000ms
   monitor.SellApple.timecost3000=0              #接口SellApple延时3000ms
   monitor.SellApple.timecostover3000=0          #接口SellApple延时>3000ms
   ```

3. log.ini，代替service.ini中logging相关配置，用来支持工厂模式获取logger：

   这里默认配置了三个logger：

   - 框架处理日志log，go_neat_frame.log，最多保留5个日志文件，单文件上限100MB，写满则滚动；
   - 框架请求流水log，go_neat_access.log，最多保留5个日志文件，单文件无上限，按天滚动；
   - 默认log，default.log，最多保留5个日志文件，单文件上限100MB，写满则滚动；

   ```ini
   #框架内部日志
   [log-go_neat_frame]
   level = 1                       #日志级别,0:DEBUG,1:INFO,2:WARN,3:ERROR
   logwrite = rolling
   logFileAndLine = 1
   rolling.filename = go_neat_frame.log
   rolling.type = size
   rolling.filesize = 100m
   rolling.lognum = 5
   
   #框架流水日志
   [log-go_neat_access]
   level = 1                      #日志级别,0:DEBUG,1:INFO,2:WARN,3:ERROR)
   logwrite = rolling
   logFileAndLine = 0
   rolling.filename = go_neat_access.log
   rolling.type = daily
   rolling.lognum = 5
   
   #服务默认日志
   [log-default]
   level = 1                     #日志级别,0:DEBUG,1:INFO,2:WARN,3:ERROR)
   logwrite = rolling
   logFileAndLine = 0
   rolling.filename = default.log
   rolling.type = size
   rolling.filesize = 100m
   rolling.lognum = 5
   ```

4. trace.ini，用于分布式跟踪相关的配置：

   GoNeat框架通过opentracing api支持分布式跟踪，支持三种backend实现，zipkin、jaeger、天机阁：

   - **[zipkin]** 配置

     ```ini
     [zipkin]
     enabled = true                                              #是否启用zipkin trace
     service.name = test_nrpc                                    #当前服务名称(span endpoint)
     service.addr = *:8000                                       #当前服务地址(span endpoint)
     collector.addr = http://9.24.146.130:8080/api/v1/spans      #zipkin collector接口地址
     traceId128bits = true                                       #是否启用128bits traceId
     ```

   - **[jaeger]** 配置

     ```ini
     [jaeger]
     enabled = false                                             #是否启用jaeger trace(暂未验证兼容性)
     service.name = test_nrpc                                    #当前服务名称(span endpoint)
     service.addr = *:8000                                       #当前服务地址(span endpoint)
     collector.addr = http://9.24.146.130:8080/api/v1/spans      #jaeger collector接口地址
     traceId128bits = true                                       #是否启用128bits traceId
     ```

   - **[天机阁]** 配置

     ```ini
     [tianjige]
     enabled = false                                             #是否启用天机阁 trace
     service.name = test_nrpc                                    #当前服务名称(span endpoint)
     service.addr = *:8000                                       #当前服务地址(span endpoint)
     collector.addr = 10.101.192.79:9092                         #天机阁 collector接口地址
     traceId128bits = true                                       #是否启用128bits traceId
     appid = ${your_applied_appid}                               #天机阁申请的appid
     ```

#### 初始化：配置加载

在详细介绍了GoNeat依赖的配置文件及各个配置项之后，来介绍下GoNeat的配置解析、加载过程。

GoNeat支持两种格式的配置文件:

- 一种是“*ini格式*”的配置文件，
- 一种是“json格式”的配置文件。

配置加载，发生在NServer实例化过程中，**default_nserver.NewNServer()**，此时会加载service.ini、monitor.ini、log.ini，并根据配置信息完成NServer实例化。

```mermaid
sequenceDiagram

default_nserver ->> nserver : NewNServer()
activate default_nserver
activate nserver
nserver ->> nserver : NewNServer()
nserver ->> config : config.NewIniConfig()
activate config
config ->> config : load & parse
config -->> nserver : return config
deactivate config
nserver ->> nserver : init log, monitor, NServer
deactivate nserver
nserver -->> default_nserver : return NServer instance
deactivate default_nserver
```

#### 初始化：logging

NServer实例化过程中，会创建三个logger对象：

- go_neat_frame，框架处理逻辑日志，对应log.ini中的[go_neat_frame]；
- go_neat_access，框架请求流水日志，对应log.ini中的[go_neat_access]；
- default，框架默认日志，对应log.ini中的[default]；

每个logger对象的创建都是按照如下流程去执行的，**nlog.GetLogger(logger)**，会首先检查loggerCache中key=$logger的logger对象是否已经存在，如果存在则直接返回，反之，加载log.ini中的配置[\$logger]，检查logwrite配置项，logwrite指定了日志输出的目的地，如：

- console，输出到控制台；
- simple，普通日志文件，不支持股东；
- rolling，支持滚动的日志文件，包括按照日期滚动、文件大小滚动；

logwrite允许逗号分隔多个输出，如`logwrite = console, rolling`，那么此时logger.Info(…)输出的信息将同时输出到控制台和滚动日志文件，详细可参考**nlog.MultiWriterLogWriter**实现。

> **nlog.MultiWriterLogWriter**可以进一步重构，如支持将日志信息上报到elasticsearch、天机阁等其他远程日志系统，现在的实现稍作修改就可以支持第三方日志组件实现，elasticsearch、天机阁等远程日志组件只要实现nlog.NLog接口并完成该实现的注册即可。

```mermaid
sequenceDiagram



nserver ->> nlog : NewLogger(logger)
activate nserver
activate nlog
nlog ->> cache : get logger via cache
cache -->> nlog : return one if cached
nlog ->> nlog : load conf
note right of nlog : section [$logger]
nlog ->> nlog : init logger
note right of nlog : console logger,<br>simple logger,<br>rolling logger
nlog ->> nlog : addWriter
note right of nlog : one logger can<br>have multi output<br> destinations
nlog -->> nserver : return logger
deactivate nlog
deactivate nserver

```

#### 初始化：tracing

分布式调用链对GoNeat框架来说是可插拔的，回想一下trace.ini，我们支持三种调用链backend实现，包括zipkin、jaeger以及公司内部的天机阁，如果希望在服务中使用tracing：

- 使用zipkin，那么在程序中`import _ “git.code.oa.com/go-neat/core/depmod/trace/zipkin`即可；
- 使用jaeger，那么在程序中`import _ “git.code.oa.com/go-neat/core/depmod/trace/jaeger`即可；
- 使用天机阁，那么在程序中`import _ “git.code.oa.com/go-neat/core/depmod/trace/tianjige`即可；

当然除了import对应的调用链实现，也要对配置文件做调整：

- 使用zipkin，trace.ini里面设置zipkin.enabled = true；
- 使用jaeger，trace.ini里面设置jaeger.enabled = true;
- 使用天机阁，trace.ini里面设置tianjige.enabled = true;

> 如果后续想要扩展tracing backend，只需要提供对应的tracer初始化方法就可以了，类似于zipkin、jaeger、天机阁初始化方式。如果要在项目中使用该tracing实现，通过import对应实现+配置文件激活就可以。import对应的tracing backend初始化，并添加对应的初始化配置，that’s it!

#### 初始化：协议handler

##### 需要我做什么？

GoNeat框架支持在单个进程中同时支持多种业务协议，如：

- 在port 8000提供nrpc服务，
- 在port 8001提供ilive协议，
- 在port 8080提供http服务。

以提供nrpc服务为例，只需要做3件事情，包括：

- 配置文件service.ini中增加[nrpc-service]配置项，指明要绑定的端口，如`tcp.port = 8000`；
- 代码引入协议handler，如`import _ "git.code.oa.com/go-neat/core/proto/nrpc/nprc_svr/default_nrpc_handler"`；
- 代码注册nrpc命令字，如`default_nserver.AddExec(“BuyApple”, BuyApple)`；

如果要在此基础上继续支持http服务呢，一样的三件事，包括：

- 配置文件service.ini中增加[http-service]配置项，指明要绑定的端口及url前缀，如：

  ```ini
  [http-service]
  http.port = 8080
  http.prefix = /cgi-bin/web
  ```

- 代码引入协议handler，如`import _ “git.code.oa.com/go-neat/core/proto/http/dft_httpsvr”`；

- 代码注册http uri，如`default_nserver.AddExec(“/BuyApple”, BuyApple)`；

That’s all！GoNeat要支持常用的业务协议，只需要做上述修改即可，是不是看上去还挺简单方便！

> 还记得写一个spp服务同时支持多种协议，需要在spp_handle_input里面区分端口来源，然后再调用对应的解包函数，判断请求命令字，转给对应的函数处理，每次有这种需要都需要写一堆这样的代码，好啰嗦！

##### 框架做了什么？

不知道读者是否注意到，nrpc命令字`BuyApple`，http请求`$host:8080/cgi-bin/web/BuyApple`，这两种不同的请求最终是被路由到了相同的方法`BuyApple`进行处理，意味着开发人员无需针对不同的协议做任何其他处理，GoNeat框架帮你搞定这一切，业务代码零侵入。

真的业务代码零侵入吗？http请求参数Get、POST方式呢？nrpc协议是protbuf格式呢？同一份业务代码如何兼容？

GoNeat对不同的业务协议抽象为如下几层：

- 协议定义，如nrpc、ilive、simplesso、http包格式；
- 协议handler，完成协议的编码、解码操作（接口由NHandler定义）；
- 会话session，维持客户端请求、响应的会话信息（接口由NSession定义）；

当希望扩展GoNeat的协议时，需要提供协议的包结构定义、协议的编解码实现、协议会话实现，nrpc协议对应的会话实现为NRPCSession、http协议对应的会话实现时HttpSession。

好，现在介绍下一份代码`func BuyApple(ctx context.Context, session nsession.NSession) (interface{}, error)`为什么可以支持多种协议。从下面的代码中不难看出，秘密在于不同协议会话对`NSession.ParseRequestBody(…)`的实现：

- 如果是pb协议，session里面会直接通过`proto.Unmarshal(data []byte, v interface{})`来实现请求解析；
- 如果是http协议，session里面会多做些工作：
  - 如果是`POST`方法，且`Content-Type=“application/json”`，则读取请求体然后`json.Unmarshal(...)`接口；
  - 其他情况下，读取GET/POST请求参数转成map[param]=value，编码为json再反序列化为目标结构体；

    ```go
    func BuyApple(ctx context.Context, session nsession.NSession) (interface{}, error) {
      req := &test_nrpc.BuyAppleReq{}
      err := session.ParseRequestBody(req)
      ...

      rsp := &test_nrpc.BuyAppleRsp{}
      err = BuyAppleImpl(ctx, session, req, rsp)
      ...
      return rsp, nil
    }

    func BuyAppleImpl(ctx context.Context, session nsession.NSession, req *test_nrpc.BuyAppleReq, rsp *test_nrpc.BuyAppleRsp) error {
      // business logic
      return nil
    }

    ```

Google Protocol Buffer是一种具有自描述性的消息格式，凭借良好的编码、解码速度以及数据压缩效果，越来越多的开发团队选择使用pb来作为服务间通信的消息格式，GoNeat框架也推荐使用pb作为首选的消息格式。

由于其自描述性，pb文件被用来描述一个后台服务是再合适不过了，基于此也衍生出一些周边工具，如自动化代码生成工具gogen用来快速生成服务模板、client测试程序等等。

## GoNeat - 服务启动

前面零零散散地介绍了不少东西，配置文件、配置加载、logging初始化、tracing集成、协议handler注册，了解了这些之后，现在我们从整体上来认识下GoNeat服务的启动过程。

说是从整体上来认识启动流程，并不意味着这里没有新的细节要引入。中间还是会涉及到一些比较细节的问题，如tcp、udp监听如何处理的，为什么要支持端口重用，为支持平滑退出需要做哪些准备等等。也许这里章节划分的不是特别科学，希望我按照一个GoNeat服务的生命周期来叙述，能尽可能多地覆盖到那些必要的设计和细节。

## GoNeat - 服务怠速

## GoNeat - 请求处理

## GoNeat - 监控上报

## GoNeat - 平滑退出

## GoNeat - More

