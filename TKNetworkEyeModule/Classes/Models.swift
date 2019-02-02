//
//  Models.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/2/3.
//

import Foundation

struct NetworkLogModel {
    enum RequestType:Int {
        case request =  0
        case response =  1
    }
    var id: Int64?
    var request_id:Int64?
    var response_id:Int64?
    var host: String?
    var debug: Bool?
    var path: String?
    var length: Int64?
    var line_length: Int64?
    var header_length: Int64?
    var body_length: Int64?
    var type: RequestType?
    var mime_type: String?
    var status_code:Int?
    var end_time: TimeInterval?
    var is_upload: Bool = false
}
