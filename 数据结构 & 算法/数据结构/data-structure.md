这里收集、整理了常见的一些数据结构实现，方便学习、使用。

# 跳表（skiplist）

开源实现：https://github.com/hitzhangjie/goskiplist

“**二叉查找树->二叉平衡树->红黑树**”，二叉树查找树及其变体以平均O(log(n))的时间复杂度、O(n)的空间复杂度站稳了脚跟，成为“查找”操作所优先考虑的数据结构，为了保证查询效率，插入、删除节点必须要对树结构进行调整，以满足树结构的约束。当节点数量比较多的时候，调整树结构的代价就变得很明显。

Wikipedia有关于 [“跳表”](https://en.wikipedia.org/wiki/Skip_list) 的设计思想、实现相关的说明：
![skiplist](https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Skip_list.svg/800px-Skip_list.svg.png)

![skiplist](https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Skip_list_add_element-en.gif/800px-Skip_list_add_element-en.gif)

简而言之，**跳表本质上是对“有序链表”的优化，其“结合了二叉查找树的特性”，也增加了类似的索引节点来加速查询**。即除了存储数据元素本身的链表外，还需要为链表中的某些元素在不同的层级构建索引链表。假如有个索引节点是A，其同层右侧节点为B，假如待查询的值val大于A小于B，则进入索引节点A在更下层的索引链表中查找，直到找到待查询元素或者无元素可查。

跳表的查询、插入、删除、更新操作的时间复杂度为O(log(n))，空间复杂度不超过2*n，记为O(n)。相比于平衡树、红黑树这两种数据结构，当存储的数据量比较大的时候，或者存储的键值比较比较耗时（长字符串）的时候，跳表就比较有优势，可以显著减少因为树调整操作引入的开销。

关于跳表时间复杂度、空间复杂度的证明也比较简单。跳表中第一层元素数量n，第二层索引节点数量n/2，更上层依次折半，可以推算出总的节点数量不超过2*n，因此空间复杂度为O(n)；树的高度因此也可以确定下来为O(log(n))，所以操作的时间复杂度为O(log(n))。
