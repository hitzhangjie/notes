
这里描述了死锁的案例：
1）两个线程申请同样的锁，但是**加锁顺序相反**，引发死锁；
2）多个线程申请的锁不同，但是他们**加锁的顺序构成了环形依赖**，引发死锁；
3）数据库事务中出现死锁；

**Thread Deadlock**
A deadlock is when two or more threads are blocked waiting to obtain locks that some of the other threads in the deadlock are holding. **Deadlock can occur when multiple threads need the same locks, at the same time, but obtain them in different order.**
For instance, if thread 1 locks A, and tries to lock B, and thread 2 has already locked B, and tries to lock A, a deadlock arises. Thread 1 can never get B, and thread 2 can never get A. In addition, neither of them will ever know. They will remain blocked on each their object, A and B, forever. This situation is a deadlock.
The situation is illustrated below:

```bash
Thread 1  locks A, waits for B
Thread 2  locks B, waits for A
```

**More Complicated Deadlocks**
Deadlock can also include more than two threads. This makes it harder to detect. Here is an example in which four threads have deadlocked:

```bash
Thread 1  locks A, waits for B
Thread 2  locks B, waits for C
Thread 3  locks C, waits for D
Thread 4  locks D, waits for A
```

**Database Deadlocks**
A more complicated situation in which deadlocks can occur, is a database transaction. A database transaction may consist of many SQL update requests. When a record is updated during a transaction, that record is locked for updates from other transactions, until the first transaction completes. Each update request within the same transaction may therefore lock some records in the database.
If multiple transactions are running at the same time that need to update the same records, there is a risk of them ending up in a deadlock.
For example
```bash
Transaction 1, request 1, locks record 1 for update
Transaction 2, request 1, locks record 2 for update
Transaction 1, request 2, tries to lock record 2 for update.
Transaction 2, request 2, tries to lock record 1 for update.
```
**Since the locks are taken in different requests, and not all locks needed for a given transaction are known ahead of time, it is hard to detect or prevent deadlocks in database transactions.**