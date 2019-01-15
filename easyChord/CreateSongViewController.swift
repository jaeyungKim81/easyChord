//
//  CreateSongViewController.swift
//  easyChord
//
//  Created by USER on 2018. 12. 4..
//  Copyright © 2018년 USER. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CreateSongViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADInterstitialDelegate, GADRewardBasedVideoAdDelegate {

    @IBOutlet var chordTF: UITextView!
    @IBOutlet var lyricTF: UITextView!
    
    @IBOutlet var musicSheet: UIImageView!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var scrollHeight: NSLayoutConstraint!
    
    var musicImg: UIImage?
    var model: SongModel?
    var isSet = false
    var saveType:SaveType = .text
    
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width:UIScreen.main.bounds.size.width , height: 50))
    
    let infoBarItem:UIBarButtonItem = UIBarButtonItem(title: "input lyric", style: UIBarButtonItemStyle.plain, target: self, action: nil)
    let chordBarItem = UIBarButtonItem.menuButton(self, action: #selector(changeChordAndLyric(_:)), imageName: "chord", title: "chord", width: 77)
    let lyricBarItem = UIBarButtonItem.menuButton(self, action: #selector(changeChordAndLyric(_:)), imageName: "lyric", title: "lyric", width: 77)
    let saveItem = UIBarButtonItem.menuButton(self, action: #selector(save), imageName: "save", title: "save", width: 70)
    
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(showInputTitleAlert), imageName: "edit")
        navigationController?.navigationBar.tintColor = UIColor.black//UIColor.gray

//reward
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-5663501014164495/4870538791")
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        
        print(" chordBarItem: \(String(describing: chordBarItem.title))")
        print(" lyricBarItem: \(String(describing: lyricBarItem.title))")
    }
    
    //scrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == chordTF) {
            lyricTF.contentOffset.y = scrollView.contentOffset.y
        }else if(scrollView == lyricTF) {
            chordTF.contentOffset.y = scrollView.contentOffset.y
        }
    }
    
    func addSong()
    {
        let actionSheet = UIAlertController(title: "Add Method", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Write", style: .default, handler: { result in
            self.setSaveType(type: .text)
            self.showInputTitleAlert()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Image", style: .default, handler: { result in
            self.setSaveType(type: .image)
            self.showImgPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler:  { result in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func showImgPicker()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum)
        {
            let profileimagePicker = UIImagePickerController()
            profileimagePicker.delegate = self
            profileimagePicker.allowsEditing = false
            profileimagePicker.sourceType = .photoLibrary
            self.present(profileimagePicker, animated: true, completion: nil)
        }else{
            let alertController = UIAlertController(title: "test", message:
                "Can not access the photo library", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Check", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        var newImage: UIImage
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        self.dismiss(animated: true, completion: nil)
        
        setImg(img: newImage)
    }
    
    func setImg(img: UIImage)
    {
        let rate = img.size.width / musicSheet.frame.size.width
        if let _ = musicSheet.image {
            let newImgViewHei = img.size.height / rate
            
            let newImgView = UIImageView(frame: CGRect(x: 0, y: scrollHeight.constant, width: musicSheet.frame.size.width, height: newImgViewHei))
            newImgView.image = img
            scrollView.addSubview(newImgView)
            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollHeight.constant + newImgViewHei)
            
            let newImg = screenshot()!
            musicSheet.image = nil
            setImg(img:newImg )
            return
        }
        musicSheet.image = img
        scrollHeight.constant = img.size.height / rate
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollHeight.constant)
    }
    
    func screenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, false, 0.0)
        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame
        defer {
            UIGraphicsEndImageContext()
            scrollView.contentOffset = savedContentOffset
            scrollView.frame = savedFrame
        }
        scrollView.contentOffset = .zero
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
       scrollView.layer.render(in: ctx)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if isSet {
            return
        }
        isSet = true
        if model != nil {
            if (model?.type == SongsDefaulsKeys.saveTypeImg) {
                setSaveType(type: .image)
            }else if (model?.type == SongsDefaulsKeys.saveTypeText) {
                setSaveType(type: .text)
                disableTextView(target: self.chordTF)
                ableTextView(target: self.lyricTF)
            }
            navigationItem.title = model?.title
        }else {
            addSong()
        }
    }
    
    func setSaveType(type: SaveType)
    {
        saveType = type
        lyricTF.isHidden = (type == .image )
        chordTF.isHidden = (type == .image )
        musicSheet.isHidden = !(type == .image )
        
        toolBar.barStyle = UIBarStyle.default
        
        saveItem.title = "save"
        var itemArr =  [
            saveItem
        ]
        
        if type == .image {
            
            let imgItem = UIBarButtonItem.menuButton(self, action: #selector(showImgPicker), imageName: "img", title: "image", width:80)
            itemArr.append(imgItem)
//            itemArr.append(UIBarButtonItem(title: "Img", style: UIBarButtonItemStyle.plain, target: self, action: #selector(showImgPicker)))
            
            toolBar.items = itemArr
            view.addSubview(toolBar)
            toolBar.frame.origin = CGPoint(x: 0, y: view.frame.size.height - toolBar.frame.size.height)
            if  musicImg != nil {
                setImg(img: musicImg!)
            }
            
        }else if type == .text {
            
//            itemArr.append(UIBarButtonItem(title: "Chord", style: UIBarButtonItemStyle.plain, target: self, action: #selector(changeChordAndLyric(_:))))
//            textItem.title = "Chord"
            itemArr.append(chordBarItem)
            toolBar.items = itemArr
            
            chordTF.inputAccessoryView = toolBar
            lyricTF.inputAccessoryView = toolBar
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 50
            
            if model == nil {
                lyricTF.attributedText = NSAttributedString(string: "", attributes: [.paragraphStyle : paragraphStyle])
                chordTF.attributedText = NSAttributedString(string: "", attributes: [.paragraphStyle : paragraphStyle])
            }else {
                lyricTF.attributedText = NSAttributedString(string: (model?.lyric)!, attributes: [.paragraphStyle : paragraphStyle])
                chordTF.attributedText = NSAttributedString(string: (model?.chord)!, attributes: [.paragraphStyle : paragraphStyle])
            }
            
            lyricTF.delegate = self
            chordTF.delegate = self
        }
    }
    
    
    @objc func showInputTitleAlert()  {
        if saveType == .text {
            self.disableTextView(target: self.chordTF)
            self.ableTextView(target: self.lyricTF)
        }
        
        let alert = UIAlertController(title: "Input Title", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            if(self.navigationItem.title == "") {
                textField.placeholder = "Title"
            }else {
                textField.text = self.navigationItem.title
            }
        })
        alert.addAction(UIAlertAction(title: "cancel", style: .default, handler: {  Void in
            if self.saveType == .image {
                alert.view.endEditing(true)
            }
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (action) -> Void in
            let textField = alert?.textFields![0]
            print("Text field: \(String(describing: textField?.text))")
            self.navigationItem.title = textField?.text
            if self.saveType == .image {
                alert?.view.endEditing(true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func validation() -> Bool {
        if navigationItem.title == nil || navigationItem.title == "" {
            showInputTitleAlert()
            return false
        }
        
        if (saveType == .text) {    //
            if lyricTF.text == "" {
                showSimpleAlert(msg: "가사를 입력해 주세요.")
                return false
            }else if chordTF.text == "" {
                showSimpleAlert(msg: "코드를 입력해 주세요.")
                return false
            }
            return true
        }else if (saveType == .image) {
            if musicSheet.image == nil {
                showSimpleAlert(msg: "이미지를 선택해 주세요.")
                return false
            }
            return true
        }else {
            return false
        }
    }
    
    @objc func save()
    {
        if !validation() {
            return
        }
        if GADRewardBasedVideoAd.sharedInstance().isReady {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        }else if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }else {
            addData()
        }
    }
    
    func addData() {
        if (saveType == .text) {    //
            if model == nil {
                AppDelegate.addOrEditSong(title: navigationItem.title!, lyric: lyricTF.text, chord: chordTF.text)
            }else {
                AppDelegate.addOrEditSong(title: navigationItem.title!, lyric: lyricTF.text, chord: chordTF.text, key: (model?.key)!)
            }
        }else if (saveType == .image) {
            if model == nil {
                AppDelegate.addOrEditSong(title: navigationItem.title!, type: .image, img: musicSheet.image)
            } else {
                AppDelegate.addOrEditSong(title: navigationItem.title!, key: (model?.key)!, type: .image, img: musicSheet.image)
            }
        }
        if model == nil {
            navigationController?.popViewController(animated: true)
        }else {
            navigationController?.popToRootViewController(animated: true)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ViewController.didUpdate), object: nil)
    }
    
    @objc func done () {
    }
    
    @objc func changeChordAndLyric(_ sender: UIButton)
    {
        print(" sender: \(String(describing: sender))")
        print(" sender.title: \(String(describing: sender.title(for: .normal)))")
        if(sender.title(for: .normal) == "chord") {
            toolBar.items?.remove(at: 1)
            toolBar.items?.append(lyricBarItem)
            disableTextView(target: lyricTF)
            ableTextView(target: chordTF)
        }else {
            toolBar.items?.remove(at: 1)
            toolBar.items?.append(chordBarItem)
            disableTextView(target: chordTF)
            ableTextView(target: lyricTF)
        }
    }
    
    func showSimpleAlert(msg: String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { Void in
         }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func disableTextView(target: UITextView){
        target.alpha = 0.5
        target.isUserInteractionEnabled = false
        target.isEditable = false
    }
    
    func ableTextView(target: UITextView) {
        target.alpha = 1.0
        target.isUserInteractionEnabled = true
        target.isEditable = true
        target.becomeFirstResponder()
    }
    
    ///reward
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
    }
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad has completed.")
    }
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        addData()
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: "ca-app-pub-5663501014164495/5155095310")
        print("Reward based video ad is closed.")
    }
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
    }
    
/// Front
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        addData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
