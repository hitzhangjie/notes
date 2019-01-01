**1.常用数据类型**

```c
pthread_mutex_t
pthread_cond_t
```

**2.信号**

- 进程之间可以互相发送信号，通过kill函数；
- 线程之间也可以互相发送信号，通过pthread_kill函数。

**3.使用mutex、cond实现线程同步（这两个结合起来，其实就相当于信号量）**

加入pthread_cond_wait(&cond, &mutex)将当前线程放置到cond对应的等待队列上之后，假如后面有个线程调用pthread_cond_signal将该线程唤醒了，那么线程被唤醒的时候，将重新获得锁mutex，获得了该锁之后继续从pthread_cond_wait之后的语句执行。

```c
#include <stdio.h>
#include <pthread.h>
#include <unistd.h> 

static int a = 1;
static pthread_mutex_t mutex;
static pthread_cond_t cond;

void *func_inc(void * arg) {
	while(1) {
		pthread_mutex_lock(&mutex);
		printf("threadid:%d\t in inc thread\n", pthread_self());
		printf("xxxxxxxxxxxxxx\n");
		
		while(a!=0) {   
			printf("threadid:%d\t a!=0,waiting\n", pthread_self());
			pthread_cond_wait(&cond, &mutex);
			// 线程被唤醒之后，获得锁的过程是在pthread线程库中完成的
			// 成功获得锁之后，将从这里继续执行
			// 注意，唤醒后重新获得锁的过程是在pthread线程库代码中完成的，
			// 而不是重新从上面的pthread_mutex_lock(&mutex)处获得锁！！！
			printf("threadid:%d\t a==0,wakup\n", pthread_self());
		}
		a++;
		pthread_cond_signal(&cond);
		pthread_mutex_unlock(&mutex);
	}
	return NULL;
}

void *func_dec(void * arg) {
	while(1) {
		pthread_mutex_lock(&mutex);
		printf("threadid:%d\t in dec thread\n", pthread_self());
		while(a!=1) {
			printf("threadid:%d\t a!=1,waiting\n", pthread_self());
			pthread_cond_wait(&cond, &mutex);
			printf("threadid:%d\t a==1,wakup\n", pthread_self());
		}
		a--;
		pthread_cond_signal(&cond);
		pthread_mutex_unlock(&mutex);
	}
	return NULL;
}

int main(int argc, char *argv[]) {
	pthread_t tids[2];
	pthread_mutex_init(&mutex, NULL);
	pthread_cond_init(&cond, NULL);
	pthread_create(&tids[0], NULL, func_inc, NULL);
	sleep(1);
	pthread_create(&tids[1], NULL, func_dec, NULL);
	pthread_join(tids[0], NULL);
	pthread_join(tids[1], NULL);
	pthread_cond_destroy(&cond);
	pthread_mutex_destroy(&mutex);
	return 0;
} 
```