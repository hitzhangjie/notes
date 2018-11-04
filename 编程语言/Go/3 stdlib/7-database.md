golang中对mysql进行操作，目前还是比较原始，还没有像java中mybatis、hibernate这么强大又易用的orm框架。github上其实也有几个面向golang的orm三方库，但是体验了下，确实和mybatis、hibernate比起来差距不是一点半点。这里介绍下golang中如何利用标准库中的api对mysql进行操作。 

# connect to mysql

```go
func openConn(ipport, database, user, pwd string) (*sql.DB, error) {
	connstr := fmt.Sprintf("%s:%s@tcp(%s)/%s?charset=utf8mb4", user, pwd, ipport, database)
	dbInstance, err := sql.Open("mysql", connstr)
	return dbInstance, err
}
```

注意mysql里面的utf8编码并不是真正的utf8，想要获得真正的utf8编码吗？那就在mysql中使用编码**utf8mb4**吧！

# exec insert

```go
func insertStudent(name string, age int, sex int) error {
	sql := "insert into t_user(name,age,sex) values(?,?,?)"
    rs, err := db.Exec(sql, name, age, sex)
	if err != nil {
		return
	}
	ret, err := rs.RowsAffected()
	if err != nil {
		return err
	}
	if ret != 1 {
        return errors.New("insert 1 row failed")
	}
	return nil
}
```

#exec select

```go
type Student struct {
    Id string
    Name string
    Age int
    Sex int
}
func queryStudent(name string) ([]*Student, error) {
    students := []*Student{}
    sql := "select * from t_user where name like '%%?%%'"
    rows, err := db.Query(sql, name)
	if err != nil {
		return nil, err
	}

	for rows.Next() {
        s := Student{}
		err := rows.Scan(&s.Id, &s.Name, &s.Age, &s.Sex)
		if err != nil {
			return nil, err
		}
        students = append(students, s)
	}
    return students, nil
}
```

# exec update

```go
func updateStudent(id int, name string) error {
    sql := "update t_user set name = ? where id = ?"
    _, _ := db.Exec(sql, name, age)
    ...
}
```

# more actions

golang中mysql相关操作远远不止CRUD，更多的mysql操作详见sql package，具体的使用可以参考这里的示例，点击查看 [sql测试样例](https://golang.org/src/database/sql/example_test.go)，这里的示例包含了更加高级的操作，如事务、连接管理、超时管理等等。