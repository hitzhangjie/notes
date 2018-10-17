```go
package stack

// GetCallerFunc 获取调用函数栈中的函数名，可以通过参数skip决定跳过几个stack frame来
// 提取对应的函数名，这里为了方便查看还返回了文件名及行号信息。在程序panic或者错误日志中
// 可能希望提取错误日志对应的栈帧或者主调函数信息，这个方法就非常有用。
func GetCallerFunc(skip int) (string, error) {

	fpcs := make([]uintptr, 1)
	// Skip 2 levels to get the caller
	n := runtime.Callers(skip, fpcs)
	if n == 0 {
		//fmt.Println("MSG: NO CALLER")
		return "", fmt.Errorf("MSG: NO CALLER")
	}

	caller := runtime.FuncForPC(fpcs[0] - 1)
	if caller == nil {
		//fmt.Println("MSG CALLER WAS NIL")
		return "", fmt.Errorf("MSG: CALLER IS NIL")
	}

	// Print the file name and line number
	fileName, lineNo := caller.FileLine(fpcs[0] - 1)
	baseName := fileName[strings.LastIndex(fileName, "/")+1:]
	funcName := caller.Name()

	return fmt.Sprintf("[%s:%d] %s", baseName, lineNo, funcName), nil
}
```
