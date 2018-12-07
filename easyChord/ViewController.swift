//
//  ViewController.swift
//  easyChord
//
//  Created by USER on 2018. 12. 3..
//  Copyright © 2018년 USER. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet private var songsTableView: UITableView!
    
    static let didUpdate = "notifiUpdate"
    
    var songArr:Array! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songsTableView.delegate = self
        songsTableView.dataSource = self
        
        navigationItem.title = "Songs"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addSong))
        
        loadData()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadData),
                                               name: NSNotification.Name(rawValue: ViewController.didUpdate),
                                               object: nil)
    }
    
    @objc func loadData()
    {
        DispatchQueue.main.async {
            self.songArr = AppDelegate.getSongArr()
            self.songsTableView.reloadData()
        }
    }
    
    @objc func addSong()
    {
        let createVC = CreateSongViewController.storyboardViewController()
        self.navigationController?.pushViewController(createVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell")
        guard  let itemCell = cell as? SongTableViewCell else {
            return cell!
        }
        print("indexPath.row : \(indexPath.row)")
        print("songArr : \(String(describing: songArr))")
        itemCell.setData(data: songArr[indexPath.row] as! SongModel)
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
        return 62
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let scrollVC = ScrollSongViewController.storyboardViewController()
        scrollVC.songData = (songArr[indexPath.row] as! SongModel)
        navigationController?.pushViewController(scrollVC, animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: {(action, indexPath) -> Void in
            print("deletAction")
            let model = self.songArr[indexPath.row] as! SongModel
            AppDelegate.deleteSong(key: model.key)
            self.loadData()
        })
        return [deleteAction]
    }
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
