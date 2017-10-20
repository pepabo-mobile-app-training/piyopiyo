//
//  TutorialView.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/09/27.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

protocol TutorialDelegate: class {
    func startButtonDidTap()
}

class TutorialView: UIView {

    weak var delegate: TutorialDelegate?
    @IBOutlet weak var startButton: ColorButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tutorialPage: TutorialPage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    fileprivate func setup() {
        guard let view = Bundle.main.loadNibNamed("TutorialView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        view.frame = bounds
        addSubview(view)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        tutorialPage.translatesAutoresizingMaskIntoConstraints = true
        
        tutorialPage.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: TutorialPage.viewSize())
        
        scrollView.contentSize = TutorialPage.viewSize()
        scrollView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
    }
    
    @IBAction func startButtonDidTap(_ sender: ColorButton) {
        removeFromSuperview()
        delegate?.startButtonDidTap()
    }
}
