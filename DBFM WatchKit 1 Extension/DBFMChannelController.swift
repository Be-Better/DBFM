//
//  DBFMChannelController.swift
//  DBFM
//
//  Created by chen on 15/11/28.
//  Copyright © 2015年 chen. All rights reserved.
//

import WatchKit
import Foundation


class DBFMChannelController: WKInterfaceController {

    //声明代理
    var delegate:ChannelProtol?
    @IBOutlet var table: WKInterfaceTable!
    //数据中心单例
    var data:DBData = DBData.instance
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        self.delegate = context as? ChannelProtol
        
        table.setNumberOfRows(data.channels.count, withRowType: "channelRow")
        for (index, json) in data.channels.enumerate(){
            let row = table.rowControllerAtIndex(index) as! DBFMChannelRow
            var title = json["name"].stringValue
            row.titleLabel.setText(title)
        }
        
    }
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let channelId = data.channels[rowIndex]["channel_id"].stringValue
        delegate?.onChangeChannel(channelId)
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

protocol ChannelProtol{
    //定义回调方法，将频道id传回主视图
    func onChangeChannel(channel_id: String)
}
