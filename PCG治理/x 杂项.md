exploring http/2 with go: https://www.youtube.com/watch?v=3IHJ6gJHITw



# http2

http2里面stream相当于一个会话，针对每个会话，涉及到请求响应的处理周期；

http2里面stream上发送的每个请求、响应都可以细分为多个frame进行传送、重组；

**http1.x vs http2.x**

- http1是将整个html文档进行发送的，之后可能会在传输层进行分片。
- http2会将stream上要发送的单个请求分为多个frame进行发送，相当于将在传输层要做的分片工作提前了，如head1、header2、payload等，。
- http2会将请求对应的响应也是按照多个heder进行接收的，收完在传输层进行包的重组。

# go-micro

microservices in go using go-micro: https://www.youtube.com/watch?v=OcjMi9cXItY
                                                              https://github.com/micro/go-micro
go这个小组的初步设计，设计很大程度上参考了这个框架。



