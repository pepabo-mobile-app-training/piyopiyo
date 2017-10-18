//
//  MenuView.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/18.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class MenuView: UIView {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    fileprivate func setup() {
        guard let view = Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        view.frame = bounds
        addSubview(view)
    }

}

