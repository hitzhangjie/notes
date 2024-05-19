pthread_t

header	:	<pthread.h>
gcc		:	-lpthread				// use shared library libpthread.so

pthread_t pthread_self();			// get current thread id
pthread_cancel();
pthread_exit();

pthread_join();
pthread_detach();

int pthread_create(.., .., .., ..);

note:
	when main thread ends,all child threads created by it will be forcefully killed.
	so,if we want child threads end normally,a good method is let the main thread sleep one or more seconds so that the child threads have enough time to finish their work.

inner-thread mutex:
pthread_mutex_t
1)create mutex
 method 1:
int pthread_mutex_destroy(pthread_mutex_t *mutex);
int pthread_mutex_init(pthread_mutex_t *restrict mutex,
						const pthread_mutexattr_t *restrict attr);
 method 2:
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

2)lock and unlock
int pthread_mutex_lock(pthread_mutex_t *mutex);			// may wait
int pthread_mutex_trylock(pthread_mutex_t *mutex);		// won't wait
int pthread_mutex_unlock(pthread_mutex_t *mutex);

summary:
	during inner-thread communication,there're 3 methods to solve the synchronization.
	1) mutex
	set up vars,then create mutexs for them to control the access to them,then in the thread function,use while-cycle or for-cycle to check the mutex and modify the vars.
	2) condition var and mutex
	set up vars,then create mutexs for them.to avoid keep checking mutexs by while or for cycle,we can use condition vars.if the mutexs is freed,we can use pthread_cond_signal to awake up other waiting threads.
	3) semaphore
	mutex is 0 or 1.
	semaphore can > 1.
	it can be used both in inner-process synchronization and inner-threa synchronization.

	#include <semaphore.h>
	sem_init();
	sem_wait();
	sem_trywait();
	sem_post();
	sem_destroy();

