//
//  ScrollSongViewController.swift
//  easyChord
//
//  Created by USER on 2018. 12. 3..
//  Copyright © 2018년 USER. All rights reserved.
//

import UIKit

class ScrollSongViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var lyric: UITextView!
    @IBOutlet var chord: UITextView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollHeight: NSLayoutConstraint!
    @IBOutlet var musicSheetHeight: NSLayoutConstraint!
    @IBOutlet var musicSheet: UIImageView!
    
    @IBOutlet var speedTF: UITextField!
    @IBOutlet var scrollBtn: UIButton!
    
    var songData : SongModel? //Dictionary! = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        chord.delegate = self
        
        // 4th create the first piece of the string you don't want to be tappable
        let regularText = NSMutableAttributedString(string: "any text ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.black])
        
        // 5th create the second part of the string that you do want to be tappable. I used a blue color just so it can stand out.
        let tappableText = NSMutableAttributedString(string: "READ MORE")
        tappableText.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, tappableText.length))
        tappableText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: NSMakeRange(0, tappableText.length))
        
        // 6th this ISN'T NECESSARY but this is how you add an underline to the tappable part. I also used a blue color so it can match the tappableText and used the value of 1 for the height. The length of the underline is based on the tappableText's length using NSMakeRange(0, tappableText.length)
        tappableText.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: NSMakeRange(0, tappableText.length))
        tappableText.addAttribute(NSAttributedStringKey.underlineColor, value: UIColor.blue, range: NSMakeRange(0, tappableText.length))
        
        // 7th this is the important part that connects the tappable link to the delegate method in step 11
        // use NSAttributedStringKey.link and the value "makeMeTappable" to link the NSAttributedStringKey.link to the method. FYI "makeMeTappable" is a name I choose for clarity, you can use anything like "anythingYouCanThinkOf"
        tappableText.addAttribute(NSAttributedStringKey.link, value: "makeMeTappable", range: NSMakeRange(0, tappableText.length))
        
        // 8th *** important append the tappableText to the regularText ***
        regularText.append(tappableText)
        
        // 9th set the regularText to the textView's attributedText property
        chord.attributedText = regularText
    }
    
    deinit {
        AppDelegate.setSpeed(model: songData, speed: Int(getNowSpeed()))
    }
    
    func loadImageFromPath(name: String) -> UIImage? {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(name)
        
        let image = UIImage(contentsOfFile: fileURL.path)
        if image == nil {
            return nil
        }
        print("Loading image from path: \(fileURL.path)")
        return image
    }
    
    func setHeight(){
        
        DispatchQueue.main.async(execute: { () -> Void in
            var rate = (self.musicSheet.image?.size.width)! / self.musicSheet.frame.size.width
            if UIDevice.current.orientation.isLandscape {
                rate = (self.musicSheet.image?.size.width)! / self.musicSheet.frame.size.height
            }
            print("rate = \(rate)")
            self.musicSheetHeight.constant = self.musicSheet.image!.size.height / rate
            self.scrollHeight.constant = self.musicSheetHeight.constant
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollHeight.constant)
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        print("songData = \(String(describing: songData))")
        let xNSNumber  = songData!.speed as NSNumber
        speedTF.text = xNSNumber.stringValue
        
        if (songData?.type == SongsDefaulsKeys.saveTypeImg) {
            musicSheet.isHidden = false
            lyric.isHidden = true
            chord.isHidden = true
            if let img = loadImageFromPath(name: (songData?.key)!) {
                musicSheet.image = img
                musicSheet.contentMode = .scaleAspectFit
                setHeight()
            }
            
        }else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 50
            lyric.attributedText = NSAttributedString(string: (songData?.lyric)!, attributes: [.paragraphStyle : paragraphStyle])
            chord.attributedText = NSAttributedString(string:(songData?.chord)!, attributes: [.paragraphStyle : paragraphStyle])
            if (lyric.contentSize.height > chord.contentSize.height) {
                scrollHeight.constant = lyric.contentSize.height+200
            }else {
                scrollHeight.constant = chord.contentSize.height+200
            }
        }
        
        navigationItem.title = songData?.title
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(moveEditView))
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(moveEditView), imageName: "edit")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height:  scrollHeight.constant)
    }
    
    @objc func moveEditView() {
        let createVC = CreateSongViewController.storyboardViewController()
        createVC.model = songData
        if songData?.type == SongsDefaulsKeys.saveTypeImg {
            createVC.musicImg = musicSheet.image
        }
        navigationController?.pushViewController(createVC, animated: true)
    }
    
    func getNowSpeed() -> CGFloat {
        if let n = NumberFormatter().number(from: speedTF.text! ) {
            return CGFloat(truncating: n)
        }else {
            scrollBtn.isSelected = false
            return 0
        }
    }
    
    @IBAction func scrollBtnAction(_ sender: UIButton)
    {
        scrollBtn.isSelected = !scrollBtn.isSelected
        scroll()
    }
    
    @IBAction func toTopBtnAction(_ sender: UIButton)
    {
        scrollBtn.isSelected = false
        scrollView.contentOffset.y = 0
    }
    
    @IBAction func speedUpBtnAction(_ sender: UIButton)
    {
        speedTF.text = ("\(Int(getNowSpeed() + 1))")
    }
    
    @IBAction func speedDownBtnAction(_ sender: UIButton)
    {
        speedTF.text = ("\(Int(getNowSpeed() - 1))")
    }
    
    @objc func scroll()
    {
        if (scrollView.frame.size.height+scrollView.contentOffset.y > scrollView.contentSize.height) {
            scrollBtn.isSelected = false
            return
        }
        
        if(scrollBtn.isSelected) {
            UIView.animate(withDuration: 0.1, animations: {
                self.scrollView.contentOffset.y = self.scrollView.contentOffset.y + self.getNowSpeed()
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.scroll), userInfo: nil, repeats: false)
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setHeight()
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }
    
}
