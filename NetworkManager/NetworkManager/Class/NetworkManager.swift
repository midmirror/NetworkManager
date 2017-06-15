//
//  AFNetWorkingManager.swift
//
//  Created by midmirror on 2017/3/1.
//  Copyright © 2017年 midmirror. All rights reserved.
//

import Foundation

public enum NetworkStatus {
    case
    /** 未知网络*/
    unknown,
    /** 无网络*/
    notReachable,
    /** 手机网络*/
    reachableViaWWAN,
    /** WIFI网络*/
    reachableViaWiFi
}

public enum RequestSerializer {
    case
    /** 设置请求数据为JSON格式*/
    json,
    /** 设置请求数据为二进制格式*/
    http
}

public enum ResponseSerializer {
    case
    /** 设置响应数据为JSON格式*/
    json,
    /** 设置响应数据为二进制格式*/
    http
}

class NetworkFileModel {
    var fileData: Data?
    var name = ""           // 上传参数字段
    var fileName = ""       // 资源文件名字,含后缀 如apple.jpg
    var mimeType = ""
}

class NetworkManager: NSObject {
    
    public typealias SuccessClosure = (_ responseObject: Any?) -> Void
    public typealias FailureClosure = (_ error: Error) -> Void
    public typealias RequestCacheClosure = (_ responseObject: Any?) -> Void
    public typealias ProgressClosure = (_ progress: Progress) -> Void
    public typealias NetworkStatusClosure = (_ status: NetworkStatus) -> Void
    
    //    static NSMutableArray *_allSessionTask;
    //    static AFHTTPSessionManager *_sessionManager;
    
    static var sessionManager: AFHTTPSessionManager!
    static var sessionDataTasks: [URLSessionTask]!
    
    //    private override init() {
    //
    //    }
    
    // static let shared = NetworkManager()
    
    override class func initialize() {
        sessionDataTasks = [URLSessionTask]()
        sessionManager = AFHTTPSessionManager.init()
        sessionManager.requestSerializer.timeoutInterval = 30
        sessionManager.responseSerializer = AFJSONResponseSerializer.init()
        let contentTypes: Set<String> = ["application/json", "text/html", "text/json", "text/plain", "text/javascript", "text/xml", "image/*"]
        sessionManager.responseSerializer.acceptableContentTypes = contentTypes
        AFNetworkActivityIndicatorManager.shared().isEnabled = true
    }
    
    class func networkStatus(whenUpdateStatus: @escaping NetworkStatusClosure) {
        
        DispatchQueue.once(token: "com.hprt.queue.once") {
            AFNetworkReachabilityManager.shared().setReachabilityStatusChange({ (status: AFNetworkReachabilityStatus) in
                switch (status) {
                case .unknown:
                    whenUpdateStatus(.unknown)
                    break;
                case .notReachable:
                    whenUpdateStatus(.notReachable)
                    break;
                case .reachableViaWWAN:
                    whenUpdateStatus(.reachableViaWWAN)
                    break;
                case .reachableViaWiFi:
                    whenUpdateStatus(.reachableViaWiFi)
                    break;
                }
            })
        }
    }
    
    class func isNetwork() -> Bool {
        return AFNetworkReachabilityManager.shared().isReachable
    }
    
    class func isWWANNetwork() -> Bool {
        return AFNetworkReachabilityManager.shared().isReachableViaWWAN
    }
    
    class func isWiFiNetwork() -> Bool {
        return AFNetworkReachabilityManager.shared().isReachableViaWiFi
    }
    
    class func appendDataTask(_ task: URLSessionTask) {
        sessionDataTasks.append(task)
    }
    
    class func removeDataTask(_ task: URLSessionTask) {
        sessionDataTasks.remove(at: sessionDataTasks.index(of: task)!)
    }
    
    
    /// 设置网络请求参数的格式:默认为二进制格式
    ///
    /// - parameter requestSerializer: json/http (json格式/二进制格式)
    class func setRequestSerializer(requestSerializer: RequestSerializer) {
        sessionManager.requestSerializer = requestSerializer==RequestSerializer.http ? AFHTTPRequestSerializer() : AFJSONRequestSerializer()
    }
    
    
    /// 设置服务器响应数据格式:默认为JSON格式
    ///
    /// - parameter responseSerializer: json/http (json格式/二进制格式)
    class func setResponseSerializer(responseSerializer: ResponseSerializer) {
        sessionManager.responseSerializer = responseSerializer==ResponseSerializer.http ? AFHTTPResponseSerializer() : AFJSONResponseSerializer()
    }
    
    
    /// 设置请求头
    class func setValue(value: String, forHTTPHeaderField headerField: String) {
        sessionManager.requestSerializer.setValue(value, forHTTPHeaderField: headerField)
    }
    
    /// 设置请求超时时间:默认为30S
    ///
    /// - parameter timeout: 时长
    class func setRequestTimeoutInterval(timeout: TimeInterval) {
        sessionManager.requestSerializer.timeoutInterval = timeout
    }
    
    
    /// 配置自建证书的Https请求
    ///
    /// - parameter cerPath:              自建Https证书的路径
    /// - parameter isValidateDomainName: 是否需要验证域名，默认为YES. 如果证书的域名与请求的域名不一致，需设置为NO (即服务器使用其他可信任机构颁发的证书，也可以建立连接)
    class func setSecurityPolicy(withCerPath cerPath: String, isValidateDomainName: Bool) {
        let cerData = try! Data.init(contentsOf: URL.init(string: cerPath)!)
        // 使用证书验证模式
        let securityPolicy = AFSecurityPolicy.init(pinningMode: AFSSLPinningMode.certificate)
        // 如果需要验证自建证书(无效证书)，需要设置为YES
        securityPolicy.allowInvalidCertificates = true
        // 是否需要验证域名，默认为YES
        securityPolicy.validatesDomainName = isValidateDomainName
        let pinnedCertificates: Set<Data> = [cerData]
        securityPolicy.pinnedCertificates = pinnedCertificates
        sessionManager.securityPolicy = securityPolicy
    }
    
    // MARK: - GET 请求
    class func get(withCache isCache: Bool, request: String, parameters: Dictionary<String, Any>?, whenReadCache: RequestCacheClosure?, whenSuccess: SuccessClosure?, whenFailure: FailureClosure?) -> URLSessionDataTask {
        
        if isCache == true {
            // 读取缓存
            whenReadCache?(NetworkCacheManager.readCache(withURL: request, parameters: parameters))
        }
        
        let task = sessionManager.get(request, parameters: parameters, progress: { (progress) in
            
        }, success: { (task, responseObject) in
            removeDataTask(task)
            whenSuccess?(responseObject)
            if isCache == true {
                // 对数据进行异步缓存
                NetworkCacheManager.writeCache(withData: responseObject as! NSCoding, url: request, parameters: parameters)
            }
        }) { (task, error) in
            removeDataTask(task!)
            whenFailure?(error)
        }
        appendDataTask(task!)
        return task!
    }
    
    // MARK: - POST 请求
    class func post(withCache isCache: Bool, request: String, parameters: Dictionary<String, Any>?, whenReadCache: RequestCacheClosure?, whenSuccess: SuccessClosure?, whenFailure: FailureClosure?) -> URLSessionDataTask {
        
        if isCache == true {
            // 读取缓存
            whenReadCache?(NetworkCacheManager.readCache(withURL: request, parameters: parameters!))
        }
        
        let task = sessionManager.post(request, parameters: parameters, progress: { (progress) in
            
        }, success: { (task, responseObject) in
            removeDataTask(task)
            whenSuccess?(responseObject)
            if isCache == true {
                // 对数据进行异步缓存
                NetworkCacheManager.writeCache(withData: responseObject as! NSCoding, url: request, parameters: parameters!)
            }
        }) { (task, error) in
            removeDataTask(task!)
            whenFailure?(error)
        }
        appendDataTask(task!)
        return task!
    }
    
    // MARK: - 上传多个文件
    class func uploadFiles(with request: String, parameters: Dictionary<String, Any>?, files: [NetworkFileModel], whenUpdateProgress: ProgressClosure?, whenSuccess: SuccessClosure?, whenFailure: FailureClosure?) -> URLSessionDataTask {
        
        let task = sessionManager.post(request, parameters: parameters, constructingBodyWith: { (formData: AFMultipartFormData) in
            for file in files {
                if let fileData = file.fileData {
                    formData.appendPart(withFileData: fileData, name: file.name, fileName: file.fileName, mimeType: file.mimeType)
                }
            }
        }, progress: { (progress) in
            DispatchQueue.main.async {
                whenUpdateProgress?(progress)
            }
        }, success: { (task, responseObject) in
            removeDataTask(task)
            whenSuccess?(responseObject)
        }) { (task, error) in
            removeDataTask(task!)
            whenFailure?(error)
        }
        appendDataTask(task!)
        return task!
    }
    
    // MARK: - 下载文件
    class func download(withURL url: String, fileDirectory: String, whenUpdateProgress: ProgressClosure?, whenSuccess: ((_ filePath: String) -> Void)?, whenFailure: FailureClosure?) -> URLSessionTask {
        
        let request = URLRequest.init(url: URL.init(string: url)!)
        
        var downloadTask: URLSessionDownloadTask!
        downloadTask = sessionManager.downloadTask(with: request, progress: { (progress) in
            DispatchQueue.main.async {
                whenUpdateProgress?(progress)
            }
        }, destination: { (url, response) -> URL in
            try! FileManager.default.createDirectory(atPath: fileDirectory, withIntermediateDirectories: true, attributes: nil)
            // 拼接文件路径
            let filePath = fileDirectory.appending(response.suggestedFilename!)
            // 返回文件位置的URL路径
            return URL.init(fileURLWithPath: filePath)
        }) { (response, url, error) in
            removeDataTask(downloadTask)
            if let fileUrl = url {
                whenSuccess?(fileUrl.path)
            }
            if error != nil {
                whenFailure?(error!)
            }
        }
        downloadTask.resume()
        appendDataTask(downloadTask)
        return downloadTask
    }
}

fileprivate extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     给DispatchQueue重新加上执行once的方法
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

