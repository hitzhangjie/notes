cache一致性实现机制，主要包括基于snooping和基于directory两种机制，一致性机制解决的是如何观测cpu read/write操作事件，两种各有优缺点：

- snooping，在cpu数量、core数量比较少的情况下，snooping可以减少req/rsp的数量，是基于广播的，效率比较高，但是在cpu、core数量比较多的情况下难以水平扩展，为了满足广播需要增加依赖的总线带宽；
- directory，在cpu数量、core数量比较多的情况下，更加适用，可以平行扩展cpu、core数量，不需要增加总线带宽，但是由于是计算cpu或者core之间的点对点请求，没有广播，req/rsp次数会比较多，会增加一定的延时；

cache一致性算法，主要包括write-through（写直达）或者write-back（写回），write-back并不是当cache中数据更新时立即写回，而是在稍后的某个时机再写回。写直达会严重降低cpu吞吐量，所以现如今的主流处理器中通常采用write-back算法。

- write-through
- write-back
  - write-invalidate，当某个core（如core 1）的cache被修改为最新数据后，总线观测到更新，将写事件同步到其他core（如core n），将其他core对应相同内存地址的cache entry标记为invalidate，后续core n继续读取相同内存地址数据时，发现已经invalidate，会再次请求内存中最新数据。
  - write-update，当某个core（如core 1）的cache被修改为最新数据后，将写事件同步到其他core，此时其他core（如core n）立即读取最新数据（如更新为core 1中数据）。

## Coherence mechanisms[[edit](https://en.wikipedia.org/w/index.php?title=Cache_coherence&action=edit&section=3)]

The two most common mechanisms of ensuring coherency are *snooping* and *directory-based*, each having their own benefits and drawbacks. Snooping based protocols tend to be faster, if enough [bandwidth](https://en.wikipedia.org/wiki/Memory_bandwidth) is available, since all transactions are a request/response seen by all processors. The drawback is that snooping isn't scalable. Every request must be broadcast to all nodes in a system, meaning that as the system gets larger, the size of the (logical or physical) bus and the bandwidth it provides must grow. Directories, on the other hand, tend to have longer latencies (with a 3 hop request/forward/respond) but use much less bandwidth since messages are point to point and not broadcast. For this reason, many of the larger systems (>64 processors) use this type of cache coherence.

### [Snooping](https://en.wikipedia.org/wiki/Bus_sniffing)[[edit](https://en.wikipedia.org/w/index.php?title=Cache_coherence&action=edit&section=4)]



### Directory-based[[edit](https://en.wikipedia.org/w/index.php?title=Cache_coherence&action=edit&section=5)]

Main article: [Directory-based cache coherence](https://en.wikipedia.org/wiki/Directory-based_cache_coherence)

[Distributed shared memory](https://en.wikipedia.org/wiki/Distributed_shared_memory) systems mimic these mechanisms in an attempt to maintain consistency between blocks of memory in loosely coupled systems.[[9\]](https://en.wikipedia.org/wiki/Cache_coherence#cite_note-9)

## Coherence protocols[[edit](https://en.wikipedia.org/w/index.php?title=Cache_coherence&action=edit&section=6)]

Coherence protocols apply cache coherence in multiprocessor systems. The intention is that two clients must never see different values for the same shared data.

The protocol must implement the basic requirements for coherence. It can be tailor-made for the target system or application.

Protocols can also be classified as snoopy or directory-based. Typically, early systems used directory-based protocols where a directory would keep a track of the data being shared and the sharers. In snoopy protocols, the transaction requests (to read, write, or upgrade) are sent out to all processors. All processors snoop the request and respond appropriately.

Write propagation in snoopy protocols can be implemented by either of the following methods:

- Write-invalidate

  When a write operation is observed to a location that a cache has a copy of, the cache controller invalidates its own copy of the snooped memory location, which forces a read from main memory of the new value on its next access.[[4\]](https://en.wikipedia.org/wiki/Cache_coherence#cite_note-:3-4)

- Write-update

  When a write operation is observed to a location that a cache has a copy of, the cache controller updates its own copy of the snooped memory location with the new data.

If the protocol design states that whenever any copy of the shared data is changed, all the other copies must be "updated" to reflect the change, then it is a write-update protocol. If the design states that a write to a cached copy by any processor requires other processors to discard or invalidate their cached copies, then it is a write-invalidate protocol.

However, scalability is one shortcoming of broadcast protocols.

Various models and protocols have been devised for maintaining coherence, such as [MSI](https://en.wikipedia.org/wiki/MSI_protocol), [MESI](https://en.wikipedia.org/wiki/MESI_protocol) (aka Illinois), [MOSI](https://en.wikipedia.org/wiki/MOSI_protocol), [MOESI](https://en.wikipedia.org/wiki/MOESI_protocol), [MERSI](https://en.wikipedia.org/wiki/MERSI_protocol), [MESIF](https://en.wikipedia.org/wiki/MESIF_protocol), [write-once](https://en.wikipedia.org/wiki/Write-once_(cache_coherence)), Synapse, Berkeley, [Firefly](https://en.wikipedia.org/wiki/Firefly_(cache_coherence_protocol)) and [Dragon protocol](https://en.wikipedia.org/wiki/Dragon_protocol).[[1\]](https://en.wikipedia.org/wiki/Cache_coherence#cite_note-:1-1) In 2011, [ARM Ltd](https://en.wikipedia.org/wiki/ARM_Ltd) proposed the AMBA 4 ACE[[10\]](https://en.wikipedia.org/wiki/Cache_coherence#cite_note-10) for handling coherency in [SoC](https://en.wikipedia.org/wiki/System_on_a_chip)s.