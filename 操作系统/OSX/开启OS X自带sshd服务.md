**1 启动sshd服务遇到的问题**

- 需要使用绝对路径：sudo /usr/sbin/sshd
- 需要配置ssh_host_$(algorithm)_key：ssh-keygen -t ${...} -f /etc/ssh_host_$(algorithm)_key -C "" -N ""

特别注意指定选项-C "" -N ""，不然启动的时候会提示failed to load ssh_host_${...}_key；

**2 支持多种不同的解密算法**

sshd服务可以使用不同的加解密算法对安全性进行控制，可以对这些加解密算法进行下学习。