基于文件系统排他性创建文件的能力实现的文件锁工具类，benchmark结果：每秒支持大约40w次lock/unlock操作！

```c
#ifndef _FILELOCK_H
#define _FILELOCK_H 

#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <iostream>

#define LOCKFILE "/tmp/tmp.lock"

namespace LinuxExUtils {
    /**
     * 文件锁工具类
     */
    class FileLock {
        public:
            static int lock()
            {
                int tempfd;
                while((tempfd=open(LOCKFILE, O_CREAT|O_RDWR|O_EXCL, S_IRUSR|S_IWUSR)) < 0)
                {
                    if(errno != EEXIST) {
                        std::cerr << "Failed to create lockfile: " << LOCKFILE << std::endl;
                        return -1;
                    }
                }
                close(tempfd);
                return 0;
            }
            
            static int unlock()
            {
                return unlink(LOCKFILE);
            }
    };
}

#endif
```
