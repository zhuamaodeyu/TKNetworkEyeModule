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
        DBManager.sharedInstance.save(model: conversionModel(requestType: .request))
        return request
    }
    func connection(_ connection: NSURLConnection, didReceive data: Data){
        self.client?.urlProtocol(self, didLoad: data)
        if let data = self.eys_data {
            self.eys_data?.append(data)
        }else {
            self.eys_data = data
        }
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
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let err = error {
            self.client?.urlProtocol(self, didFailWithError: err)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.eye_response = response
        self.client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    }
    
    @available(iOS 10.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        
    }
}
