http post操作示例代码，http get操作也可以简单的坐下修改来实现：

```go
import (
    "net/http"
    "net/url"
    "io/ioutil"
    "encoding/json"
)

// doHttpReq params, headers are both k,v pairs, 
// returns response map converted from rsp json.
// if error occurred, return an error.
func doHttpReq(httpUrl string, params, headers map[string]string) (map[string]interface{}, error) {
    // params
    form := make(url.Values)
    for p, v := range params {
        form.Add(k, v)
    }
    // build http request
    buf := []byte(form.Encode())
    req, err := http.NewRequest("POST", httpUrl, bytes.NewBuffer(buf))
    // headers
    for h, v := range headers {
        req.Header.Add(h, v)
    }
    // send & recv & parse
    httpClient := &http.Client{}
    rsp, err := httpClient.Do(req)
    if err != nil {
        return nil, err
    }
    if rsp.StatusCode != 200 {
        return nil, fmt.Errorf("http rsp StatusCode:%v", rsp.StatusCode)
    }
    body, err := ioutil.ReadAll(rsp.Body)
    if err != nil {
        return nil, err
    }
    rspdata := map[string]interface{}{}
    err = json.Unmarshal(body, &rspdata)
    if err != nil {
        return nil, err
    }
    return rspdata, nil
}
```

