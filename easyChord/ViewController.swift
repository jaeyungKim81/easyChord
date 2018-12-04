//
//  ViewController.swift
//  easyChord
//
//  Created by USER on 2018. 12. 3..
//  Copyright © 2018년 USER. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet private var songsTableView: UITableView!
    
    var songArr:Array! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        songArr = UserDefaults.standard.array(forKey: SongsDefaulsKeys.songsArrKey)
        
        songsTableView.delegate = self
        songsTableView.dataSource = self
        
        print("songArr : \(songArr)")
    }
    
//    static func storyboardViewController() -> Self {
//        guard let vc = storyboard().instantiateViewController(withIdentifier: String(describing: self)) as? Self else {
//            fatalError("Could not instantiate storyboard with name: \(defaultStoryboardName)")
//        }
//        return vc
//    }

    //TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell")
        guard  let itemCell = cell as? SongTableViewCell else {
            return cell!
        }

        itemCell.setData(data: songArr[indexPath.row] as! Dictionary<String, String>)
        return cell!
    }
    //TableView DataSource end

    //TableView Delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let scrollVC = ScrollSongViewController.storyboardViewController()
        scrollVC.songData = songArr[indexPath.row] as! Dictionary<String, String>
        navigationController?.pushViewController(scrollVC, animated: true)
    }
    //TableView Delegate end
}

protocol Storyboard: class { //, HasApply, HasLet {
    static var defaultStoryboardName: String { get }
}

extension Storyboard where Self: UIViewController {
    static var defaultStoryboardName: String {
        return String(describing: self)
    }
    
    static func storyboardViewController() -> Self {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: defaultStoryboardName) as? Self else {
            fatalError("Could not instantiate storyboard with name: \(defaultStoryboardName)")
        }
        return vc
    }
}
extension UIViewController: Storyboard { }
