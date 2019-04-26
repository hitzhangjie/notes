golang目录相关操作：

- 获取当前可执行程序路径；
- 获取当前可执行程序父路径；
- 检查文件是否已经存在；
- 相对路径转为绝对路径；

```go
// Copyright 2019 Go-Neat
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package common

import (
   "os"
   "os/user"
   "path"
   "path/filepath"
   "strings"
)

// Get current directory of executable file,
// if fails returns empty filepath and error
func GetCurrentDirectory() (string, error) {
   dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
   if err != nil {
      return "", err
   }
   return dir, nil
}

// returns substring of s, i.e., s[pos:pos+length]
func substr(s string, pos, length int) string {
   runes := []rune(s)
   l := pos + length
   if l > len(runes) {
      l = len(runes)
   }
   return string(runes[pos:l])
}

// Get parental directory of executable file,
// if fails returns empty filepath and error
func GetParentDirectory() (string, error) {
   dirctory, err := GetCurrentDirectory()
   if err != nil {
      return "", err
   }
   parentPath := substr(dirctory, 0, strings.LastIndex(dirctory, string(filepath.Separator)))
   return parentPath, nil
}

// Check whether file is existed,
// if existed returns true, otherwise returns false
func CheckFileIsExist(filename string) bool {
   if _, err := os.Stat(filename); os.IsNotExist(err) {
      return false
   }
   return true
}

// AbsoluteFilePath 绝对路径转相对路径
func AbsoluteFilePath(p string) (string, error) {

   if path.IsAbs(p) {
      return p, nil
   }

   // convert ~ to home directory of current user
   var home string
   if usr, err := user.Current(); err != nil {
      return "", err
   } else {
      home = usr.HomeDir
   }

   if p == "~" {
      // In case of "~", which won't be caught by the "else if"
      p = home
      return p, nil
   } else if strings.HasPrefix(p, "~/") {
      // Use strings.HasPrefix so we don't match paths like "/something/~/something/"
      p = filepath.Join(home, p[2:])
      return p, nil
   }

   // convert to absolute path providing it's indeed a valid filepath
   return filepath.Abs(p)
}
```