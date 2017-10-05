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
    
    var micropost: Micropost? {
        didSet {
            guard let micropost = micropost else {
                return
            }
            textView.text = micropost.content
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
        guard let view = Bundle.main.loadNibNamed("BalloonView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        view.frame = bounds
        addSubview(view)
    }
}
