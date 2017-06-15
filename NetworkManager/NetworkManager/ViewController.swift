//
//  ViewController.swift
//  NetworkManager
//
//  Created by ios on 15/06/2017.
//  Copyright © 2017 mellow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkTest.get()
//        NetworkTest.post()      // use your url
//        NetworkTest.upload()    // use your url and file
        NetworkTest.download()
        
        print("网络缓存大小cache = \(NetworkCacheManager.cacheSize()/1024)KB")
        monitorNetworkStatus()
    }
    
    func monitorNetworkStatus() {
        NetworkManager.networkStatus { (status) in
            switch status {
            case .unknown: break;
            case .notReachable:
                print("无网络，加载缓存数据")
                break;
            case .reachableViaWiFi:
                print("有网络，请求网络数据")
                break;
            case .reachableViaWWAN: break;
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

