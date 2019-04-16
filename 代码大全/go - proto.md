Google Proto Buffer是一种常用的编解码格式，简称protobuf或者pb。pb是一种自描述的语言，其包含的信息非常丰富，可以用来完整描述一个服务，包括服务名称、rpc接口、接口请求、接口响应等等。

```protobuf
syntax = "proto2";
package test_svr;

enum BIG_CMD {
    CMD_TEST_SVR = 0x1;
};

enum SUB_CMD {
    CMD_BuyApple = 0x1;
};

// cmd: 0x1, BuyApple 
message BuyAppleReq {
    optional uint32 num = 1;
};

message BuyAppleRsp {
    optional uint32 result = 1;
    optional string errmsg = 2;
};

service test_svr {
    rpc BuyApple(BuyAppleReq) returns(BuyAppleRsp);
};
```

常基于pb文件来构建一些自动化工具，如自动化代码生成、自动化协议测试proxy之类的，实现这些自动化工具的前提是要正确解析这里的pb文件，现在有如下几个选择可用来对pb文件进行解析。

# 基于protoc解析

方法1：基于protoc的解析能力，protoc解析成功后会构建一个FileDescriptor对象，然后将其封装到代码生成请求，并通过管道的方式传递给子进程，子进程如protoc-gen-go会接收请求并提取FileDescriptor对象，并据此拿到pb描述信息，进而有针对性的生成代码。

但是这种方式，有个缺点，就是必须依赖protoc这个工具，在没有好的golang三方库解析pb之前，也可以通过这种方式来实现，但是现在github上已经有了几个比较优秀的pb解析库，实在没必要再继续依赖protoc了。因为依赖protoc就要写protoc的插件，需要fork protoc-gen-go的代码然后修修补补，而且生成代码的方式也很鸡肋。对于生成一个服务工程而言，涉及代码较多，这种实现方式可维护性太差。

# 基于jhump/protoreflect解析库实现

```go
import (
	"context"
	"fmt"
	"github.com/jhump/protoreflect/desc/protoparse"
	"time"
)

func main() {

	parser := protoparse.Parser{
		ImportPaths:                     []string{"/Users/zhangjie/Desktop"},
		IncludeSourceCodeInfo:           true,
	}

	fname := "test_svr.proto"
	descriptors, err := parser.ParseFiles(fname)
	fmt.Println(descriptors, err)

	fd := descriptors[0]
	fmt.Println("packageName:", fd.GetPackage())
	fmt.Println("serviceName:", fd.GetServices()[0].GetName())

	fmt.Println("messages:")
	for idx, msg := range fd.GetMessageTypes() {
		fmt.Println("\t", idx+1, "messageName:", msg.GetName())
		fmt.Println("\t", idx+1, "messageComment:", msg.GetSourceInfo())
		fmt.Println("\t", idx+1, "messageFields:", msg.GetFields())
	}

	fmt.Println("enums:", fd.GetEnumTypes())
}
```

# 基于emicklei/proto解析库实现

解析pb主要是希望提取关心的描述信息，关心的描述信息可以抽象成下面的类型：

```go
type ServerAsset struct {
   ServerName    string        // 服务名称
   PackageName   string        // pb包名称
   CreateTime    string        // 服务创建时间
   Protocol      string        // 协议类型，ilive，nrpc，simplesso
   RPC           []ServerRPC   // rpc接口定义
}

type ServerRPC struct {
   Name         string // RPC方法名
   Cmd          string // RPC命令字
   RequestType  string // RPC请求消息类型
   ResponseType string // RPC响应消息类型
}
```

现在开始解析，emicklei/proto这个库没有jhump/protoreflect这个库解析的时候那么直接，用起来没那么方便，要采用类似遍历或者回调的方式来对相关信息进行提取，这个用起来不太爽。因为用起来比较啰嗦，没jhump/protoreflect那么直接、简单，所以写个demo总结下其使用方式。

```go
var (
	g_server_asset ServerAsset

	// ilive
	g_ilive_bigcmd = 0
	g_ilive_subcmd = []int{}

	// simplesso
	g_simsso_cmd = []int{}
)

func ParseProtoFile(filename, protocol string) (*ServerAsset, error) {
    
	pbspec, err := openProtoFile(filename)
	if err != nil {
		return nil, err
	}

	WithErrorAssert(GetPackageName, pbspec) // package name
	//fmt.Printf("server_asset:%#v\n", g_server_asset)

	WithErrorAssert(GetServerName, pbspec) // server name
	//fmt.Printf("server_asset:%#v\n", g_server_asset)

	WithErrorAssert(GetCmdEnum, pbspec) // server cmd
	//fmt.Printf("server_asset:%#v\n", g_server_asset)

	WithErrorAssert(GetServerRpc, pbspec) // server rpc
	//fmt.Printf("server_asset:%#v\n", g_server_asset)

	g_server_asset.Spec = *spec.GetTypeSpec(protocol) // protocol spec
	//fmt.Printf("server spec:%#v\n", g_server_asset)

	return &g_server_asset, nil
}

func openProtoFile(filename string) (*proto.Proto, error) {
    
    reader, err := os.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("open protofile error, %v", err)
	}
    defer reader.Close()
    
    parser := proto.NewParser(reader)
	definition, err := parser.Parse()
	if err != nil {
		return nil, fmt.Errorf("parse protofile error, %v", err)
	}
    
    return definition, nil
}

func WithErrorAssert(phase ParsePhase, pbspec *proto.Proto) string {
	data, err := phase(pbspec)
	if err != nil {
		fmt.Println("error occur: ", err)
		os.Exit(1)
	}
	return data
}

// 获取package name
func GetPackageName(pbspec *proto.Proto) (string, error) {

	if pbspec == nil {
		return "", fmt.Errorf("pbspec is nil")
	}

	for _, el := range pbspec.Elements {
		pkg, ok := el.(*proto.Package)
		if ok && pkg.Name != "" {
			g_server_asset.PackageName = strings.Replace(pkg.Name, ".", "_", -1)
		}
	}

	if g_server_asset.PackageName == "" {
		return "", fmt.Errorf("packageName is not defined")

	}

	return g_server_asset.PackageName, nil
}

// 获取server name
func GetServerName(pbspec *proto.Proto) (string, error) {

	if pbspec == nil {
		return "", fmt.Errorf("pbspec is nil")
	}

	proto.Walk(pbspec, proto.WithService(handleService))
	return g_server_asset.ServerName, nil
}

func handleService(service *proto.Service) {
	g_server_asset.ServerName = service.Name
}

//  获取server rpc
func GetServerRpc(pbspec *proto.Proto) (string, error) {

	if pbspec == nil {
		return "", fmt.Errorf("pbspec is nil")
	}

	proto.Walk(pbspec, proto.WithRPC(handleRpc))
	return "", nil
}

func handleRpc(rpc *proto.RPC) {

	cmd := ""

	if g_server_asset.Protocol == "nrpc" {
		cmd = rpc.Name
	} else if g_server_asset.Protocol == "simplesso" {
		cmd = GetCmdString("simplesso", rpc)
	} else if g_server_asset.Protocol == "ilive" {
		// 0x$bigcmd_0x$subcmd
		cmd = GetCmdString("ilive", rpc)
	} else {
		fmt.Println(("invalid protocol, only nrpc,simplesso,ilive supported"))
		os.Exit(1)
	}

	server_rpc := ServerRPC{
		Name:         rpc.Name,
		Cmd:          cmd,
		RequestType:  rpc.RequestType,
		ResponseType: rpc.ReturnsType,
	}

	g_server_asset.RPC = append(g_server_asset.RPC, server_rpc)
}

func GetCmdString(protocol string, rpc *proto.RPC) string {
	if protocol == "ilive" {
		bigcmd := g_ilive_bigcmd
		subcmd := g_ilive_subcmd[len(g_ilive_subcmd)-1]
		return fmt.Sprintf("ilive_0x%#v_0x%#v", bigcmd, subcmd)
	} else if protocol == "simplesso" {
		cmd := g_simsso_cmd[len(g_simsso_cmd)-1]
		return fmt.Sprintf("simplesso_0x%#v", cmd)
	} else {
		return ""
	}
}

// 获取enum
func GetCmdEnum(pbspec *proto.Proto) (string, error) {

	if pbspec == nil {
		return "", fmt.Errorf("pbspec is nil")
	}

	proto.Walk(pbspec, proto.WithEnum(handleEnum))
	return "", nil
}

func handleEnum(enum *proto.Enum) {

	if g_server_asset.Protocol == "ilive" {

		if enum.Name == "BIG_CMD" {
			el := enum.Elements[0]
			field, ok := el.(*proto.EnumField)
			if ok {
				g_ilive_bigcmd = field.Integer
			}
		}

		if enum.Name == "SUB_CMD" {
			for _, el := range enum.Elements {
				field, ok := el.(*proto.EnumField)
				if ok {
					g_ilive_subcmd = append(g_ilive_subcmd, field.Integer)
				}
			}
		}

	} else if g_server_asset.Protocol == "simplesso" {

		if enum.Name == "SERVICE_CMD" {
			for _, el := range enum.Elements {
				field, ok := el.(*proto.EnumField)
				if ok {
					g_simsso_cmd = append(g_simsso_cmd, field.Integer)
				}
			}
		}

	} else {
		return
	}
}
```



