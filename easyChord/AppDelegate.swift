//
//  AppDelegate.swift
//  easyChord
//
//  Created by USER on 2018. 12. 3..
//  Copyright © 2018년 USER. All rights reserved.
//

import UIKit

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
        // Override point for customization after application launch.
        
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
    
//    static func getNextKey() -> String
//    {
//         var saveKeyStr = "1"
//        if  let keyString = UserDefaults.standard.string(forKey: SongsDefaulsKeys.songCountKey) {
//            saveKeyStr = String( Int(keyString)! + 1 )
//        }
//        return saveKeyStr
//    }
    
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
        
        let model = SongModel(title: title, lyric: lyric, chord: chord, key: saveKeyStr, type: saveType)
        let encoded = try? JSONEncoder().encode(model) as NSData
        
        var songDic = UserDefaults.standard.dictionary(forKey: SongsDefaulsKeys.songsDicKey)
        if  songDic == nil || songDic?.count == 0 {
            songDic = [saveKeyStr : encoded!]
        } else {
            songDic![String(saveKeyStr)] = encoded!
        }

        UserDefaults.standard.set(songDic, forKey: SongsDefaulsKeys.songsDicKey)
        UserDefaults.standard.synchronize()
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
            
            UserDefaults.standard.set(songDic, forKey: SongsDefaulsKeys.songsDicKey)
            UserDefaults.standard.synchronize()
            
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
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

