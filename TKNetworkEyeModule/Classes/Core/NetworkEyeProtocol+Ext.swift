//
//  TKRunloop.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/1/24.
//

import Foundation

//发送请求到密码验证阶段
extension NetworkEyeProtocol: NSURLConnectionDelegate {
    // 失败
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        self.client?.urlProtocol(self, didFailWithError: error)
    }
    
    func connectionShouldUseCredentialStorage(_ connection: NSURLConnection) -> Bool {
        return true
    }
    
    func connection(_ connection: NSURLConnection, didReceive challenge: URLAuthenticationChallenge) {
        self.client?.urlProtocol(self, didReceive: challenge)
    }
    
    func connection(_ connection: NSURLConnection, didCancel challenge: URLAuthenticationChallenge) {
        self.client?.urlProtocol(self, didCancel: challenge)
    }
}

extension NetworkEyeProtocol: NSURLConnectionDataDelegate {
    func connection(_ connection: NSURLConnection, willSend request: URLRequest, redirectResponse response: URLResponse?) -> URLRequest?{
        if let res = response  {
            self.client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: res)
        }
        return request
    }
    func connection(_ connection: NSURLConnection, didReceive data: Data){
        self.client?.urlProtocol(self, didLoad: data)
        self.eye_data.append(data)
    }
    // 成功
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.allowed)
        self.eye_response = response
    }
    
    func connection(_ connection: NSURLConnection, needNewBodyStream request: URLRequest) -> InputStream?{
        return request.httpBodyStream
    }
    func connection(_ connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int){
        
    }
    func connection(_ connection: NSURLConnection, willCacheResponse cachedResponse: CachedURLResponse) -> CachedURLResponse?{
        return cachedResponse
    }
    func connectionDidFinishLoading(_ connection: NSURLConnection){
        self.client?.urlProtocolDidFinishLoading(self)
    }
}

extension NetworkEyeProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        self.eye_response = response
        completionHandler(.allow)
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
        self.eye_data.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let err = error {
            self.client?.urlProtocol(self, didFailWithError: err)
        }
        self.client?.urlProtocolDidFinishLoading(self)
        self.eye_task = nil
    }
    
    // 如果当前请求需要重定向请求， 会调用此方法， 会生成一个新的 request 进行请求
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.eye_response = response
        self.client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    }
    @available(iOS 10.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        //        transactionMetrics 数组包含了在执行任务时产生的每个请求/响应事务中收集的指标。
        //        taskInterval:任务从创建到完成花费的总时间，任务的创建时间是任务被实例化时的时间；任务完成时间是任务的内部状态将要变为完成的时间。
        //        redirectCount:记录了被重定向的次数。
        //        networkProtocolName:获取资源时使用的网络协议，由 ALPN 协商后标识的协议，比如 h2, http/1.1, spdy/3.1。
        //        isProxyConnection:是否使用代理进行网络连接。
        //        isReusedConnection:是否复用已有连接。
        //        resourceFetchType:NSURLSessionTaskMetricsResourceFetchType 枚举类型，标识资源是通过网络加载，服务器推送还是本地缓存获取的。
        //此处会在缓存 didReceive 方法中调用一次
        self.updateMetrics(metrics)
    }
}
