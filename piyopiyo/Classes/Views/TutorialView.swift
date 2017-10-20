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

class TutorialView: UIView, UIScrollViewDelegate {

    weak var delegate: TutorialDelegate?
    @IBOutlet weak var startButton: ColorButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tutorialPage: TutorialPage!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var isNotFirstTutorial: Bool = true {
        didSet {
            if isNotFirstTutorial {
                startButton.setTitle("とじる", for: .normal)
            } else {
                startButton.setTitle("はじめる", for: .normal)
            }
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
        guard let view = Bundle.main.loadNibNamed("TutorialView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        view.frame = bounds
        addSubview(view)

        tutorialPage.translatesAutoresizingMaskIntoConstraints = true
        tutorialPage.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: TutorialPage.viewSize())
        
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.contentSize = TutorialPage.viewSize()
        scrollView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        scrollView.delegate = self
        
        startButton.isHidden = true
    }
    
    @IBAction func startButtonDidTap(_ sender: ColorButton) {
        removeFromSuperview()
        delegate?.startButtonDidTap()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.maxX)
        pageControl.currentPage = currentPage
        
        if currentPage == TutorialPage.pageCount-1 {
            startButton.isHidden = false
        } else {
            startButton.isHidden = true
        }
    }
    
}
