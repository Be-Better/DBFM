//
//  DBFMSongController.swift
//  DBFM
//
//  Created by chen on 15/11/29.
//  Copyright © 2015年 chen. All rights reserved.
//

import WatchKit
import Foundation


class DBFMSongController: WKInterfaceController {

    
    @IBOutlet var table: WKInterfaceTable!
    
    //声明代理
    var delegage: SongProtocol?
    //引用数据中心的单例
    var data: DBData = DBData.instance
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        self.delegage = context as? SongProtocol
        
        table.setNumberOfRows(data.songs.count, withRowType: "songRow")
        for (index, json) in data.songs.enumerate() {
            let row = table.rowControllerAtIndex(index) as! DBFMSongRow
            let title = json["title"].stringValue
            let artist = json["artist"].stringValue
            
            let imagUrl = json["picture"].stringValue
            
            data.onSetImage(imagUrl, imag:row.titleImage)
            row.titleLabel.setText(title)
            row.detilLabel.setText(artist)
        }
        
    }
    //点击具体某一首歌的时候，返回主视图，并让当前视图消失
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        delegage?.onChangeSong(rowIndex)
        self.dismissController()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

protocol SongProtocol {
    //将歌曲索引返回
    func onChangeSong(index: Int)
}
