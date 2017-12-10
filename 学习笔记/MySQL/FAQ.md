# FAQ

##### 1.创建db时，如何指定默认字符集以及整理引擎字符集？

```
create database dbname default character set utf8 default collate utf8_bin;
```
>utf8中一个汉字占3个字节，varchar(n)中指定的是字符的数量！

##### 2.设置单条sql语句最大长度？

单条sql查询语句是有最大长度限制的，以mysql为例进行说明，这里的sql语句长度是通过max_allowed_packet反映出来的，max_allowed_packet限定的是一个最大分组的字节数量，默认为10MB，如果查询语句特别长的话，可以设置这个参数大些。此外如果读取的时候，字段里面包括比较大的blob、clob字段，也应该设置这个参数大些。

修改方法：

- 修改mysql.conf在mysqld下面增加max_allowed_packet=xxMB
- 命令行里面执行set [global] max_allowed_packet=xxxxxx（注意单位是字节）





