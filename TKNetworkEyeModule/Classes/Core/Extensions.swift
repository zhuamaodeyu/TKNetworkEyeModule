//
//  Extensions.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/3/5.
//

import Foundation
import Gzip

extension Data {
    public func zip() -> Data {
        if self.count <= 0 {
            return self
        }
        do {
            let data = try self.gzipped()
            return data
        } catch let error {
            print("\(error)")
        }
        return self
    }
}
