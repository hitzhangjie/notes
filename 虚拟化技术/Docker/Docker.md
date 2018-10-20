# Docker

Docker是一种容器技术，它与虚拟机不同，容器更加轻量。Docker简化了开发、运维人员的工作，develop、ship、deploy any where！

安装并启动一个linux镜像！

```sh
docker pull centos
sudo docker run -it centos  /bin/bash
sudo docker run -it -v ~/debugger:/root/debugger centos  /bin/bash

# install softwares or make some changes
# save it as new image

# get docker process's id
docker ps
docker commit -a author -m message docker-ps-id repo:tag

# docker push may fail because privilege denied by docker hub
docker push docker-image-id

```
