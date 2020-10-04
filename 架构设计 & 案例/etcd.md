# Etcd架构设计

## Etcd是什么？

Etcd是一个分布式、强一致的KV存储系统，它提供了一种可靠访问存储数据的解决方案，对于节点失效（包括leader节点的失效）也提供了可靠的处理方法。从简单如一个WebApp到复杂如Kubernetes的应用，都可以非常便捷地从Etcd读写数据。Etcd基于golang开发，目前在github托管，详见 [etcd-io/etcd](https://github.com/etcd-io/etcd)，由CNCF（云原生计算基金会）支持。

Etcd节点之间的通信采用Raft一致性算法，到etcd leader节点之间的访问延迟（latency）是一项非常关键的监控指标，etcd也提供了内置的看板来观察监控相关指标。访问延迟严重的话会影响到集群整体的稳定性，因为Raft一致性算法的特点，基本上可以认为访问延迟由集群中延迟最大的节点决定，当然我们可以进行调优。云提供商一般都针对不可靠的网络环境进行了适当的调优。

## Etcd使用案例



## Etcd架构设计

## Etcd详细实现

