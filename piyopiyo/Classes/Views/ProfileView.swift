//
//  ProfileView.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/09/26.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class ProfileView: UIView {
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
            profileImageView.layer.masksToBounds = true
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
    
}
