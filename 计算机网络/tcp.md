# TCP流量控制+拥塞控制算法

# Part 1 TCP流量控制

## 1.1 滑动窗口协议

需要说明一下，如果你不了解TCP的滑动窗口这个事，你等于不了解TCP协议。我们都知道，TCP必需要解决的可靠传输以及包乱序（reordering）的问题，所以，TCP必需要知道网络实际的数据处理带宽或是数据处理速度，这样才不会引起网络拥塞，导致丢包。

所以，TCP引入了一些技术和设计来做网络流控，Sliding Window是其中一个技术。 前面我们说过，TCP头里有一个字段叫Window，又叫Advertised-Window，这个字段是接收端告诉发送端自己还有多少缓冲区可以接收数据。于是发送端就可以根据这个接收端的处理能力来发送数据，而不会导致接收端处理不过来。 为了说明滑动窗口，我们需要先看一下TCP缓冲区的一些数据结构：

![img](assets/sliding_window.jpg)

上图中，我们可以看到：

- 接收端LastByteRead指向了TCP缓冲区中读到的位置，NextByteExpected指向的地方是收到的连续包的最后一个位置，LastByteRcved指向的是收到的包的最后一个位置，我们可以看到中间有些数据还没有到达，所以有数据空白区。

- 发送端的LastByteAcked指向了被接收端Ack过的位置（表示成功发送确认），LastByteSent表示发出去了，但还没有收到成功确认的Ack，LastByteWritten指向的是上层应用正在写的地方。

于是：

- 接收端在给发送端回ACK中会汇报自己的AdvertisedWindow = MaxRcvBuffer – LastByteRcvd – 1;

- 而发送方会根据这个窗口来控制发送数据的大小，以保证接收方可以处理。

下面我们来看一下发送方的滑动窗口示意图：

![img](assets/tcpswwindows.png)

（[图片来源](http://www.tcpipguide.com/free/t_TCPSlidingWindowAcknowledgmentSystemForDataTranspo-6.htm)）

上图中分成了四个部分，分别是：（其中那个黑模型就是滑动窗口）

- \#1已收到ack确认的数据。
- \#2发还没收到ack的。
- \#3在窗口中还没有发出的（接收方还有空间）。
- \#4窗口以外的数据（接收方没空间）

下面是个滑动后的示意图（收到36的ack，并发出了46-51的字节）：

![img](assets/tcpswslide.png)

下面我们来看一个接受端控制发送端的图示：

![img](assets/tcpswflow.png)

（[图片来源](http://www.tcpipguide.com/free/t_TCPWindowSizeAdjustmentandFlowControl-2.htm)）

## 1.2 Zero Window

上图，我们可以看到一个处理缓慢的Server（接收端）是怎么把Client（发送端）的TCP Sliding Window给降成0的。此时，你一定会问，如果Window变成0了，TCP会怎么样？是不是发送端就不发数据了？是的，发送端就不发数据了，你可以想像成“Window Closed”，那你一定还会问，如果发送端不发数据了，接收方一会儿Window size 可用了，怎么通知发送端呢？

解决这个问题，TCP使用了Zero Window Probe技术，缩写为ZWP，也就是说，发送端在窗口变成0后，会发ZWP的包给接收方，让接收方来ack他的Window尺寸，一般这个值会设置成3次，第次大约30-60秒（不同的实现可能会不一样）。如果3次过后还是0的话，有的TCP实现就会发RST把链接断了。

注意：只要有等待的地方都可能出现DDoS攻击，Zero Window也不例外，一些攻击者会在和HTTP建好链发完GET请求后，就把Window设置为0，然后服务端就只能等待进行ZWP，于是攻击者会并发大量的这样的请求，把服务器端的资源耗尽。（关于这方面的攻击，大家可以移步看一下[Wikipedia的SockStress词条](http://en.wikipedia.org/wiki/Sockstress)）

另外，Wireshark中，你可以使用tcp.analysis.zero_window来过滤包，然后使用右键菜单里的follow TCP stream，你可以看到ZeroWindowProbe及ZeroWindowProbeAck的包。

## 1.3 Silly Window Syndrome

Silly Window Syndrome翻译成中文就是“糊涂窗口综合症”。正如你上面看到的一样，如果我们的接收方太忙了，来不及取走Receive Windows里的数据，那么，就会导致发送方越来越小。到最后，如果接收方腾出几个字节并告诉发送方现在有几个字节的window，而我们的发送方会义无反顾地发送这几个字节。

要知道，我们的TCP+IP头有40个字节，为了几个字节，要达上这么大的开销，这太不经济了。

另外，你需要知道网络上有个MTU，对于以太网来说，MTU是1500字节，除去TCP+IP头的40个字节，真正的数据传输可以有1460，这就是所谓的MSS（Max Segment Size）注意，TCP的RFC定义这个MSS的默认值是536，这是因为 [RFC 791](http://tools.ietf.org/html/rfc791)里说了任何一个IP设备都得最少接收576尺寸的大小（实际上来说576是拨号的网络的MTU，而576减去IP头的20个字节就是536）。

如果你的网络包可以塞满MTU，那么你可以用满整个带宽，如果不能，那么你就会浪费带宽。（大于MTU的包有两种结局，一种是直接被丢了，另一种是会被重新分块打包发送） 你可以想像成一个MTU就相当于一个飞机的最多可以装的人，如果这飞机里满载的话，带宽最高，如果一个飞机只运一个人的话，无疑成本增加了，也而相当二。

所以，Silly Windows Syndrome这个现像就像是你本来可以坐200人的飞机里只做了一两个人。 要解决这个问题也不难，就是避免对小的window size做出响应，直到有足够大的window size再响应，这个思路可以同时实现在sender和receiver两端。

- 如果这个问题是由Receiver端引起的，那么就会使用 David D Clark’s 方案。在receiver端，如果收到的数据导致window size小于某个值，可以直接ack(0)回sender，这样就把window给关闭了，也阻止了sender再发数据过来，等到receiver端处理了一些数据后windows size 大于等于了MSS，或者，receiver buffer有一半为空，就可以把window打开让send 发送数据过来。

- 如果这个问题是由Sender端引起的，那么就会使用著名的 [Nagle’s algorithm](http://en.wikipedia.org/wiki/Nagle%27s_algorithm)。这个算法的思路也是延时处理，他有两个主要的条件：1）要等到 Window Size>=MSS 或是 Data Size >=MSS，2）收到之前发送数据的ack回包，他才会发数据，否则就是在攒数据。

另外，Nagle算法默认是打开的，所以，对于一些需要小包场景的程序——比如像telnet或ssh这样的交互性比较强的程序，你需要关闭这个算法。你可以在Socket设置TCP_NODELAY选项来关闭这个算法（关闭Nagle算法没有全局参数，需要根据每个应用自己的特点来关闭）

```
`setsockopt(sock_fd, IPPROTO_TCP, TCP_NODELAY, (``char``*)&value,``sizeof``(``int``));`
```

另外，网上有些文章说TCP_CORK的socket option是也关闭Nagle算法，这不对。TCP_CORK其实是更新激进的Nagle算汉，完全禁止小包发送，而Nagle算法没有禁止小包发送，只是禁止了大量的小包发送。最好不要两个选项都设置。

# Part 2 TCP拥塞控制

上面我们知道了，TCP通过Sliding Window来做流控（Flow Control），但是TCP觉得这还不够，因为Sliding Window需要依赖于连接的发送端和接收端，其并不知道网络中间发生了什么。TCP的设计者觉得，一个伟大而牛逼的协议仅仅做到流控并不够，因为流控只是网络模型4层以上的事，TCP的还应该更聪明地知道整个网络上的事。

具体一点，我们知道TCP通过一个timer采样了RTT并计算RTO，但是，如果网络上的延时突然增加，那么，TCP对这个事做出的应对只有重传数据，但是，重传会导致网络的负担更重，于是会导致更大的延迟以及更多的丢包，于是，这个情况就会进入恶性循环被不断地放大。试想一下，如果一个网络内有成千上万的TCP连接都这么行事，那么马上就会形成“网络风暴”，TCP这个协议就会拖垮整个网络。这是一个灾难。

所以，TCP不能忽略网络上发生的事情，而无脑地一个劲地重发数据，对网络造成更大的伤害。对此TCP的设计理念是：TCP不是一个自私的协议，当拥塞发生的时候，要做自我牺牲。就像交通阻塞一样，每个车都应该把路让出来，而不要再去抢路了。

关于拥塞控制的论文请参看《[Congestion Avoidance and Control](http://ee.lbl.gov/papers/congavoid.pdf)》(PDF)

拥塞控制主要是四个算法：1）慢启动，2）拥塞避免，3）拥塞发生，4）快速恢复。这四个算法不是一天都搞出来的，这个四算法的发展经历了很多时间，到今天都还在优化中。 备注:

- 1988年，TCP-Tahoe 提出了1）慢启动，2）拥塞避免，3）拥塞发生时的快速重传
- 1990年，TCP Reno 在Tahoe的基础上增加了4）快速恢复

## 2.1 慢启动算法

首先，我们来看一下TCP的慢启动（Slow Start）。慢启动的意思是，刚刚加入网络的连接，一点一点地提速，不要一上来就像那些特权车一样霸道地把路占满。新同学上高速还是要慢一点，不要把已经在高速上的秩序给搞乱了。

慢启动的算法如下(cwnd全称Congestion Window)：

1）连接建好的开始先初始化cwnd = 1，表明可以传一个MSS大小的数据。

2）每当收到一个ACK，cwnd++; 呈线性上升

3）每当过了一个RTT，cwnd = cwnd*2; 呈指数让升

4）还有一个ssthresh（slow start threshold），是一个上限，当cwnd >= ssthresh时，就会进入“拥塞避免算法”（后面会说这个算法）

所以，我们可以看到，如果网速很快的话，ACK也会返回得快，RTT也会短，那么，这个慢启动就一点也不慢。下图说明了这个过程。

![img](assets/tcp.slow_.start_.jpg)

这里，我需要提一下的是一篇Google的论文《[An Argument for Increasing TCP’s Initial Congestion Window](http://static.googleusercontent.com/media/research.google.com/zh-CN//pubs/archive/36640.pdf)》Linux 3.0后采用了这篇论文的建议——把cwnd 初始化成了 10个MSS。 而Linux 3.0以前，比如2.6，Linux采用了[RFC3390](http://www.rfc-editor.org/rfc/rfc3390.txt)，cwnd是跟MSS的值来变的，如果MSS< 1095，则cwnd = 4；如果MSS>2190，则cwnd=2；其它情况下，则是3。

## 2.2 拥塞避免算法

前面说过，还有一个ssthresh（slow start threshold），是一个上限，当cwnd >= ssthresh时，就会进入“拥塞避免算法（Congestion Avoidance）”。一般来说ssthresh的值是65535，单位是字节，当cwnd达到这个值时后，算法如下：

1）收到一个ACK时，cwnd = cwnd + 1/cwnd

2）当每过一个RTT时，cwnd = cwnd + 1

这样就可以避免增长过快导致网络拥塞，慢慢的增加调整到网络的最佳值。很明显，是一个线性上升的算法。

## 2.3 快速重传算法

### 2.3.1 RTO重传 vs 快速重传

拥塞状态时的算法主要指快速重传（Fast Retransmit），前面我们说过，当丢包的时候，会有两种情况：

1）等到RTO（Retransmit Timout）超时，重传数据包。TCP为每一个发送的数据包启动一个计时器，在计时器超时之前收到了这个数据包的ACK则撤销计时器，否则重传这个数据包。TCP认为这种情况太糟糕，反应也很强烈，因为必须要等到计时器超时。

- sshthresh =  cwnd /2；
- cwnd 重置为 1；
- 进入慢启动过程；

2）Fast Retransmit算法，也就是在收到3个duplicate ACK时就开启重传，而不用等到1）中描述的RTO超时。什么时候会发送3个冗余的ACK呢，比如发送方向接收方发送数据的时候出现了分组丢失的情况，接收方收到了乱序的数据，此时

- TCP Tahoe的实现和RTO超时一样；

- TCP Reno的实现是：
  - cwnd = cwnd /2；
  - sshthresh = cwnd；
  - 进入快速恢复算法（Fast Recovery）；

上面我们可以看到RTO超时后，sshthresh会变成cwnd的一半，这意味着，如果cwnd<=sshthresh时出现的丢包，那么TCP的sshthresh就会减了一半，然后等cwnd又很快地以指数级增涨爬到这个地方时，就会成慢慢的线性增涨。我们可以看到，TCP是怎么通过这种强烈地震荡快速而小心得找到网站流量的平衡点的。

### 2.3.2 为什么是三次冗余ACK

快速重传为什么选择3次冗余ACK?主要的考虑还是要区分包的丢失是由于**链路故障**还是**乱序**等其他因素引发。

两次duplicated ACK时很可能是乱序造成的！三次duplicated ACK时很可能是丢包造成的！四次duplicated ACK更更更可能是丢包造成的！但是这样的响应策略太慢。丢包肯定会造成三次duplicated ACK！综上是选择收到三个重复确认时窗口减半效果最好，这是实践经验。

在没有fast retransmit / recovery 算法之前，重传依靠发送方的retransmit timeout，就是在timeout内如果没有接收到对方的ACK，默认包丢了，发送方就重传，但是包的丢失原因有多种：

- 包checksum出错
- 网络拥塞
- 网络断，包括路由重收敛

发送方在RTO超时的时候，是无法判断到底是哪一种情况引起的。于是采用最笨的办法，就是将自己的发送速率减半，即CWND 减为1/2，这样的方法对场景“网络拥塞”是有效的，可以缓解网络拥塞。对“网络断”这种场景则无所谓了，反正网络断了，无论发快发慢都会被丢。但对于场景“校验和出错”来说，丢包是因为偶尔的出错引起，一丢包就对半减速不合理。

于是有了fast retransmit 算法，基于在反向还可以接收到冗余ACK，可以认为网络并没有断，否则也接收不到ACK，如果在timeout 时间内没有接收到大于2个的duplicated ACK，则概率大事件为乱序，乱序无需重传，接收方会进行排序工作；而如果接收到三个或三个以上的duplicated ACK，则大概率是丢包，可以逻辑推理，发送方可以接收ACK，则网络是通的，可能是1、2造成的，先不降速，重传一次，如果接收到正确的ACK，则一切OK，流速依然（包出错被丢）。而如果依然接收到duplicated ACK，则认为是网络拥塞造成的，此时降速则比较合理。

### 2.3.3 细说重传机制

TCP要保证所有的数据包都可以到达，必需要有重传机制。

注意，接收端给发送端的Ack确认只会确认最后一个连续的包，比如，发送端发了1,2,3,4,5一共五份数据，接收端收到了1，2，于是回ack 3，然后收到了4（注意此时3没收到），此时的TCP会怎么办？我们要知道，因为正如前面所说的，**SeqNum和Ack是以字节数为单位，所以ack的时候，不能跳着确认，只能确认最大的连续收到的包**，不然，发送端就以为之前的都收到了。

#### 2.3.3.1 超时重传机制

一种是不回ack，死等3，当发送方发现收不到3的ack超时后，会重传3。一旦接收方收到3后，会ack 回 4——意味着3和4都收到了。

但是，这种方式会有比较严重的问题，那就是因为要死等3，所以会导致4和5即便已经收到了，而发送方也完全不知道发生了什么事，因为没有收到Ack，所以，发送方可能会悲观地认为也丢了，所以有可能也会导致4和5的重传。

对此有两种选择：

- 一种是仅重传timeout的包。也就是第3份数据。
- 另一种是重传timeout后所有的数据，也就是第3，4，5这三份数据(此时会接收到一个丢弃一个?直到超时)。

这两种方式有好也有不好。第一种会节省带宽，但是慢(原因是直到超时，重传3，同时需要在服务端重组报文顺序?)，第二种会快一点，但是会浪费带宽，也可能会有无用功。但总体来说都不好。因为都在等timeout，timeout可能会很长（在下篇会说TCP是怎么动态地计算出timeout的）

#### 2.3.3.2 快速重传机制

于是，TCP引入了一种叫**Fast Retransmit** 的算法，**不以时间驱动，而以数据驱动重传**。也就是说，如果，包没有连续到达，就ack最后那个可能被丢了的包，如果发送方连续收到3次相同的ack，就重传。Fast Retransmit的好处是不用等timeout了再重传。

比如：如果发送方发出了1，2，3，4，5份数据，第一份先到送了，于是就ack回2，结果2因为某些原因没收到，3到达了，于是还是ack回2，后面的4和5都到了，但是还是ack回2，因为2还是没有收到，于是发送端收到了三个ack=2的确认，知道了2还没有到，于是就马上重转2。然后，接收端收到了2，此时因为3，4，5都收到了，于是ack回6。示意图如下：

![img](assets/FASTIncast021.png)

Fast Retransmit只解决了一个问题，就是timeout的问题，它依然面临一个艰难的选择，就是，是重传之前的一个还是重传所有的问题。对于上面的示例来说，是重传#2呢还是重传#2，#3，#4，#5呢？因为发送端并不清楚这连续的3个ack(2)是谁传回来的？也许发送端发了20份数据，是#6，#10，#20传来的呢。这样，发送端很有可能要重传从2到20的这堆数据（这就是某些TCP的实际的实现）。可见，这是一把双刃剑。

##### 2.3.3.2.1 SACK 方法

另外一种更好的方式叫：**Selective Acknowledgment (SACK，选择确认)**（参看[RFC 2018](http://tools.ietf.org/html/rfc2018)），这种方式需要在TCP头里加一个SACK的东西，ACK还是Fast Retransmit的ACK，SACK则是汇报收到的数据碎版。参看下图：

![img](assets/tcp_sack_example-1024x577.jpg)

这样，在发送端就可以根据回传的SACK来知道哪些数据到了，哪些没有到。于是就优化了Fast Retransmit的算法。当然，这个协议需要两边都支持。在 Linux下，可以通过**tcp_sack**参数打开这个功能（Linux 2.4后默认打开）。

这里还需要注意一个问题——**接收方Reneging，所谓Reneging的意思就是接收方有权把已经报给发送端SACK里的数据给丢了**。这样干是不被鼓励的，因为这个事会把问题复杂化了，但是，接收方这么做可能会有些极端情况，比如要把内存给别的更重要的东西。**所以，发送方也不能完全依赖SACK，还是要依赖ACK，并维护Time-Out，如果后续的ACK没有增长，那么还是要把SACK的东西重传，另外，接收端这边永远不能把SACK的包标记为Ack。**

注意：SACK会消费发送方的资源，试想，如果一个攻击者给数据发送方发一堆SACK的选项，这会导致发送方开始要重传甚至遍历已经发出的数据，这会消耗很多发送端的资源。详细的东西请参看《[TCP SACK的性能权衡](http://www.ibm.com/developerworks/cn/linux/l-tcp-sack/)》

##### 2.3.3.2.2 Duplicate SACK

Duplicate SACK又称D-SACK，**其主要使用了SACK来告诉发送方有哪些数据被重复接收了**。[RFC-2883 ](http://www.ietf.org/rfc/rfc2883.txt)里有详细描述和示例。下面举几个例子（来源于[RFC-2883](http://www.ietf.org/rfc/rfc2883.txt)）

D-SACK使用了SACK的第一个段来做标志，下面是D-SACK的处理流程：

- 如果SACK的第一个段的范围被ACK所覆盖，则是D-SACK，用于报告冗余数据；
- 如果SACK的第一个段的范围被SACK的第二个段覆盖，那也是D-SACK，SACK的第一个端用于报告冗余数据；
- 其他情况，当做正常的SACK（选择确认）进行处理。

**示例一：报告ACK丢包**

下面的示例中，丢了两个ACK，所以，发送端重传了第一个数据包（3000-3499），于是接收端发现重复收到，于是回了一个SACK=3000-3500，因为ACK都到了4000意味着收到了4000之前的所有数据，所以这个SACK就是D-SACK——旨在告诉发送端我收到了重复的数据，而且我们的发送端还知道，数据包没有丢，丢的是ACK包。

```bash
Transmitted  Received    ACK Sent
Segment      Segment     (Including SACK Blocks)
3000-3499    3000-3499   3500 (ACK dropped)
3500-3999    3500-3999   4000 (ACK dropped)
3000-3499    3000-3499   4000, SACK=3000-3500
```

**示例二：报告网络延误**

下面的示例中，网络包（1000-1499）被网络给延误了，导致发送方没有收到ACK，而后面到达的三个包触发了“Fast Retransmit算法”，所以重传，但重传时，被延误的包又到了，所以，回了一个SACK=1000-1500，因为ACK已到了3000，所以，这个SACK是D-SACK——标识收到了重复的包。

这个案例下，发送端知道之前因为“Fast Retransmit算法”触发的重传不是因为发出去的包丢了，也不是因为回应的ACK包丢了，而是因为网络延时了。

```bash
Transmitted    Received    ACK Sent
Segment        Segment     (Including SACK Blocks)
500-999        500-999     1000
1000-1499      (delayed)
1500-1999      1500-1999   1000, SACK=1500-2000
2000-2499      2000-2499   1000, SACK=1500-2500
2500-2999      2500-2999   1000, SACK=1500-3000
1000-1499      1000-1499   3000
               1000-1499   3000, SACK=1000-1500
```

可见，引入了D-SACK，有这么几个好处：

- 可以让发送方知道，是发出去的包丢了，还是回来的ACK包丢了。

- 是不是自己的timeout太小了，导致重传。

- 网络上出现了先发的包后到的情况（又称reordering）

- 网络上是不是把我的数据包给复制了。

 **知道这些东西可以很好得帮助TCP了解网络情况，从而可以更好的做网络上的流控**。Linux下的tcp_dsack参数用于开启这个功能（Linux 2.4后默认打开）。

## 2.4 快速恢复算法

### 2.4.1 TCP Reno

这个算法定义在[RFC5681](http://tools.ietf.org/html/rfc5681)。快速重传和快速恢复算法（Fast Recovery）一般同时使用。快速恢复算法是认为，你还有3个Duplicated Acks说明网络也不那么糟糕，所以没有必要像RTO超时那么强烈。 注意，正如前面所说，进入Fast Recovery之前，cwnd 和 sshthresh已被更新：

- cwnd = cwnd /2
- sshthresh = cwnd

然后，真正的Fast Recovery算法如下：

- cwnd = sshthresh  + 3 * MSS （3的意思是确认有3个数据包被收到了）
- 重传Duplicated ACKs指定的数据包
- 如果再收到 duplicated Acks，那么cwnd = cwnd +1
- 如果收到了新的Ack，那么，cwnd = sshthresh ，然后就进入了拥塞避免的算法了。

如果你仔细思考一下上面的这个算法，你就会知道，上面这个算法也有问题，那就是——它依赖于3个重复的Acks。注意，3个重复的Acks并不代表只丢了一个数据包，很有可能是丢了好多包。但这个算法只会重传一个，而剩下的那些包只能等到RTO超时，于是，进入了恶梦模式——超时一个窗口就减半一下，多个超时会超成TCP的传输速度呈级数下降，而且也不会触发Fast Recovery算法了。

通常来说，正如我们前面所说的，SACK或D-SACK的方法可以让Fast Recovery或Sender在做决定时更聪明一些，但是并不是所有的TCP的实现都支持SACK（SACK需要两端都支持），所以，需要一个没有SACK的解决方案。而通过SACK进行拥塞控制的算法是FACK（后面会讲）

### 2.4.2 TCP New Reno

于是，1995年，TCP New Reno（参见 [RFC 6582](http://tools.ietf.org/html/rfc6582) ）算法提出来，主要就是在没有SACK的支持下改进Fast Recovery算法的。

- 当sender这边收到了3个Duplicated Acks，进入Fast Retransimit模式，开始重传重复Acks指示的那个包。如果只有这一个包丢了，那么，重传这个包后回来的Ack会把整个已经被sender传输出去的数据ack回来。如果没有的话，说明有多个包丢了。我们叫这个ACK为Partial ACK。

- 一旦Sender这边发现了Partial ACK出现，那么，sender就可以推理出来有多个包被丢了，于是乎继续重传sliding window里未被ack的第一个包。直到再也收不到了Partial Ack，才真正结束Fast Recovery这个过程。

我们可以看到，这个“Fast Recovery的变更”是一个非常激进的玩法，他同时延长了Fast Retransmit和Fast Recovery的过程。

下面我们来看一个简单的图示以同时看一下上面的各种算法的样子：

![img](assets/tcp.fr_-1024x359.jpg)

### 2.4.3 FACK

FACK全称Forward Acknowledgment 算法，论文地址在这里（PDF）[Forward Acknowledgement: Refining TCP Congestion Control](http://conferences.sigcomm.org/sigcomm/1996/papers/mathis.pdf) 这个算法是其于SACK的，前面我们说过SACK是使用了TCP扩展字段Ack了有哪些数据收到，哪些数据没有收到，他比Fast Retransmit的3 个duplicated acks好处在于，前者只知道有包丢了，不知道是一个还是多个，而SACK可以准确的知道有哪些包丢了。 所以，SACK可以让发送端这边在重传过程中，把那些丢掉的包重传，而不是一个一个的传，但这样的一来，如果重传的包数据比较多的话，又会导致本来就很忙的网络就更忙了。所以，FACK用来做重传过程中的拥塞流控。

- 这个算法会把SACK中最大的Sequence Number 保存在snd.fack这个变量中，snd.fack的更新由ack带秋，如果网络一切安好则和snd.una一样（snd.una就是还没有收到ack的地方，也就是前面sliding window里的category #2的第一个地方）

- 然后定义一个awnd = snd.nxt – snd.fack（snd.nxt指向发送端sliding window中正在要被发送的地方——前面sliding windows图示的category#3第一个位置），这样awnd的意思就是在网络上的数据。（所谓awnd意为：actual quantity of data outstanding in the network）

- 如果需要重传数据，那么，awnd = snd.nxt – snd.fack + retran_data，也就是说，awnd是传出去的数据 + 重传的数据。

- 然后触发Fast Recovery 的条件是： ( ( snd.fack – snd.una ) > (3*MSS) ) || (dupacks == 3) ) 。这样一来，就不需要等到3个duplicated acks才重传，而是只要sack中的最大的一个数据和ack的数据比较长了（3个MSS），那就触发重传。在整个重传过程中cwnd不变。直到当第一次丢包的snd.nxt<=snd.una（也就是重传的数据都被确认了），然后进来拥塞避免机制——cwnd线性上涨。

我们可以看到如果没有FACK在，那么在丢包比较多的情况下，原来保守的算法会低估了需要使用的window的大小，而需要几个RTT的时间才会完成恢复，而FACK会比较激进地来干这事。 但是，FACK如果在一个网络包会被 reordering的网络里会有很大的问题。

## 2.5 其它拥塞控制算法

### 2.5.1 TCP Vegas 拥塞控制算法

这个算法1994年被提出，它主要对TCP Reno 做了些修改。这个算法通过对RTT的非常重的监控来计算一个基准RTT。然后通过这个基准RTT来估计当前的网络实际带宽，如果实际带宽比我们的期望的带宽要小或是要多的活，那么就开始线性地减少或增加cwnd的大小。如果这个计算出来的RTT大于了Timeout后，那么，不等ack超时就直接重传。（Vegas 的核心思想是用RTT的值来影响拥塞窗口，而不是通过丢包） 这个算法的论文是《[TCP Vegas: End to End Congestion Avoidance on a Global Internet](http://www.cs.cmu.edu/~srini/15-744/F02/readings/BP95.pdf)》这篇论文给了Vegas和 New Reno的对比：

![img](assets/tcp_vegas_newreno-1024x555.jpg)

关于这个算法实现，你可以参看Linux源码：[/net/ipv4/tcp_vegas.h](http://lxr.free-electrons.com/source/net/ipv4/tcp_vegas.h)， [/net/ipv4/tcp_vegas.c](http://lxr.free-electrons.com/source/net/ipv4/tcp_vegas.c)

##### 

### 2.5.2 HSTCP(High Speed TCP) 算法

这个算法来自[RFC 3649](http://tools.ietf.org/html/rfc3649)（[Wikipedia词条](http://en.wikipedia.org/wiki/HSTCP)）。其对最基础的算法进行了更改，他使得Congestion Window涨得快，减得慢。其中：

- 拥塞避免时的窗口增长方式： cwnd = cwnd + α(cwnd) / cwnd
- 丢包后窗口下降方式：cwnd = (1- β(cwnd))*cwnd

注：α(cwnd)和β(cwnd)都是函数，如果你要让他们和标准的TCP一样，那么让α(cwnd)=1，β(cwnd)=0.5就可以了。 对于α(cwnd)和β(cwnd)的值是个动态的变换的东西。 关于这个算法的实现，你可以参看Linux源码：[/net/ipv4/tcp_highspeed.c](http://lxr.free-electrons.com/source/net/ipv4/tcp_highspeed.c)

### 2.5.3  TCP BIC 算法

2004年，产内出BIC算法。现在你还可以查得到相关的新闻《Google：[美科学家研发BIC-TCP协议 速度是DSL六千倍](https://www.google.com/search?lr=lang_zh-CN%7Clang_zh-TW&newwindow=1&biw=1366&bih=597&tbs=lr%3Alang_1zh-CN%7Clang_1zh-TW&q=%E7%BE%8E%E7%A7%91%E5%AD%A6%E5%AE%B6%E7%A0%94%E5%8F%91BIC-TCP%E5%8D%8F%E8%AE%AE+%E9%80%9F%E5%BA%A6%E6%98%AFDSL%E5%85%AD%E5%8D%83%E5%80%8D&oq=%E7%BE%8E%E7%A7%91%E5%AD%A6%E5%AE%B6%E7%A0%94%E5%8F%91BIC-TCP%E5%8D%8F%E8%AE%AE+%E9%80%9F%E5%BA%A6%E6%98%AFDSL%E5%85%AD%E5%8D%83%E5%80%8D)》 BIC全称[Binary Increase Congestion control](http://research.csc.ncsu.edu/netsrv/?q=content/bic-and-cubic)，在Linux 2.6.8中是默认拥塞控制算法。BIC的发明者发这么多的拥塞控制算法都在努力找一个合适的cwnd – Congestion Window，而且BIC-TCP的提出者们看穿了事情的本质，其实这就是一个搜索的过程，所以BIC这个算法主要用的是Binary Search——二分查找来干这个事。 关于这个算法实现，你可以参看Linux源码：[/net/ipv4/tcp_bic.c](http://lxr.free-electrons.com/source/net/ipv4/tcp_bic.c)

### 2.5.4 TCP WestWood算法

westwood采用和Reno相同的慢启动算法、拥塞避免算法。westwood的主要改进方面：在发送端做带宽估计，当探测到丢包时，根据带宽值来设置拥塞窗口、慢启动阈值。 那么，这个算法是怎么测量带宽的？每个RTT时间，会测量一次带宽，测量带宽的公式很简单，就是这段RTT内成功被ack了多少字节。因为，这个带宽和用RTT计算RTO一样，也是需要从每个样本来平滑到一个值的——也是用一个加权移平均的公式。 另外，我们知道，如果一个网络的带宽是每秒可以发送X个字节，而RTT是一个数据发出去后确认需要的时候，所以，X * RTT应该是我们缓冲区大小。所以，在这个算法中，ssthresh的值就是est_BD * min-RTT(最小的RTT值)，如果丢包是Duplicated ACKs引起的，那么如果cwnd > ssthresh，则 cwin = ssthresh。如果是RTO引起的，cwnd = 1，进入慢启动。   关于这个算法实现，你可以参看Linux源码： [/net/ipv4/tcp_westwood.c](http://lxr.free-electrons.com/source/net/ipv4/tcp_westwood.c)

### 2.5.5 其它

更多的算法，你可以从Wikipedia的 [TCP Congestion Avoidance Algorithm](http://en.wikipedia.org/wiki/TCP_congestion-avoidance_algorithm) 词条中找到相关的线索。