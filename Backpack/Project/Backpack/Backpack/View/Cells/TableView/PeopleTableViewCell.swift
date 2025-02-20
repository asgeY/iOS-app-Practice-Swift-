//
//  PeopleTableViewCell.swift
//  Backpack
//
//  Created by Anik on 11/4/19.
//  Copyright © 2019 A7Studio. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: RoundedCornerImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: RoundedButtonWithBorder!
    @IBOutlet weak var followedDoneButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
