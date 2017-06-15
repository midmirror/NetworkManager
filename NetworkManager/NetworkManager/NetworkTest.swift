//
//  NetworkTest.swift
//  NetworkManager
//
//  Created by ios on 15/06/2017.
//  Copyright © 2017 mellow. All rights reserved.
//

import Foundation

class NetworkTest {
    
    class func get() {
        let url = "http://news-at.zhihu.com/api/4/news/latest"
        let _ = NetworkManager.get(withCache: true, request: url, parameters: nil, whenReadCache: { (cacheData) in
            print("cached Data:\(cacheData)")
        }, whenSuccess: { (responseObject) in
            print("response Data:\(responseObject)")
        }) { (error) in
            
        }
    }
    
    class func post() {
        
        let key = "your_app_key"
        let url = "your_post_url"
        
        let parameters: [String: Any] = [
            "lat": 118.10,
            "lon": 24.46,
            "appid": key
        ]
        let _ = NetworkManager.post(withCache: false, request: url, parameters: parameters, whenReadCache: { (cachedData) in
            
        }, whenSuccess: { (responseData) in
            print("weather data:\(responseData)")
        }) { (error) in
            print("weather error:\(error)")
        }
    }
    
    class func upload() {
        
        let key = "your_app_key"
        let url = "your_post_url"
        
        let parameters: [String: Any] = [
            "lat": 118.10,
            "lon": 24.46,
            "appid": key
        ]
        
        let zipFile = NetworkFileModel.init()
        zipFile.fileData = Data.init()  // you file data
        zipFile.name = "resourceFile"
        zipFile.mimeType = "application/zip"
        zipFile.fileName = "QQ.zip"     // your file name + extension
        
        let _ = NetworkManager.uploadFiles(with: url, parameters: parameters, files: [zipFile], whenUpdateProgress: { (progress) in
            
        }, whenSuccess: { (response) in
            
        }) { (error) in
            
        }
    }
    
    class func download() {
        let url = "http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4"
        let _ = NetworkManager.download(withURL: url, fileDirectory: NSHomeDirectory() + "Documents", whenUpdateProgress: { (progress) in
            let status = 100 * progress.completedUnitCount/progress.totalUnitCount
            print("download progress:\(status)")
        }, whenSuccess: { (filePath) in
            print("download success:\(filePath)")
        }) { (error) in
            print("download error:\(error)")
        }
    }
}
