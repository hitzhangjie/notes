# Docker

Docker是一种容器技术，它与虚拟机不同，容器更加轻量。Docker简化了开发、运维人员的工作，develop、ship、deploy any where！

安装并启动一个linux镜像！

```sh
# 检出一个docker镜像，这里以centos为例
docker pull centos

# 运行该docker镜像，交互模式启动中端/bin/bash
sudo docker run -it centos  /bin/bash

# 运行该docker镜像，交互模式启动中端/bin/bash，并挂载本地文件夹到镜像
sudo docker run -it -v ~/debugger:/root/debugger centos  /bin/bash

# 在镜像运行期间，做了某些修改（如安装软件），希望将当前状态保存为新镜像
## 首先获取正在运行的docker容器id
docker ps
## 将指定容器id的容器状态保存为新的镜像
docker commit -a author -m message docker-ps-id repo:tag

# 将新生成的docker镜像push到dockerhub，需要先登录dockerhub
docker push docker-image-id

```
