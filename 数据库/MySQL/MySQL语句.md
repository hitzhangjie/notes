[toc]

##### 1 连接一个数据库
```mysql -h{host} -P{port} -D{dbname} -u{user} -p```，然后回车根据提示输入密码即可。
##### 2 执行系统命令
一般登录到mysql服务器之后，用户是没有权限执行系统命令的，但是mysql中可以配置用户通过内置的```system```命令以数据库进程权限执行一些命令，例如system scp可以拷贝文件，system vim可以修改拷贝过来但是有少量错误的sql文件等等。
##### 3 SQL性能测试
一般一条sql语句执行后，都会在后面显示出这条sql执行过程中所花费的时间，但是如果我们想对自己新编写的sql的性能做个测试，也可以这么干，但是很有可能我们需要的sql不止一行，或者涉及到复杂的存储过程等等，这个时候肯定不能一行一行执行后手动去记录每一个语句的执行时间，怎么办呢？
执行这行命令：```set profiling=1```，之后执行的sql的耗时都会被服务器记录下来，然后可以通过执行命令：```show profiles```来查看最近执行的sql的耗时情况，以便我们及时对sql进行优化。
##### 4 mysql导出数据
```mysql -e "select * from tablename" -hhost -Pport -uuser -ppassword databasename > dump.data```
这种方式不需要锁表！
mysqldump完整导出表定义及数据需要锁表，在运维环境中，可能不一定有锁表权限，这种情况下可以通过上述方式来获取表的数据；
查看db、表定义可以通过```show create database dbname```或者```show create table tablename```来完成；
##### 5 乱码问题
```
set character_set_results=utf8;
set character_set_connection=utf8;
set character_set_client=utf8;
```
上面3句其实相当于下面这一句的效果：set names 'utf8';
##### 6 mysql屏蔽select输出
mysql client成功连接之后，执行```pager > /dev/null```将输出重定向到/dev/null丢弃，然后执行select的时候就会只显示执行时间了，select结果不会再输出；如果想让select恢复输出，可以执行```pager```，不再指定重定向就可以了。pager相关操作包括```pager less/ pager more/nopager```。
##### 7 mysql查看某个db占用的存储空间
```
select  sum(round(((data_length + index_length) / 1024 / 1024 ), 2)) as "SIZE IN MB"
from information_schema.tables
where table_schema = "SCHEMA-NAME";`
```
##### 9 查询中使用更强大的regexp，而不是like
like能进行的字符串匹配比较简单，能满足一般的简单匹配，例如```like '%%xxx%%'```，但是对于更加复杂的匹配就无能为力了，这时可以考虑使用正则表达式进行匹配，即regexp运算符：
```select ${field} from ${table} where ${field} regexp 'pattern'```。
##### 10 显示创建数据库、表的sql语句？
有时候我们希望查看完整的创建数据库、表的语句，desc只能对表结构进行简单的描述，并不能完整显示表创建时的细节，这个时候可以使用：```show create table ${tablename}```，也可以使用```show create database ${dbname}```来查看创建数据库的sql语句。
##### 11 运算结果的数据类型
mysql中逻辑运算<,>返回结果是long类型，同一个select语句中假如还有其他int字段，也会被转为long，jdbc中取回来后，map.get("fieldname")最好用Number进行接收，然后调用intValue()来取值；
##### 12 字段包括的字符数量 or 字节数量
mysql中`char(n)/varchar(n)`中的n代表的是字符数量，而非字节数量；
`binary(n)/varbinary(n)`中的n代表的是字节数量，注意二者区别；
varchar(n)在存储字符串的时候，会计算字符串长度，然后使用额外的一个字节或者两个字节来表示字符串长度，这个字符串长度作为一个前缀存储在实际的字符串值的前面。
##### 13 mysql中的主键自增id
insert的时候id=1,2,3假如事务回滚了,下次插入的时候id=4；
假如现在max(id)=4，现在delete删除id=4的记录，下次insert的时候id=5而不是4。
##### 14 存储过程、函数、触发器会降低性能
mysql中如果存储过程、函数、触发器逻辑中包括了deadcode（永远不会被执行的分支逻辑），虽然它不会执行，但是mysql分析器还是会去分析他们，对性能还是有影响的。参考文章：[Why MySQL Stored Procedures, Functions and Triggers Are Bad For Performance](https://www.percona.com/blog/2018/07/12/why-mysql-stored-procedures-functions-triggers-bad-performance/)
##### 15 查看允许的最大连接数
```
show variables like 'max_connections' // 显示最大允许连接数
show variables like 'max_user_connections' // 显示用户最大允许连接数
show processList; // 显示mysql当前正在执行的sql
```
##### 16 修改表的存储引擎
```
alter table ${tablename} engine=MyISAM;
alter table ${tablename} engine=InnoDB;
```
##### 17 MySQL分表
```
create table `tbl_1` (
`id` int unsigned not null auto_increment,
`name` varchar(64) not null,
`age` int unsigned not null,
PRIMARY KEY(id)
) ENGINE=MyISAM;

create table `tbl_2` (
...
);

create table `tbl_3` (
...
);

create table `tbl` (
`id` int unsigned not null auto_increment,
`name` varchar(64) not null,
`age` int unsigned not null,
PRIMARY KEY(id)
) ENGINE=MRG_MyISAM INSERT_METHOD=NO UNION=(tbl_1,tbl_2,tbl_3);
```

##### 18 创建db时，如何指定默认字符集以及整理引擎字符集？

```
create database dbname default character set utf8 default collate utf8_bin;
```
>utf8中一个汉字占3个字节，varchar(n)中指定的是字符的数量！

##### 19 设置单条sql语句最大长度？

单条sql查询语句是有最大长度限制的，以mysql为例进行说明，这里的sql语句长度是通过max_allowed_packet反映出来的，max_allowed_packet限定的是一个最大分组的字节数量，默认为10MB，如果查询语句特别长的话，可以设置这个参数大些。此外如果读取的时候，字段里面包括比较大的blob、clob字段，也应该设置这个参数大些。

修改方法：

- 修改mysql.conf在mysqld下面增加max_allowed_packet=xxMB
- 命令行里面执行set [global] max_allowed_packet=xxxxxx（注意单位是字节）

##### 20 检查mysql慢查询？

```SELECT * FROM information_schema.PROCESSLIST WHERE COMMAND!='Sleep';```

该命令会列出当前正在执行处理的sql以及耗时信息，通常该方法用于检查慢查询。

| ID | USER | HOST | DB | COMMAND | TIME | STATE | INFO |
|:-----:|:------:|:-------:|:----:|:--------------:|:------:|:-------:|:------:|
| 1 | root | ip:port | test | query | 0 | sending data | select *  from t_test ... |


##### X 其他
