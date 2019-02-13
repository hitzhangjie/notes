如果通过http访问github，会返回307状态代码，表示internal redirect，这个时候会被重定向到https，浏览器再发送一次https请求。

强制http跳转到https的方式有多种：

1. web服务器控制的强制跳转，例如nginx通过rewrite规则实现强制跳转、tomcat强制使用ssl；
2. web服务器中的应用程序通过301状态码控制跳转；
3. 页面中通过修改请求的url来实现跳转，例如修改window.location.href=<https://...；>