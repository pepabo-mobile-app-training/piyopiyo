//
//  BallonView.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/09/26.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class BalloonView: UIView {
    
    @IBOutlet weak var textView: UITextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    fileprivate func setup() {
        guard let view = Bundle.main.loadNibNamed("BalloonView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        view.frame = bounds
        addSubview(view)
    }
}
