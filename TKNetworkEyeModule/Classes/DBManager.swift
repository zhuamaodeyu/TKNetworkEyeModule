//
//  DBManager.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/1/24.
//

import Foundation

import Foundation
import SQLite

struct DBModel {
    enum RequestType:Int {
        case request =  0
        case response =  1
    }
    var id: Int64
    var host: String
    var path: String
    var length: Int64
    var lineLength: Int64
    var headerLength: Int64
    var bodyLength: Int64
    var type: RequestType
    var startTime: Int64
    var endTime: Int64?
}

class DBManager {
    static let sharedInstance = DBManager()
    fileprivate var db: Connection?
    private init() {
        createDb()
    }
}

extension DBManager {
    
    func createDb(){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if path == nil  {
            return
        }
        self.db = try? Connection("\(path!)/tkNetworkEye.sqlite3")
        self.db?.busyTimeout = 5
        self.db?.busyHandler({ (tries) -> Bool in
            if tries >= 3{
                return false
            }
            return true
        })
    }
    
    func createTable() {
        let id = Expression<Int64>("id")
        let host = Expression<String>("host")
        let path = Expression<String>("path")
        let length = Expression<Int64>("length")
        let lineLength = Expression<Int64>("lineLength")
        let headerLength = Expression<Int64>("headerLength")
        let bodyLength = Expression<Int64>("bodyLength")
        let type = Expression<Int>("type")
        let startTime = Expression<Int64>("startTime")
        let endTime = Expression<Int64?>("endTime")
        
        let table = Table("t_table")
        _ = try? db?.run(table.create(block: { (b ) in
            b.column(id, primaryKey: true)
            b.column(host)
            b.column(path)
            b.column(length)
            b.column(lineLength)
            b.column(headerLength)
            b.column(bodyLength)
            b.column(type)
            b.column(startTime)
            b.column(endTime)
        }))
    }
    
    func selectAll() {
        
    }
    
    func select(sql: String) {
        
    }
}

extension DBManager {
    
    
    /// 清除7前的数据
    func removeSevenDaysBefore() {
        
    }
}
