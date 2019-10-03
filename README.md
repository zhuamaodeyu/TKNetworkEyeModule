# TKNetworkEyeModule

[![CI Status](https://img.shields.io/travis/zhuamaodeyu/TKNetworkEyeModule.svg?style=flat)](https://travis-ci.org/zhuamaodeyu/TKNetworkEyeModule)
[![Version](https://img.shields.io/cocoapods/v/TKNetworkEyeModule.svg?style=flat)](https://cocoapods.org/pods/TKNetworkEyeModule)
[![License](https://img.shields.io/cocoapods/l/TKNetworkEyeModule.svg?style=flat)](https://cocoapods.org/pods/TKNetworkEyeModule)
[![Platform](https://img.shields.io/cocoapods/p/TKNetworkEyeModule.svg?style=flat)](https://cocoapods.org/pods/TKNetworkEyeModule)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TKNetworkEyeModule is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TKNetworkEyeModule'
```

## Example 
1. register Network Eye Service 
	
	```
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // register 
        // you can new config object
        NetworkEyeManager.sharedInstance.register(nil)
        return true
    }	
	```

Now,you can see all network request from sandBox `TKNetworkEye.sqlite3` file 

##### Note 
this pod is not support `UIWebView/WKWebView` request.

## Author

zhuamaodeyu, playtomandjerry@gmail.com

## License

TKNetworkEyeModule is available under the MIT license. See the LICENSE file for more info.
