//
//  Models.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/2/3.
//

import Foundation

struct NetworkEyeModel {
    // 自增
    var id: Int64?
    // host
    var host: String?
    // debug 模式
    var debug: Bool = false
    // path
    var path: String?
    // 总长度
    var length: Int64 = 0
    // 请求方式
    var httpMethod: String? = ""
    // Line 字节数
    var request_line_length: Int64 = 0
    // Header 字节数
    var request_header_length: Int64 = 0
    // Body 字节数
    var request_body_length: Int64 = 0
    // Line 字节数
    var response_line_length: Int64 = 0
    // Header 字节数
    var response_header_length: Int64 = 0
    // Body 字节数
    var response_body_length: Int64 = 0
    //mime 类型
    var mime_type: String?
    // 状态码
    var status_code:Int = 0
    //  任务 开始时间
    var start_time: TimeInterval = 0
    // 结束时间
    var end_time: TimeInterval = 0
    // metrics 指标
    var redirect_count: Int = 0
    // 网络协议
    var protocol_name: String?
    // 是否使用代理
    var proxy_connection: Bool = false
    // dns 开始时间 domainLookupEndDate
    var dns_start_time: TimeInterval = 0
    // dns 结束时间
    var dns_end_time: TimeInterval = 0
    // connectStartDate
    var tcp_start_time: TimeInterval = 0
    
    var tcp_end_time: TimeInterval = 0
    
    var request_start_time:TimeInterval = 0
    
    var request_end_time: TimeInterval = 0
    
    var response_start_time:TimeInterval = 0
    
    var response_end_time: TimeInterval = 0
    // 是否已经上传
    var is_upload: Bool = false
}

public enum CleanupStrategyType {
    case restart
    case oneDay
    case oneWeek
    case oneMonth
    case never
    // 没有上传的
    case notUpload
}

public struct NetworkEyeConfig {
    var hosts:[String] = []
    var debug: Bool = false
    var strategyType: CleanupStrategyType = .restart
}
