假定tinyproxy安装在机器9.77.4.168上，并且监听8888端口。现在要讲cvm的机器通过该tinyproxy访问外部网络，如何设置呢？

cvm机器上需进行如下设置：

```bash
export http_proxy=http://9.77.4.168:8888
export https_proxy=http://9.77.4.168:8888
```

然后把cvm的ip加到这个168机器的/etc/tinyproxy/tinyprox.conf：
```bash
....
Allow ${cvm-ip}
....
```
重启下tinyproxy之后，可以通过在cvm机器上访问下网络，如wget之类的，来测试下网络是否访问是否ok了

！