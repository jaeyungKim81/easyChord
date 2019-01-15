//
//  ViewController.swift
//  easyChord
//
//  Created by USER on 2018. 12. 3..
//  Copyright © 2018년 USER. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet private var songsTableView: UITableView!
    
    var bannerView: GADBannerView!
    
    
    static let didUpdate = "notifiUpdate"
    
    var songArr:Array! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        songsTableView.delegate = self
        songsTableView.dataSource = self
        
        navigationItem.title = "Songs"
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(addSong), imageName: "add")
        
        loadData()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadData),
                                               name: NSNotification.Name(rawValue: ViewController.didUpdate),
                                               object: nil)
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-5663501014164495/6510923527"
        bannerView.delegate = self
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    @objc func loadData()
    {
        DispatchQueue.main.async {
            self.songArr = AppDelegate.getSongArr()
            print("ViewController songArr = \(String(describing: self.songArr))")
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

extension ViewController : GADBannerViewDelegate
{
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}

extension UIBarButtonItem {
    
    static func menuButton(_ target: Any?, action: Selector, imageName: String, title: String="", width: CGFloat=0.0) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.title = title
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        if !(width == 0.0) {
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, width-24)
            menuBarItem.customView?.widthAnchor.constraint(equalToConstant: width).isActive = true
        }else {
            menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        }
        
        return menuBarItem
    }
}


