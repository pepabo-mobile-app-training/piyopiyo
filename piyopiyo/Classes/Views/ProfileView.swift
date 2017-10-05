//
//  ProfileView.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/09/26.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate: class {
    func closeButtonDidTap()
}

class ProfileView: UIView {
    
    weak var delegate: ProfileViewDelegate?
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
    
    @IBAction func closeButtonDidTap(_ sender: UIButton) {
        delegate?.closeButtonDidTap()
        removeFromSuperview()
    }
}
