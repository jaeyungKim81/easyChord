//
//  CreateSongViewController.swift
//  easyChord
//
//  Created by USER on 2018. 12. 4..
//  Copyright © 2018년 USER. All rights reserved.
//

import UIKit

//enum saveType : Int {
//    case text = 0
//    class img
//}

class CreateSongViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.title = "Add Song"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Title", style: .plain, target: self, action: #selector(showInputTitleAlert))
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
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
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
        musicSheet.image = img
        let rate = img.size.width / musicSheet.frame.size.width
        scrollHeight.constant = img.size.height / rate
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollHeight.constant)
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
        var itemArr =  [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Img", style: UIBarButtonItemStyle.plain, target: self, action: #selector(showImgPicker)),
            UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(save)),
        ]
        
        if type == .image {
            
            toolBar.items = itemArr
            view.addSubview(toolBar)
            toolBar.frame.origin = CGPoint(x: 0, y: view.frame.size.height - toolBar.frame.size.height)
            if  musicImg != nil {
                setImg(img: musicImg!)
            }
            
        }else if type == .text {
            
            itemArr.append(UIBarButtonItem(title: "Chord", style: UIBarButtonItemStyle.plain, target: self, action: #selector(changeChordAndLyric(_:))))
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
        let alert = UIAlertController(title: "Input Title", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            if(self.navigationItem.title == "") {
                textField.placeholder = "Title"
            }else {
                textField.text = self.navigationItem.title
            }
            self.disableTextView(target: self.chordTF)
            self.ableTextView(target: self.lyricTF)
        })
        alert.addAction(UIAlertAction(title: "cancel", style: .default, handler: {  Void in
            self.disableTextView(target: self.chordTF)
            self.ableTextView(target: self.lyricTF)
            self.view.endEditing(true)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (action) -> Void in
            let textField = alert?.textFields![0]
            print("Text field: \(String(describing: textField?.text))")
            self.navigationItem.title = textField?.text
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            self.view.endEditing(true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func save()
    {
        if navigationItem.title == nil || navigationItem.title == "" {
            showSimpleAlert(msg: "제목을 입력해 주세요.")
            return
        }
        
        if (saveType == .text) {    //
            if lyricTF.text == "" {
                showSimpleAlert(msg: "가사를 입력해 주세요.")
                return
            }else if chordTF.text == "" {
                showSimpleAlert(msg: "코드를 입력해 주세요.")
                return
            }
            if model == nil {
                AppDelegate.addOrEditSong(title: navigationItem.title!, lyric: lyricTF.text, chord: chordTF.text)
            }else {
                AppDelegate.addOrEditSong(title: navigationItem.title!, lyric: lyricTF.text, chord: chordTF.text, key: (model?.key)!)
            }
        }else if (saveType == .image) {
            if musicSheet.image == nil {
                showSimpleAlert(msg: "이미지를 선택해 주세요.")
                return
            }
            if model == nil {
                AppDelegate.addOrEditSong(title: navigationItem.title!, type: .image, img: musicSheet.image)
            } else {
                AppDelegate.addOrEditSong(title: navigationItem.title!, key: (model?.key)!, type: .image, img: musicSheet.image)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ViewController.didUpdate), object: nil)
        if model == nil {
            navigationController?.popViewController(animated: true)
        }else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func done () {
    }
    
    @objc func changeChordAndLyric(_ sender: UIBarButtonItem) {
        if(sender.title == "Chord") {   //Lyric -> Chord
            sender.title = "Lyric"
            infoBarItem.title = "Input Chord"
            disableTextView(target: lyricTF)
            ableTextView(target: chordTF)
        }else {
            sender.title = "Chord"
            infoBarItem.title = "Input chord"
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
