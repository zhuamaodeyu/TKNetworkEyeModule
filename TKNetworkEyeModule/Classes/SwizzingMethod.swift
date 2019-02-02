//
//  SwizzingMethod.swift
//  TKNetworkEyeModule
//
//  Created by 聂子 on 2019/2/3.
//

import Foundation


protocol NetworkEyeSwizzingMethod : class{
    static func swizzing()
}
class NetworkEyeNotingToSwizzingMethod {
    static func sendMessage() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        for index  in 0 ..< typeCount {
            (types[index] as? NetworkEyeSwizzingMethod.Type)?.swizzing()
        }
        types.deallocate()
    }
}
extension UIApplication {
    private static let mockOne: Void = {
        NetworkEyeNotingToSwizzingMethod.sendMessage()
        NetworkEyeProtocol.register()
    }()
    open override var next: UIResponder? {
        UIApplication.mockOne
        return super.next
    }
}

extension URLSession: NetworkEyeSwizzingMethod {
    static func swizzing() {
        URLSession.mockClassInit()
    }
    static func mockClassInit() {
        mockSwizzleMethod
    }
    private static let mockSwizzleMethod: Void = {
        let originalSelector = Selector(("initWithConfiguration:delegate:delegateQueue:"))
        let swizzleSelector = #selector(URLSession.init(configuration_mock:delegate:delegateQueue:))
        swizzlingForClass(URLSession.self, originalSelector: originalSelector, swizzledSelector: swizzleSelector)
    }()
    @objc convenience init(configuration_mock: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) {
        if configuration_mock.protocolClasses != nil {
            configuration_mock.protocolClasses?.insert(NetworkEyeProtocol.classForCoder(), at: 0)
        }else {
            configuration_mock.protocolClasses = [NetworkEyeProtocol.classForCoder()]
        }
        self.init(configuration_mock: configuration_mock, delegate: delegate, delegateQueue: queue)
    }
}


func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    let originalMethod = class_getInstanceMethod(forClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
    
    guard (originalMethod != nil && swizzledMethod != nil) else {
        return
    }
    if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
        class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    } else {
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}
