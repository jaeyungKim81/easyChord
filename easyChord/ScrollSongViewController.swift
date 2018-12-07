//
//  ScrollSongViewController.swift
//  easyChord
//
//  Created by USER on 2018. 12. 3..
//  Copyright © 2018년 USER. All rights reserved.
//

import UIKit

class ScrollSongViewController: UIViewController {

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

        // Do any additional setup after loading the view.
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
        let rate = (musicSheet.image?.size.width)! / musicSheet.frame.size.width
        musicSheetHeight.constant = musicSheet.image!.size.height / rate
        scrollHeight.constant = musicSheetHeight.constant
        
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollHeight.constant)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if (songData?.type == SongsDefaulsKeys.saveTypeImg) {
            musicSheet.isHidden = false
            lyric.isHidden = true
            chord.isHidden = true
            if let img = loadImageFromPath(name: (songData?.key)!) {
                
                musicSheet.image = img
                setHeight()
//                let rate = img.size.width / musicSheet.frame.size.width
//                musicSheetHeight.constant = img.size.height / rate
//                scrollHeight.constant = musicSheetHeight.constant
//
//                scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollHeight.constant)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(moveEditView))
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
        scrollView.contentOffset.y = scrollView.contentOffset.y + getNowSpeed()
        if(scrollBtn.isSelected) {
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(scroll), userInfo: nil, repeats: false)
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
