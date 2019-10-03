//
//  NetworkEyeManager.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/1/24.
//

import Foundation


/// Network Eye Manager
public class NetworkEyeManager {

    /// 单利
    public static let sharedInstance = NetworkEyeManager()
    private(set) var config: NetworkEyeConfig?
    private init() {
      _ = DBManager.sharedInstance.connection()
        clearData()
    }
}

extension NetworkEyeManager {

    /// register
    ///
    /// - Parameter config: 配置对象
    /// - SeeAlso:
    ///     NetworkEyeConfig 类介绍 
    public func register(_ config: NetworkEyeConfig?) {
        self.config = config
    }
}

extension NetworkEyeManager {
    private func clearData() {
        DBManager.sharedInstance.removeData(for: self.config?.strategyType ?? .restart)
    }
}
