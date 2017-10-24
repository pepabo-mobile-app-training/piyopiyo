//
//  BallonView.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/09/26.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

protocol BalloonViewDelegate: class {
    func textViewDidTap(_ micropost: MicroContent?)
}

class BalloonView: UIView {
    
    weak var delegate: BalloonViewDelegate?
    @IBOutlet weak var microContentLabel: UILabel!
    
    var micropost: MicroContent? {
        didSet {
            guard let micropost = micropost else {
                return
            }
            let attributedText = NSMutableAttributedString(string: micropost.content)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.4
            paragraphStyle.lineBreakMode = .byTruncatingTail
            attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
            microContentLabel.attributedText = attributedText
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

    @IBAction func tap(_ sender: UIGestureRecognizer) {
        delegate?.textViewDidTap(micropost)
    }
}
