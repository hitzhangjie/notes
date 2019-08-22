- **对map、sync.Map、[concurrent_map](https://github.com/orcaman/concurrent-map)进行了benchmark，结果如下：**

- ```bash
  BenchmarkDeleteEmptyMap-8               20000000                86.9 ns/op
  BenchmarkDeleteEmptySyncMap-8           300000000                5.16 ns/op
  BenchmarkDeleteEmptyCMap-8              50000000                34.8 ns/op
  
  BenchmarkDeleteMap-8                    10000000               131 ns/op
  BenchmarkDeleteSyncMap-8                10000000               135 ns/op
  BenchmarkDeleteCMap-8                   30000000                37.0 ns/op
  
  BenchmarkLoadEmptyMap-8                 20000000                87.9 ns/op
  BenchmarkLoadEmptySyncMap-8             300000000                5.03 ns/op
  BenchmarkLoadEmptyCMap-8                100000000               17.1 ns/op
  
  BenchmarkLoadMap-8                      20000000               111 ns/op
  BenchmarkLoadSyncMap-8                  100000000               12.8 ns/op
  BenchmarkLoadCMap-8                     100000000               22.5 ns/op
  
  BenchmarkSetMap-8                       10000000               187 ns/op
  BenchmarkSetSyncMap-8                    5000000               396 ns/op
  BenchmarkSetCMap-8                      20000000                84.9 ns/op
  ```

- 

- **benchmark结果表明：**

- - map+rwmutex这种方式，锁粒度比加大，增删该查操作耗时相对来说都是比较明显的

  - sync.Map这种方式，写少读多的情况是非常合适的，效率比较明显，优于map、concurrent_map

  - concurrent_map，考虑了并发写比较频繁的情况，特别是删除，多shard执行删除操作时效率非常明显

    

- **使用场景：**

- - 连接池明显属于读多写少的场景，建议用sync.Map代替，
  - transport如果要实现双工模式的时候，需要维护req.seqno\rsp.seqno的映射关系，增删频繁，可以考虑用concurrent_map。

- 

- 

- 

- 