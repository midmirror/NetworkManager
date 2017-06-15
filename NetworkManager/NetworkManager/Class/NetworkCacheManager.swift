//
//  NetworkCacheManager.swift
//
//  Created by midmirror on 2017/3/13.
//  Copyright © 2017年 midmirror. All rights reserved.
//

import Foundation

open class NetworkCacheManager: NSObject {
    
    static let NetworkResponseCache = "NetworkResponseCache"
    static var dataCache: YYCache!
    
    open override class func initialize() {
        dataCache = YYCache.init(name: NetworkResponseCache)
    }
    
    
    /// 异步缓存网络数据,根据请求的 URL与parameters，做KEY存储数据, 缓存多级页面的数据
    ///
    /// - parameter data:       服务器返回的数据
    /// - parameter url:        请求的URL地址
    /// - parameter parameters: 请求的参数
    open class func writeCache(withData data: NSCoding, url: String, parameters: Dictionary<String, Any>?) {
        
        let cacheKey = self.cacheKey(withURL: url, parameters: parameters)
        dataCache.setObject(data, forKey: cacheKey)
    }
    
    
    /// 根据请求的 URL与parameters 取出缓存数据
    ///
    /// - parameter url:        请求的URL地址
    /// - parameter parameters: 请求的参数
    ///
    /// - returns: 缓存的服务器数据
    open class func readCache(withURL url: String, parameters: Dictionary<String, Any>?) -> NSCoding? {
        let cacheKey = self.cacheKey(withURL: url, parameters: parameters)
        return dataCache.object(forKey: cacheKey)
    }
    
    
    /// 根据请求的 URL与parameters 异步取出缓存数据
    ///
    /// - parameter url:          请求的URL地址
    /// - parameter parameters:   请求的参数
    /// - parameter withClosoure: 异步回调缓存的数据
    open class func readCache(withURL url: String, parameters: Dictionary<String, Any>, withClosoure: @escaping (_ object: NSCoding) -> Void) {
        
        let cacheKey = self.cacheKey(withURL: url, parameters: parameters)
        dataCache.object(forKey: cacheKey) { (key: String, object: NSCoding) in
            DispatchQueue.main.async {
                withClosoure(object)
            }
        }
    }
    
    open class func cacheKey(withURL url: String, parameters: Dictionary<String, Any>?) -> String {
        
        var cacheKey: String?
        if parameters != nil {
            let stringData = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            let paraString = String.init(data: stringData, encoding: String.Encoding.utf8)
            cacheKey = url+paraString!
        } else {
            cacheKey = url
        }
        
        return cacheKey!
    }
    
    
    /// 获取网络缓存的总大小
    ///
    /// - returns: 总大小 bytes(字节)
    open class func cacheSize() -> Int {
        return dataCache.diskCache.totalCost()
    }
    
    
    /// 删除所有网络缓存
    open class func removeAllCache() {
        return dataCache.diskCache.removeAllObjects()
    }
}
