[TOC]

##### 1 连接一个数据库
mysql -h{host} -P{port} -D{dbname} -u{user} -p，然后回车根据提示输入密码即可。
##### 2 执行系统命令
一般登录到mysql服务器之后，用户是没有权限执行系统命令的，但是mysql中可以配置用户通过内置的system命令以数据库进程权限执行一些命令，例如system scp可以拷贝文件，system vim可以修改拷贝过来但是有少量错误的sql文件等等。
##### 3 SQL性能测试
一般一条sql语句执行后，都会在后面显示出这条sql执行过程中所花费的时间，但是如果我们想对自己新编写的sql的性能做个测试，也可以这么干，但是很有可能我们需要的sql不止一行，或者涉及到复杂的存储过程等等，这个时候肯定不能一行一行执行后手动去记录每一个语句的执行时间，怎么办呢？
执行这行命令：set profiling=1，之后执行的sql的耗时都会被服务器记录下来，然后可以通过执行命令：show profiles来查看最近执行的sql的耗时情况，以便我们及时对sql进行优化。
##### 4 mysql导出数据
mysql -e "select * from tablename" -hhost -Pport -uuser -ppassword databasename > dump.data
这种方式不需要锁表！
mysqldump完整导出表定义及数据需要锁表，在运维环境中，可能不一定有锁表权限，这种情况下可以通过上述方式来获取表的数据；
查看db、表定义可以通过show create database dbname或者show create table tablename来完成；
##### 5 乱码问题
set character_set_results=utf8;
set character_set_connection=utf8;
set character_set_client=utf8;
上面3句其实相当于下面这一句的效果：set names 'utf8';
##### 6 mysql导出数据
mysql -e "select * from tablename" -hhost -Pport -uuser ppassword databasename > dump.data
这种方式不需要锁表！
mysqldump完整导出表定义及数据需要锁表，在运维环境中，可能不一定有锁表权限，这种情况下可以通过上述方式来获取表的数据；
查看db、表定义可以通过show create database dbname或者show create table tablename来完成；
##### 7 mysql屏蔽select输出
mysql client成功连接之后，执行pager > /dev/null指定输出重定向，然后执行select的时候就会只显示执行时间了，select结果不会再输出；如果想让select恢复输出，可以执行pager，不再指定重定向就可以了。
##### 8 mysql查看某个db占用的存储空间
select  sum(round(((data_length + index_length) / 1024 / 1024 ), 2)) as "SIZE IN MB"
from information_schema.tables
where table_schema = "SCHEMA-NAME";`
##### 9 查询中使用更强大的regexp，而不是like？
like能进行的字符串匹配比较简单，能满足一般的简单匹配，例如like '%%xxx%%'，但是对于更加复杂的匹配就无能为力了，这时可以考虑使用正则表达式进行匹配，即regexp运算符：
select ${field} from ${table} where ${field} regexp '自定义的正则表达式'。
##### 10 显示创建数据库、表的sql语句？
有时候我们希望查看完整的创建数据库、表的语句，desc只能对表结构进行简单的描述，并不能完整显示表创建时的细节，这个时候可以使用：show create table ${tablename}，也可以使用show create database ${dbname}来查看创建数据库的sql语句。
##### 11 运算结果的数据类型
mysql中逻辑运算<,>返回结果是long类型，同一个select语句中假如还有其他int字段，也会被转为long，jdbc中取回来后，map.get("fieldname")最好用Number进行接收，然后调用intValue()来取值；
##### 12 字段包括的字符数量 or 字节数量
mysql中char(n)\varchar(n)中的n代表的是字符数量，而非字节数量；
binary(n)、varbinary(n)中的n代表的是字节数量，注意二者区别；
varchar(n)在存储字符串的时候，会计算字符串长度，然后使用额外的一个字节或者两个字节来表示字符串长度，这个字符串长度作为一个前缀存储在实际的字符串值的前面。
##### 13 mysql中的主键自增id
insert的时候id=1,2,3假如事务回滚了,下次插入的时候id=4；
假如现在max(id)=4，现在delete删除id=4的记录，下次insert的时候id=5而不是4。


##### X 其他



