一个简单的makefile写法：

```bash
program: xxx xxxx
	cmd		(show cmd and result)
	@cmd	(only show result)
	-cmd	(continue when error occurs)
clean:
	-rm *.o

install:
	-cp ...
distclean:
	-rm *.o
	-rm *.cfg
	-rm *...
	
PHONY: clean
```

