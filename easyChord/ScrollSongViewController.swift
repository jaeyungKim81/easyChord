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
    
    @IBOutlet var speedTF: UITextField!
    @IBOutlet var scrollBtn: UIButton!
    
    var songData : Dictionary! = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 50
        lyric.attributedText = NSAttributedString(string: (songData[SongsDefaulsKeys.lyrics] as? String)!, attributes: [.paragraphStyle : paragraphStyle])
        chord.attributedText = NSAttributedString(string: (songData[SongsDefaulsKeys.chord] as? String)!, attributes: [.paragraphStyle : paragraphStyle])
        if (lyric.contentSize.height > chord.contentSize.height) {
            scrollHeight.constant = lyric.contentSize.height+200
        }else {
            scrollHeight.constant = chord.contentSize.height+200
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        navigationController?.title = songData[SongsDefaulsKeys.title] as? String
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height:  scrollHeight.constant)
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

}
