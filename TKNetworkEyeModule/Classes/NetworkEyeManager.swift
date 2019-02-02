//
//  NetworkEyeManager.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/1/24.
//

import Foundation


public class NetworkEyeManager {
    public static let sharedInstance = NetworkEyeManager()
    private init() {
      _ = DBManager.sharedInstance
    }
    /// 注册
    public func register() {
        
    }
}

extension NetworkEyeManager {
    
}




//        thread = Thread(target: self, selector: #selector(threadEntryPoint), object: nil)
//        thread?.start()
//        autoreleasepool{
//            Thread.current.name = "NetworkEyeManager"
//            let runloop = RunLoop.current
//            runloop.add(NSMachPort.port(withMachPort: 25532), forMode: RunLoopMode.commonModes)
//            runloop.run()
//        }
