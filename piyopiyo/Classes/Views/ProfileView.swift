//
//  ProfileView.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/09/26.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit
import SDWebImage

protocol ProfileViewDelegate: class {
    func closeButtonDidTap()
    func showUserFeedButtonDidTap()
}

class ProfileView: UIView {
    
    weak var delegate: ProfileViewDelegate?
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
            profileImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    var profile: userProfile? {
        didSet {
            guard let profile = profile else {
                return
            }
            userNameLabel.text = profile.name
            profileImageView.sd_setImage(with: profile.avatarURL, placeholderImage: UIImage(named: "avatar"))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    fileprivate func setup() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1

        guard let view = Bundle.main.loadNibNamed("ProfileView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        view.frame = bounds
        addSubview(view)
    }
    
    @IBAction func closeButtonDidTap(_ sender: UIButton) {
        delegate?.closeButtonDidTap()
        removeFromSuperview()
    }

    @IBAction func showButtonDidTap(_ sender: ColorButton) {
        delegate?.showUserFeedButtonDidTap()
        removeFromSuperview()
    }
}
