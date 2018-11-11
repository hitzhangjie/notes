如何自己构建一个image呢，比如一个centos7的image，有两种办法，一种是自己下载对应的centos7的文件，创建dockerfile然后docker build来构建，另一种是dockerfile里面通过From指令引用他人之前创建好的，然后在此基础上进行构建。

```bash
FROM centos
#ADD centos-7-x86_64-docker.tar.xz /
LABEL name="CentOS Base Image" \
    vendor="CentOS" \
    license="GPLv2" \
    build-date="20181021"
CMD ["/bin/bash"]
```

然后docker build就可以了，构建成功之后可以push到自己的docker hub账号中去，后面就可以方便使用了。