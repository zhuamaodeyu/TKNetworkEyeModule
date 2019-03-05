//
//  DBManager.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/1/24.
//

import Foundation

import Foundation
import SQLite


let id = Expression<Int64>("id")
let host = Expression<String?>("host")
let debug = Expression<Bool>("debug")
let path = Expression<String?>("path")
let length = Expression<Int64>("length")
let httpMethod = Expression<String?>("method")
let requestLineLength = Expression<Int64>("request_line_length")
let requestHeaderLength = Expression<Int64>("request_header_length")
let requestBodyLength = Expression<Int64>("request_body_length")
let responseLineLength = Expression<Int64>("response_line_length")
let responseHeaderLength = Expression<Int64>("response_header_length")
let responseBodyLength = Expression<Int64>("response_body_length")
let mimeType = Expression<String?>("mime_type")
let statusCode = Expression<Int>("status_code")
let startTime = Expression<TimeInterval>("start_time")
let endTime = Expression<TimeInterval>("end_time")
let redirectCount = Expression<Int>("endTime")
let protocolName = Expression<String?>("protocol_name")
let proxyConnection = Expression<Bool>("proxy_connection")
let dnsStartTime = Expression<TimeInterval>("dns_start_time")
let dnsEndTime = Expression<TimeInterval>("dns_end_time")
let tcpStartTime = Expression<TimeInterval>("tcp_start_time")
let tcpEndTime = Expression<TimeInterval>("tcp_end_time")
let requestStartTime = Expression<TimeInterval>("request_start_time")
let requestEndTime = Expression<TimeInterval>("request_end_time")
let responseStartTime = Expression<TimeInterval>("response_start_time")
let responseEndTime = Expression<TimeInterval>("response_end_time")
let isUpload = Expression<Bool>("is_upload")


class DBManager: NSObject {
    static let sharedInstance = DBManager()
    private var db: Connection?
    private var thread: Thread?
    private var table: Table?
    private var queue:[NetworkEyeModel] = []
    private var column:[String:Any] = [String:Any]()
    
    private override init() {
        super.init()
        initConnection()
        initTable()
        initThread()
    }
}

extension DBManager {
    private func initConnection(){
        self.db = try? Connection("\(DBManager.dbPath())/TKNetworkEye.sqlite3")
        self.db?.busyTimeout = 5
        self.db?.busyHandler({ (tries) -> Bool in
            if tries >= 3{
                return false
            }
            return true
        })
    }
    
    private func initTable() {
        self.table = Table("t_table")
        _ = try? db?.run(table?.create(block: { (b ) in
            b.column(id, primaryKey: PrimaryKey.autoincrement)
            b.column(host)
            b.column(debug)
            b.column(path)
            b.column(length)
            b.column(httpMethod)
            b.column(requestLineLength)
            b.column(requestHeaderLength)
            b.column(requestBodyLength)
            b.column(responseLineLength)
            b.column(responseHeaderLength)
            b.column(responseBodyLength)
            b.column(mimeType)
            b.column(statusCode)
            b.column(startTime)
            b.column(endTime)
            b.column(redirectCount)
            b.column(protocolName)
            b.column(proxyConnection)
            b.column(dnsStartTime)
            b.column(dnsEndTime)
            b.column(tcpStartTime)
            b.column(tcpEndTime)
            b.column(requestStartTime)
            b.column(requestEndTime)
            b.column(responseStartTime)
            b.column(responseEndTime)
            b.column(isUpload)
        }) ?? "")
    }
    
    private func initThread() {
        self.thread = Thread.init(target: self, selector: #selector(startRunloop), object: nil)
        self.thread?.name = "update_db_eye"
        self.thread?.start()
    }
}


// MARK: - Action
extension DBManager {
    @objc private func startRunloop() {
        autoreleasepool {
            let runloop = RunLoop.current
            runloop.add(NSMachPort.init(), forMode: .commonModes)
            runloop.run()
        }
    }
    
    @objc private func threadAction() {
        while queue.count > 0 {
            do {
                if let db = self.db,let table = self.table,let model = queue.first {
                   try db.run(table.insert(
                        host <- model.host,
                        debug <- model.debug,
                        path <- model.path,
                        length <- model.length,
                        httpMethod <- model.httpMethod,
                        requestLineLength <- model.request_line_length,
                        requestHeaderLength <- model.request_header_length,
                        requestBodyLength <- model.request_body_length,
                        responseLineLength <- model.response_line_length,
                        responseHeaderLength <- model.response_header_length,
                        responseBodyLength <- model.response_body_length,
                        mimeType <- model.mime_type,
                        statusCode <- model.status_code,
                        startTime <- model.start_time,
                        endTime <- model.end_time,
                        redirectCount <- model.redirect_count,
                        protocolName <- model.protocol_name,
                        proxyConnection <- model.proxy_connection,
                        dnsStartTime <- model.dns_start_time,
                        dnsEndTime <- model.dns_end_time,
                        tcpStartTime <- model.tcp_start_time,
                        tcpEndTime <- model.tcp_end_time,
                        requestStartTime <- model.request_start_time,
                        requestEndTime <- model.request_end_time,
                        responseStartTime <- model.response_start_time,
                        responseEndTime <- model.response_end_time,
                        isUpload <- model.is_upload
                    ))
                    queue.removeFirst()
                }else {
                    queue.removeAll()
                }
            }catch let error{
                print("insert id: \(error)")
            }
        }
    }
    
}


// MARK: - Other
extension DBManager {
    private static func dbPath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        return path ?? ""
    }
}


extension DBManager {
    /// 清除7前的数据
    func removeSevenDaysBefore() {
        
    }
}

extension DBManager {
    func save(model: NetworkEyeModel) {
        self.queue.append(model)
        if let t = self.thread {
            self.perform(#selector(threadAction), on: t, with: nil, waitUntilDone: false)
        }
    }
}
