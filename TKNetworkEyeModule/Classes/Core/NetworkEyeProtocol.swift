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
    var eye_data: Data = Data.init()
    var eye_response: URLResponse?
    private var eye_queue: OperationQueue = OperationQueue.init()
    static var registered: Bool = false
    private var model: NetworkEyeModel = NetworkEyeModel()
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
        
        // init queue
        self.eye_queue.maxConcurrentOperationCount = 1
        self.eye_queue.name = "com.tknetworkeye.session.queue"
        
        self.startRequest(request: request)
        
        if #available(iOS 8.0, *) {
            // 高于 8.0
            self.eye_task = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil).dataTask(with: request)
            self.eye_task?.resume()
        }else {
            self.eye_connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
            self.eye_connection?.start()
        }
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
        // end
        self.endResponse(response: self.eye_response as? HTTPURLResponse)
        
        // save
        DBManager.sharedInstance.save(model: self.model)
    }
}
extension NetworkEyeProtocol {
    private func startRequest(request: URLRequest) {
        self.model.host = request.url?.host
        self.model.path = request.url?.path
        self.model.httpMethod = request.httpMethod
        self.model.debug = NetworkEyeManager.sharedInstance.config?.debug ?? false
        self.model.request_line_length = Int64(self.requestLineLen())
        self.model.request_header_length = Int64(self.requestHeadersLen())
        self.model.request_body_length = Int64(self.requestBodyLen())
        self.model.start_time = Date.init().timeIntervalSince1970
    }
    private func endResponse(response: HTTPURLResponse?) {
        self.model.response_body_length = Int64(self.responseBodyLen())
        self.model.response_line_length = Int64(self.responseStatusLineLen())
        self.model.response_header_length = Int64(self.responseHeaderLen())
        self.model.mime_type = response?.mimeType
        self.model.status_code = response?.statusCode  ?? 0
        self.model.end_time = Date.init().timeIntervalSince1970
        self.model.mime_type = response?.mimeType
        
        self.model.length = self.model.response_body_length +
            self.model.response_line_length +
            self.model.response_header_length +
            self.model.request_body_length +
            self.model.request_header_length +
            self.model.request_line_length
    }
    
    @available(iOS 10.0, *)
    func updateMetrics(_ taskMetrics:URLSessionTaskMetrics) {
        self.model.redirect_count = taskMetrics.redirectCount
        
        if let metric = taskMetrics.transactionMetrics.filter({ (m) -> Bool in
            m.request.url?.absoluteString == self.eye_request?.url?.absoluteString
        }).last {
            self.model.protocol_name = metric.networkProtocolName
            self.model.proxy_connection = metric.isProxyConnection
            self.model.dns_start_time = metric.domainLookupStartDate?.timeIntervalSince1970 ?? 0
            self.model.dns_end_time = metric.domainLookupEndDate?.timeIntervalSince1970 ?? 0
            self.model.tcp_start_time = metric.connectEndDate?.timeIntervalSince1970 ?? 0
            self.model.tcp_end_time = metric.connectEndDate?.timeIntervalSince1970 ?? 0
            self.model.request_start_time = metric.requestStartDate?.timeIntervalSince1970 ?? 0
            self.model.request_end_time = metric.requestEndDate?.timeIntervalSince1970 ?? 0
            self.model.response_start_time = metric.responseStartDate?.timeIntervalSince1970 ?? 0
            self.model.response_end_time = metric.responseEndDate?.timeIntervalSince1970 ?? 0
        }
    }
}

extension NetworkEyeProtocol {
    private func requestLineLen() -> Int {
        if let method = self.request.httpMethod, let path = self.request.url?.path {
            let string = NSString.init(format: "%@ %@ %@\n", method, path, "HTTP/1.1")
            return string.data(using: String.Encoding.utf8.rawValue)?.count ?? 0
        }
        return 0
    }
    
    private func requestHeadersLen() -> Int {
        var header = self.request.allHTTPHeaderFields ?? [:]
        
        for dic in self.cookie() {
            header.updateValue(dic.value, forKey: dic.key)
        }
        
        var headerString = ""
        for (key , value) in header {
            headerString.append("\(key)")
            headerString.append(": ")
            headerString.append("\(value)")
            headerString.append("\n")
        }
        return headerString.data(using: String.Encoding.utf8)?.count ?? 0
    }
    
    private func requestBodyLen() -> Int {
        var bodyLength = self.request.httpBody?.count ?? 0
        
        if self.request.allHTTPHeaderFields?.contains(where: { (key,value) -> Bool in
            key == "Accept-Encoding"
        }) ?? false  {
            var data: Data = Data.init()
            if let body =  self.request.httpBody  {
                data = body
            }else {
                if let stream = self.request.httpBodyStream{
                    stream.open()
                    let bufferSize = 1024
                    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                    while stream.hasBytesAvailable {
                        let read = stream.read(buffer, maxLength: bufferSize)
                        data.append(buffer, count: read)
                    }
                    buffer.deallocate()
                    defer {
                        stream.close()
                    }
                }
            }
            // 进行压缩
            bodyLength = data.zip().count
        }
        return bodyLength
    }
    
    private func requestLen() -> Int {
        return self.requestBodyLen() + self.requestLineLen() + self.requestHeadersLen()
    }
    private func cookie() -> [String: String] {
        if let cookies = HTTPCookieStorage.shared.cookies(for: self.request.url ?? URL.init(string: "")!) {
            return HTTPCookie.requestHeaderFields(with: cookies)
        }
        return [:]
    }
    
    /// response
    private func responseStatusLineLen() -> Int {
        return 0
    }
    
    private func responseHeaderLen() -> Int {
        
        if  let response = self.eye_response as? HTTPURLResponse {
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
        return 0
    }
    
    private func responseBodyLen() -> Int {
        if let response = self.eye_response as? HTTPURLResponse {
            if let encoding = response.allHeaderFields["Content-Encoding"] as? String, encoding == "gzip" {
                // 模拟gzip 压缩， 计算 self.eye_data
                return self.eye_data.zip().count
            }
        }else {
            return self.eye_data.count
        }
        return 0
    }
    
    private func responseLen() -> Int {
        return self.responseBodyLen() + self.responseHeaderLen() + self.responseStatusLineLen()
    }
}


