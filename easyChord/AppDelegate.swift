//
//  AppDelegate.swift
//  easyChord
//
//  Created by USER on 2018. 12. 3..
//  Copyright © 2018년 USER. All rights reserved.
//

import UIKit
import GoogleMobileAds

enum SaveType: Int {
    case text = 0
    case image = 1
}

struct SongModel : Codable{
//class SongModel {
    var title: String = ""
    var lyric: String = ""
    var chord: String = ""
    var key:String = ""
    var type:String = SongsDefaulsKeys.saveTypeText
    var speed: Int = 5
}

enum SongsDefaulsKeys
{
    static let title = "title"
    static let lyrics = "lyrics"
    static let chord = "chord"
    static let songKey = "songKey"
//    static let songsArrKey = "songs"
    static let songsDicKey = "songs"
    static let songCountKey = "songCountKey"
    
    static let saveTypeImg = "saveTypeImg"
    static let saveTypeText = "saveTypeText"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        GADMobileAds.configure(withApplicationID: "ca-app-pub-5663501014164495~4457930662")
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: "ca-app-pub-5663501014164495/5155095310")
        
        guard UserDefaults.standard.array(forKey: SongsDefaulsKeys.songsDicKey) != nil else {
//            let sampleDic: [String: String] =
//                [SongsDefaulsKeys.title : "샘플입니다.",
//                 SongsDefaulsKeys.lyrics : "start너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n end",
//                 SongsDefaulsKeys.chord: "startEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em      \n end "]
//            let songArr: Array = [sampleDic]
//            UserDefaults.standard.set(songArr, forKey: SongsDefaulsKeys.songsArrKey)
            
//            AppDelegate.addOrEditSong(title: "DicSample",
//                                      lyric: "start너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n너를보내고\n end",
//                                      chord: "startEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em           Em          \nEm           Em           Em      \n end ",
//                                      key: "1")
            return true
        }
        return true
    }
    
    static func setSpeed(model: SongModel?, speed: Int)
    {
        guard var myModel = model else {
            return
        }
        myModel.speed = speed
        guard var songDic = UserDefaults.standard.dictionary(forKey: SongsDefaulsKeys.songsDicKey) else {
            return
        }
        let encoded = try? JSONEncoder().encode(myModel) as NSData
        songDic[(model?.key)!] = encoded
        
        DispatchQueue.main.async {
            UserDefaults.standard.set(songDic, forKey: SongsDefaulsKeys.songsDicKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func addOrEditSong(title: String, lyric: String="", chord: String="", key: String="", type: SaveType = .text, img: UIImage? = nil)
    {
        var saveKeyStr = "1"
        if(key == "") {
            if  let keyString = UserDefaults.standard.string(forKey: SongsDefaulsKeys.songCountKey) {
                saveKeyStr = String( Int(keyString)! + 1 )
            }
            UserDefaults.standard.set(saveKeyStr, forKey: SongsDefaulsKeys.songCountKey)
        }else {
            saveKeyStr = key
        }
        var saveType = SongsDefaulsKeys.saveTypeText
        if type == .image {
            saveType = SongsDefaulsKeys.saveTypeImg
            if !saveImage(img: img!, name: saveKeyStr) {
                print("fail save Img key = \(saveKeyStr)")
            }
        }
        
        let model = SongModel(title: title, lyric: lyric, chord: chord, key: saveKeyStr, type: saveType, speed: 5)
        print("addOrEditSong = \(model)")
        let encoded = try? JSONEncoder().encode(model) as NSData
        
        var songDic = UserDefaults.standard.dictionary(forKey: SongsDefaulsKeys.songsDicKey)
        if  songDic == nil || songDic?.count == 0 {
            songDic = [saveKeyStr : encoded!]
        } else {
            songDic![String(saveKeyStr)] = encoded!
        }

        DispatchQueue.main.async {
            UserDefaults.standard.set(songDic, forKey: SongsDefaulsKeys.songsDicKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func deleteSong(key: String)
    {
        if var songDic = UserDefaults.standard.dictionary(forKey: SongsDefaulsKeys.songsDicKey) {
            
            let model:SongModel = try! JSONDecoder().decode(SongModel.self, from: songDic[key] as! Data)
            print("delete model = \(model)")
            if model.type == SongsDefaulsKeys.saveTypeImg {
                AppDelegate.deleteImage(name: key)
            }
            songDic.removeValue(forKey: key)
            
            DispatchQueue.main.async {
                UserDefaults.standard.set(songDic, forKey: SongsDefaulsKeys.songsDicKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    static func getSongArr() -> Array<SongModel>
    {
        if let dicData = UserDefaults.standard.dictionary(forKey: SongsDefaulsKeys.songsDicKey) {
            let  arr: NSMutableArray = NSMutableArray()
            
            for item in dicData {
                let model:SongModel = try! JSONDecoder().decode(SongModel.self, from: item.value as! Data)
                arr.add(model)
            }
            return arr as! Array<SongModel>
        }
        return Array()
    }

    static func saveImage(img: UIImage, name: String) -> Bool
    {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(name)
        print("fileURL = \(fileURL.path)")
        let pngImageData = UIImagePNGRepresentation(img)
        do {
            try pngImageData?.write(to: fileURL, options: .atomic)
        }catch {
            return false
        }
        return true
    }
    
    static func deleteImage(name: String)
    {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(name)
        
        do{
            try FileManager.default.removeItem(at: fileURL)
        }catch {
            print("removefile = \(fileURL.path)")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

