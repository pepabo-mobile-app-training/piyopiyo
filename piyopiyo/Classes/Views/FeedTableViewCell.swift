//
//  FeedTableViewCell.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/10/10.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit
import SDWebImage

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
            avatarImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func update(profile: UserProfile, micropost: Micropost) {
        nameLabel.text = profile.name
        avatarImageView.sd_setImage(with: profile.avatarURL, placeholderImage: UIImage(named: "avatar"))
        contentTextView.text = micropost.content
    }
}
