这里收集、整理了常见的一些数据结构实现，方便学习、使用。

# 跳表

开源实现：https://github.com/hitzhangjie/goskiplist

“**二叉查找树->二叉平衡树->红黑树**”，二叉树查找树及其变体以平均O(log(n))的时间复杂度、O(n)的空间复杂度站稳了脚跟，成为“查找”操作所优先考虑的数据结构，为了保证查询效率，插入、删除节点必须要对树结构进行调整，以满足树结构的约束。当节点数量比较多的时候，调整树结构的代价就变得很明显。

Wikipedia有关于 [“跳表”](https://en.wikipedia.org/wiki/Skip_list) 的设计思想、实现相关的说明：
![skiplist](https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Skip_list.svg/800px-Skip_list.svg.png)

![skiplist](https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Skip_list_add_element-en.gif/800px-Skip_list_add_element-en.gif)

简而言之，跳表本质上是对“**有序链表**”的优化，其结合了二叉查找树的某些特性（小的在左子树查，大的在右子树查），也增加了类似的索引节点，即除了存储数据元素本身的链表外，还需要为链表中的某些元素在不同的层级构建索引链表。假如有个索引节点是A，其同层右侧节点为B，假如待查询的值val大于A小于B，则进入索引节点A在更下层的索引链表中查找，直到找到待查询元素或者无元素可查。
