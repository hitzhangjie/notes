golang标准库sql提供了一些针对关系数据库的抽象，具体的sql操作由不同的关系型数据库产品提供对应的实现，例如mysql数据库的相关驱动实现。在项目中如果要支持mysql操作，只需要import标准库sql以及mysql驱动即可，其他的关系数据库产品的访问方式与之类似。

这里以笔者使用最多的mysql为例，描述下golang针对mysql的相关操作。

```go
package main

import (
	"fmt"
    "database/sql"
	_ "github.com/go-sql-driver/mysql"
)

func main() {
	// 首先连接到数据库
	db, err := openConnection("127.0.0.1:3306", "golang", "root", "justdoit")
	if err != nil {
		fmt.Println(err)
		return
	}

	// 测试insert操作
	fmt.Println("test mysql insert:")
	sql := "insert into t_user(name,age,sex) values(?,?,?)"
	rs, err := db.Exec(sql, "zhangjie", 28, 0)
	if err != nil {
		fmt.Println(err)
		return
	}
	ret, err := rs.RowsAffected()
	if err != nil {
		fmt.Println(err)
	}
	if ret != 1 {
		fmt.Println("inserted 1 row failed")
		return
	}
	fmt.Println("insert 1 row success")
	fmt.Println()

	// 测试select操作
	fmt.Println("test mysql select:")
	rows, err := db.Query("select * from t_user")
	if err != nil {
		fmt.Println(err)
		return
	}

	for rows.Next() {
		var id int
		var name string
		var age int
		var sex int
		err := rows.Scan(&id, &name, &age, &sex)
		if err != nil {
			fmt.Println(err)
			continue
		}
		fmt.Printf("id:%d name:%s age:%d sex:%d\n", id, name, age, sex)
	}
}

//连接数据库示例(通过*sql.DB执行数据库操作，其内部维护了数据库连接池)
func openConnection(ipport, database, user, pwd string) (*sql.DB, error) {
	connstr := fmt.Sprintf("%s:%s@tcp(%s)/%s?charset=utf8mb4", user, pwd, ipport, database)
	dbInstance, err := sql.Open("mysql", connstr)
	return dbInstance, err
}
```

