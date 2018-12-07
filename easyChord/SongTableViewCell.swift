//
//  SongTableViewCell.swift
//  easyChord
//
//  Created by USER on 2018. 12. 3..
//  Copyright © 2018년 USER. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel?
    var songsData: SongModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(data: SongModel) {
        songsData = data
        titleLabel?.text = songsData?.title
    }

}
