//
//  ColorButton.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/09/26.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

@IBDesignable class ColorButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var buttonColor: UIColor = UIColor.white {
        didSet {
            self.backgroundColor = buttonColor
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.white {
        didSet {
            self.setTitleColor(textColor, for: .normal)
        }
    }

}
