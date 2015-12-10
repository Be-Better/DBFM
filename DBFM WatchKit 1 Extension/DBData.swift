//
//  DBData.swift
//  DBFM
//
//  Created by chen on 15/11/28.
//  Copyright © 2015年 chen. All rights reserved.
//

import Foundation
import SwiftyJSON
import WatchKit
import Alamofire

class DBData {
    internal static let instance: DBData = {
        return DBData()
    }()
    
    //存放歌曲数据
    var songs = [JSON]()
    //存放歌曲列表数组
    var channels = [JSON]()
    
    //声明字典, 实现图像缓存
    var imageCache = Dictionary<String, UIImage>()
    
    //缓存策略，显示图像，iPhone端
    func onSetImage2(url: String, imag: WKInterfaceImage) {
        //通过url去缓存查找有没有缓存过的图像
        let image = self.imageCache[url] as UIImage?
        
        if image == nil {
            //如果缓存中没有此图片，就从网络获取
            Alamofire.request(.GET, url).responseData({ (Response) -> Void in
                //完成网络请求,将获取到的图像赋予imageview
                let imagData = UIImage(data:Response.result.value! )
                imag.setImage(imagData)
                self.imageCache[url] = imagData
            })
        } else {
            //如果缓存中有，就直接用
            imag.setImage(image)
        }
    }
    //watch端缓存图像策略
    func onSetImage(url: String, imag: WKInterfaceImage){
        let device = WKInterfaceDevice.currentDevice()
        let nsUrl = NSURL(string: url)?.lastPathComponent
        //获取图像文件名，。。jpg
        let imageName = nsUrl
        
        if cacheContainsImageNamed(imageName!) == true {
            imag.setImageNamed(imageName)
        } else {
            Alamofire.request(.GET, url).response{
                request, response, data, error in
                if error == nil {
                    //将获取的图像赋予img
                    let image = UIImage(data: data! as NSData)
                    self.addImageToCache(image!, name: imageName!)
                    imag.setImageNamed(imageName)
                }
            }
        
        }
    }
    //根据图像名称，来判断缓存中是否有图像
    func cacheContainsImageNamed(name: String) -> Bool {
        
        return cachedImages.keys.contains(name)
    }
    //有图像加入缓存，以图像名称为key，图像数据位value
    func addImageToCache(imag: UIImage, name: String) {
        //获取当前设备
        let device = WKInterfaceDevice.currentDevice()
        //假设加入缓存不成功，清除缓存中第一个元素，如果一直不成功，就清空所有缓存，并强行插入
        while (device.addCachedImage(imag, name: name) == false) {
            let removedImage = removeRandomImageFromCache()
            if !removedImage {
                device.removeAllCachedImages()
                device.addCachedImage(imag, name: name)
                break
            }
        }
    }
    //删除图像缓存的方法
    func removeRandomImageFromCache() -> Bool {
        let cachedImageNames = cachedImages.keys
        //找出集合的第一个元素，从缓存中清除掉
        if let randomImageName = cachedImageNames.first {
            WKInterfaceDevice.currentDevice().removeCachedImageWithName(randomImageName)
            return true
        }
        return false
    }
    var cachedImages:[String:NSNumber] = {
        return WKInterfaceDevice.currentDevice().cachedImages 
    }()
}