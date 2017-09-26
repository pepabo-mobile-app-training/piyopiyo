//
//  ProfileView.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/09/26.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

@IBDesignable class ProfileView: UIView {

    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = 80
        }
    }
}
