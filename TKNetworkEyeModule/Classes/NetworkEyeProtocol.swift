//
//  NetworkEyeProtocol.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/1/24.
//

import Foundation
let kEyeKey = "tk_notwork_eye"
class NetworkEyeProtocol : URLProtocol {
    var eye_connection: NSURLConnection?
    var eye_request: URLRequest?
    var eye_task: URLSessionDataTask?
    var eys_data: Data?
    var eye_response: URLResponse?
    var requestId: Int64?
    static var registered: Bool = false
}

extension NetworkEyeProtocol {
    static func register()  {
        if registered {
            return
        }
        URLProtocol.registerClass(self.classForCoder())
        registered = true
    }
    static func  unRegister()  {
        if !registered {
            return
        }
        URLProtocol.unregisterClass(self.classForCoder())
        registered = false
    }
}

extension NetworkEyeProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme else {
            return false
        }
        guard scheme == "http" || scheme == "https" else {
            return false
        }
        guard URLProtocol.property(forKey: kEyeKey, in: request) == nil  else {
            return false
        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        guard let req = (request as? NSMutableURLRequest)?.mutableCopy() as? NSMutableURLRequest else {
            return request
        }
        URLProtocol.setProperty(true, forKey: kEyeKey, in: req) 
        return req.copy() as! URLRequest
    }
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
    override func startLoading() {
        // request
        let request = self.classForCoder.canonicalRequest(for: self.request)
        self.eye_request = request
        
        if #available(iOS 8.0, *) {
            // 高于 8.0
            self.eye_task = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil).dataTask(with: request)
            self.eye_task?.resume()
        }else {
            self.eye_connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
            self.eye_connection?.start()
        }
        // 初始化属性
        initProterty()
    }
    override func stopLoading() {
        if self.eye_connection != nil {
            self.eye_connection?.cancel()
            self.eye_connection = nil
        }
        if self.eye_task != nil  {
            self.eye_task?.cancel()
            self.eye_task = nil
        }
        // save
        DBManager.sharedInstance.save(model: conversionModel(requestType: .response))
    }
    
    
    private func initProterty() {
        self.requestId = Int64(Date().timeIntervalSince1970)
    }
    
}
//var id: Int64?
//var request_id:Int64?
//var response_id:Int64?
//var host: String?
//var debug: Bool?
//var path: String?
//var length: Int64?
//var line_length: Int64?
//var header_length: Int64?
//var body_length: Int64?
//var type: RequestType?
//var mime_type: String?
//var status_code:Int?
//var end_time: Int64?
//var is_upload: Bool = false
extension NetworkEyeProtocol {
    func conversionModel(requestType: NetworkLogModel.RequestType) -> NetworkLogModel {
        var model = NetworkLogModel()
        if requestType == .request {
            model.request_id = self.requestId
        }else {
            model.response_id = Int64(Date().timeIntervalSince1970)
            model.request_id = self.requestId
            model.mime_type = self.eye_response?.mimeType
            model.status_code = (self.eye_response as? HTTPURLResponse)?.statusCode
        }
        model.host = self.eye_request?.url?.host ?? ""
        model.path = self.eye_request?.url?.path ?? ""
        model.length = 0
        model.line_length = 0
        model.header_length = 0
        model.body_length = 0
        model.type = requestType
        model.end_time = Date.init().timeIntervalSince1970
        return model
    }
}

extension NetworkEyeProtocol {
    fileprivate func requestLineLen() -> Int {
        if let method = self.request.httpMethod, let path = self.request.url?.path {
             let string = NSString.init(format: "%@ %@ %@\n", method, path, "HTTP/1.1")
            return string.data(using: String.Encoding.utf8.rawValue)?.count ?? 0
        }
        return 0
    }
    
    fileprivate func requestHeadersLen() -> Int {
        let header = self.request.allHTTPHeaderFields ?? [:]
        var headerString = ""
        for (key , value ) in header {
            headerString.append("\(key)")
            headerString.append(": ")
            headerString.append("\(value)")
            headerString.append("\n")
        }
        return headerString.data(using: String.Encoding.utf8)?.count ?? 0
    }
    fileprivate func requestBodyLen() -> Int {
        return 0
    }
    fileprivate func responseBodyLen() -> Int {
        return 0
    }
    
    fileprivate func cookieLen() -> Int {
        
        return 0
    }
    
    fileprivate func cookie() -> [String: String] {
        if let cookies = HTTPCookieStorage.shared.cookies(for: self.request.url ?? URL.init(string: "")!) {
            return HTTPCookie.requestHeaderFields(with: cookies)
        }
        return [:]
    }
    fileprivate func responseLineLen() -> Int {
        return 0
    }
    fileprivate func responseHeaderLen() -> Int {
        guard let response = self.eye_response as? HTTPURLResponse else {
            return 0
        }
        let header = response.allHeaderFields
        var headerString = ""
        for (key , value ) in header {
            headerString.append("\(key)")
            headerString.append(": ")
            headerString.append("\(value)")
            headerString.append("\n")
        }
        return headerString.data(using: String.Encoding.utf8)?.count ?? 0
    }
    
    fileprivate func responseLen() -> Int {
        return 0
    }
}


