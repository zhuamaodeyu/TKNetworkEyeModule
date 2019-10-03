//
//  ViewController.swift
//  TKNetworkEyeModule
//
//  Created by zhuamaodeyu on 01/24/2019.
//  Copyright (c) 2019 zhuamaodeyu. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    fileprivate var button: UIButton!
    fileprivate var session: URLSession?
    override func viewDidLoad() {
        super.viewDidLoad()
        button = UIButton.init(type: .custom)
        button.setTitle("request ", for: .normal)
        button.frame = CGRect.init(x: 0, y: 100, width: view.bounds.width, height: 50)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.backgroundColor = UIColor.red
        view.addSubview(button)
    }
    
}

extension ViewController {
   @objc fileprivate func buttonAction() {
        // request
//    let param = "24A014CFACF85FFBE94739C5A9168B2ED56B1256A55F49A5E850DC73EDDA2E9493FE428E1BC1ED9B5B394E34FDB14905C9422216661EC300D86504865FE2487AE83E806159BC4AA7B9878AD0C530B630962EB4884E6B06078491454F89E2C9E257E2DBB5C19220C20EE55DE2B6B8E0C0CC966047FAA6F248E367E56196463CCC8E380A89F241BB15938B11F864BD16AB152F32E6041176216F221644F252FAB3991A0DA6917D677D11ABB0D9B3CA5BC8C90D8AD4787E5EDDFE2976965585C4839B443E14E79FD14697C829AC5A57C0F9C6E9F94C5CE6C6C3B789DEDB684CD12075BAD775CB9D4A633C0FF22BB7E462DD4D958486FC3B91E42A2DE6C98838E5A271B5EF6B1CD2048F45FE75D8DEF1A25C1C5D88244FAD08117EC34A30DD8C27E404215D993749B64254F5F5141EE8C783E69D7017328D1EA913C64CA87BAC46430703287584953B6DF22F0BEA63C5C51B"
    
//    let header = ["Content-Type":"application/x-www-form-urlencoded",
//                  "Cookie":"appver=1.5.10; os=osx; MUSIC_U=bd14081224faed4cafb7e904062766d2f9b5275b85ff59dfdcaa00502f8c9ad5cab95bf8155c0486100f8832a35ec71931b299d667364ed3; deviceId=E0E56F71-EA22-5A26-A936-8545E899059B%7C876667BF-EFF8-4D73-934F-B64DFB423BC8; __csrf=19d29bc29b8e937ec800125c5a2a69b8; channel=netease; __remember_me=true; osver=%E7%89%88%E6%9C%AC%2010.13.6%EF%BC%88%E7%89%88%E5%8F%B7%2017G65%EF%BC%89;"]
//
//    Alamofire.request("http://music.163.com/eapi/pl/count", method: .post, parameters: ["params":param], encoding: URLEncoding.default, headers: header).responseJSON { (response) in
//        debugPrint("response")
//        if let json = response.result.value {
//            debugPrint("json:\(json)")
//        }
//    }
        Alamofire.request("https://api.github.com/users/solomonxie").responseJSON { (response) in
            debugPrint("response")
            if let json = response.result.value {
                debugPrint("json:\(json)")
            }
        }
    }

}
