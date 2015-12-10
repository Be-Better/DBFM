//
//  HttpController.swift
//  DBFM
//
//  Created by chen on 15/11/28.
//  Copyright © 2015年 chen. All rights reserved.
//

import Alamofire
import UIKit

class HttpController: NSObject {
    //定义一个代理
    var delegate:HttpProtocol?
    //定义一个方法,接收网址，请求数据,回调代理的方法，传回数据
    func onSearch(url:String) {
        Alamofire.request(.GET, url).responseJSON{
            response in
            self.delegate?.didRecieveResults(response.result.value!)
        }
    }
}

//定义http协议
protocol HttpProtocol {
    
    //定义一个方法，接收一个参数：AnyObject
    func didRecieveResults(results:AnyObject)
}
