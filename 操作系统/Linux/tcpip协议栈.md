tcp连接终止问题：

**情景一：杀进程**

tcp连接主动打开的一端，假如被kill -9杀掉，那么该方会主动发FIN包；
但是如果连接如果是被动打开的（如server端接听连接请求），当服务被kill -9杀掉时不会发送FIN包，而是发送RST包。

**情景二：socket buffer中是否有数据**

对于server端而言，client通过tcp连接向其发送数据，当server关闭时：

- 假如连接socket buffer中还有数据未读取，则发送RST包给客户端；
- 假如连接socket buffer中没有数据要读取，则发送FIN包给客户端；

**情景三：server端主动关连接后，client发送数据，收到RST包，但是api没有返回错误**

如go中conn.Write()返回的error为nil，没有报Broken Pipe错误，需要等到第二次发送数据的时候才会检测到。Why？

**情景4：进程不再了之后，但是连接状态还未完全销毁，发包给对方，会返回RST。**

操作系统认为这个连接虽然未完全关闭，但是socket归属的进程都没了，肯定没有上层来处理了，buffer里面有没有数据都不会被处理了，直接RST快速断开连接吧。

这几种场景是否能够统一起来呢？

