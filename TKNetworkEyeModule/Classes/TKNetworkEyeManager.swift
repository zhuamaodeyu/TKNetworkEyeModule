//
//  TKNetworkEyeManager.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/1/24.
//

import Foundation


public class TKNetworkEyeManager {
    public static let sharedInstance = TKNetworkEyeManager()
    fileprivate let db = DBManager.sharedInstance
    fileprivate var thread:Thread?
    private init() {
        thread = Thread(target: self, selector: #selector(threadEntryPoint), object: nil)
        thread?.start()
    }
    
    /// 注册
    public func register() {
        self.createDB()
        self.createTable()
    }
}

extension TKNetworkEyeManager {
    @objc fileprivate func threadEntryPoint() {
        autoreleasepool{
            Thread.current.name = "TKNetworkEyeManager"
            let runloop = RunLoop.current
            runloop.add(NSMachPort.port(withMachPort: 25532), forMode: RunLoopMode.commonModes)
            runloop.run()
        }
    }
}


extension TKNetworkEyeManager {
    // 创建数据库
    fileprivate func createDB() {
        db.createDb()
    }
    
    /// 创建数据库表
    fileprivate func createTable() {
        db.createTable()
    }
}
