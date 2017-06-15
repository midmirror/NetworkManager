# NetworkManager
Swift 3 基于 AFNetworking 的网络请求封装（Get/Post/Download/Upload/SecurityPolicy证书/基于YYCache请求缓存）



### 说明

| 框架           | 介绍   |
| ------------ | ---- |
| AFNetworking | 网络通讯 |
| YYCache      | 本地缓存 |

对 AFNetworking 接口做一层封装，方便以后的替换网络框架等日常维护。对Get、Post请求进行本地数据缓存，以增强弱网络环境用户体验，降低对服务器不必要的请求。

APP 实际开发需求使用到的接口会在此基础上，再做一层封装。

#### 设置网络请求参数的格式

```swift
/// 设置网络请求参数的格式:默认为二进制格式
///
/// - parameter requestSerializer: json/http (json格式/二进制格式)
class func setRequestSerializer(requestSerializer: RequestSerializer)
```

#### 设置服务器响应数据格式

```swift
/// 设置服务器响应数据格式:默认为JSON格式
///
/// - parameter responseSerializer: json/http (json格式/二进制格式)
class func setResponseSerializer(responseSerializer: ResponseSerializer)
```

#### 设置请求头

```swift
/// 设置请求头
///
/// - parameter value:
/// - parameter headerField:
class func setValue(value: String, forHTTPHeaderField headerField: String)
```

#### 设置请求超时时间:默认为30S

```swift
/// 设置请求超时时间:默认为30S
///
/// - parameter timeout: 时长
class func setRequestTimeoutInterval(timeout: TimeInterval) {
}
```

#### 配置自建证书的Https请求

```swift
/// 配置自建证书的Https请求
///
/// - parameter cerPath:              自建Https证书的路径
/// - parameter isValidateDomainName: 是否需要验证域名，默认为YES. 如果证书的域名与请求的域名不一致，需设置为NO (即服务器使用其他可信任机构颁发的证书，也可以建立连接)
class func setSecurityPolicy(withCerPath cerPath: String, isValidateDomainName: Bool)
```

#### GET 请求

```swift
// MARK: - GET 请求
NetworkManager.get(withCache: true, request: "请求url", parameters: "请求参数字典", whenReadCache: { (cacheData) in
            	// 读取到缓存数据 cacheData
            }, whenSuccess: { (responseData) in
                // 请求成功，数据是 responseData
            }) { (error) in
                // 请求过程中出错
        }
```

#### POST 请求

```swift
// MARK: - POST 请求
NetworkManager.post(withCache: true, request: "请求url", parameters: "请求参数字典", whenReadCache: { (cacheData) in
            	// 读取到缓存数据 cacheData
            }, whenSuccess: { (responseData) in
                // 请求成功，数据是 responseData
            }) { (error) in
                // 请求过程中出错
        }
```

#### Upload File 上传文件

```swift
let zipFile = NetworkFileModel.init()
zipFile.fileData = Data.init()  // you file data
zipFile.name = "resourceFile"
zipFile.mimeType = "application/zip"
zipFile.fileName = "QQ.zip"     // your file name + extension
        
NetworkManager.uploadFiles(with: url, parameters: parameters, files: [zipFile], whenUpdateProgress: { (progress) in
            // 上传进度
        }, whenSuccess: { (response) in
            // 上传成功
        }) { (error) in
            // 上传过程中出错
        }
```

#### Download File 下载文件

```swift
NetworkManager.download(withURL: "服务器url", fileDirectory: "本地保存路径", whenUpdateProgress: { (progress) in
            	// 下载进度
            }, whenSuccess: { (filePath) in
                // 下载好的文件所在路径
            }) { (error) in
                // 下载过程中出错
        }
```



### 缓存 API

> 在GET/POST请求中，根据实际需求进行缓存数据。

#### 缓存网络数据

```swift
/// 异步缓存网络数据,根据请求的 URL与parameters，做KEY存储数据, 缓存多级页面的数据
///
/// - parameter data:       服务器返回的数据
/// - parameter url:        请求的URL地址
/// - parameter parameters: 请求的参数
open class func writeCache(withData data: NSCoding, url: String, parameters: Dictionary<String, Any>?) 
```

#### 取出缓存数据

```swift
/// 根据请求的 URL与parameters 取出缓存数据
///
/// - parameter url:        请求的URL地址
/// - parameter parameters: 请求的参数
///
/// - returns: 缓存的服务器数据
open class func readCache(withURL url: String, parameters: Dictionary<String, Any>?) -> NSCoding?
```

#### 异步取出缓存数据

```swift
/// 根据请求的 URL与parameters 异步取出缓存数据
///
/// - parameter url:          请求的URL地址
/// - parameter parameters:   请求的参数
/// - parameter withClosoure: 异步回调缓存的数据
open class func readCache(withURL url: String, parameters: Dictionary<String, Any>, withClosoure: @escaping (_ object: NSCoding) -> Void)
```

#### 获取网络缓存的总大小

```swift
open class func cacheSize() -> Int
```

#### 删除所有网络缓存

```swift
open class func removeAllCache()
```

