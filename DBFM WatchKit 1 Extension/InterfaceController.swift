//
//  InterfaceController.swift
//  DBFM WatchKit 1 Extension
//
//  Created by chen on 15/11/26.
//  Copyright © 2015年 chen. All rights reserved.
//
import WatchKit
import Foundation
import SwiftyJSON
import AVKit
import AVFoundation

class InterfaceController: WKInterfaceController, HttpProtocol, ChannelProtol, SongProtocol {

    @IBOutlet var imag: WKInterfaceImage!
    @IBOutlet var songName: WKInterfaceLabel!
    @IBOutlet var btnPre: WKInterfaceButton!
    @IBOutlet var btnPlay: WKInterfaceButton!
    @IBOutlet var btnNext: WKInterfaceButton!
    //网络控制器的类的实例
    var eHttp:HttpController = HttpController()
    //数据参数类
    var data:DBData = DBData.instance
    
    //声明一个媒体播放器的实例
    var audioPlayer:AVPlayerViewController = AVPlayerViewController()
    //当前播放歌曲的索引值
    var currIndex: Int = 0
    
    //判断是否要更新主视图的信息
    var isRefresh: Bool = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        //频道列表数据网址：
        //http://www.douban.com/j/app/radio/channels
        //频道0歌曲数据网址
        //http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite
            
        eHttp.delegate = self
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=5&from=mainsite")
    }
    func didRecieveResults(results: AnyObject) {
        print("data:\(results)");
        let json = JSON(results)
        //列表是否是频道列表数据
        if let channels = json["channels"].array {
            data.channels = channels
        } else if let songs = json["song"].array {
            data.songs = songs
            onSetSong(0)
        }
    }
    //接收歌曲索引
    func onChangeSong(index: Int) {
        onSetSong(index)
    }
    //根据歌曲索引设置音乐信息
    func onSetSong(index: Int) {
        currIndex = index
        
        //获取行数据
        var rowData:JSON = self.data.songs[index] as JSON
        //设置封面
        onSetImage(rowData)
        
        //获取歌曲的文件地址
        var songUrl:String = rowData["url"].stringValue
        //播放歌曲
        onSetAudio(songUrl)
    }
    /***
    **使用AVPlayerViewController播放视频
    ****/
    func onSetAudio(songUrl:String) {
        
        isPlay = true
        btnPlay.setBackgroundImageNamed("btnPause")
        
        self.audioPlayer.player?.pause()
        //实例化AVPlayer
        let player = AVPlayer(URL: NSURL(string: songUrl)!)
        //设置AVPlayerViewController的AVPlayer
        self.audioPlayer.player = player
        self.audioPlayer.player?.play()
        
    }
/*********************
     ***********
    //播放歌曲的方法
    func onSetAudio(songUrl:String) {
//        if self.audioPlayer.playing {
//            self.audioPlayer.stop()
//        }
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string: songUrl)!)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
        } catch {
            
        }
        
//        self.audioPlayer.play()
    }
     ***********
************************/
     
    @IBAction func onPre() {
        //自减，
        currIndex--
        if currIndex < 0 {
            currIndex = self.data.songs.count - 1
        }
        onSetSong(currIndex)
    }
     //播放状态
    var isPlay: Bool = true
    @IBAction func onPlay() {
        isPlay = !isPlay
        if isPlay {
            self.audioPlayer.player?.play()
            btnPlay.setBackgroundImageNamed("btnPause")
        } else {
            self.audioPlayer.player?.pause()
            btnPlay.setBackgroundImageNamed("btnPlay")
        }
    }
    
    @IBAction func onNext() {
        //自增
        currIndex++
        if (currIndex > self.data.songs.count - 1) {
            currIndex = 0
        }
        onSetSong(currIndex )
    }
     
    //设置歌曲封面以及信息
    func onSetImage(rowData: JSON) {
        //获取该首歌曲的图片地址
        let imageUrl = rowData["picture"].stringValue
        data.onSetImage(imageUrl, imag: imag)
        
        //设置
        let sTitle = rowData["title"].stringValue
        let sArtist = rowData["artist"].stringValue
        let title = "\(sTitle) - \(sArtist)"
        songName.setText(title)
    }
    //接收频道id
    func onChangeChannel(channel_id: String) {

        //拼接频道列表的歌曲数据网络地址
        //频道0歌曲数据网址
        //http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite
        
        let url:String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        eHttp.onSearch(url)
        
    }
    //跳转到频道列表
    @IBAction func onShowChannel() {
        self.presentControllerWithName("channel", context: self)
        isRefresh = true
    }
    //跳转到歌曲列表
    @IBAction func onShowSongs() {
        self.presentControllerWithName("song", context: self)
    }
    @IBAction func dismissShow() {
        self.dismissController()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if isRefresh {
            var rowData:JSON = self.data.songs[currIndex] as JSON
            onSetImage(rowData)
            isRefresh = false
            if isPlay {
                btnPlay.setBackgroundImageNamed("btnPause")
            }
        }
        
//        if self.data.songs.count > 0 {
//            var rowData:JSON = self.data.songs[currIndex] as JSON
//            onSetImage(rowData)
//        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
