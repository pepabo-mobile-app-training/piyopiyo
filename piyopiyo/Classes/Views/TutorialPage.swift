//
//  TutorialPage.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/09/27.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class TutorialPage: UIView {
    
    @IBOutlet weak var firstPageView: UIView!
    @IBOutlet weak var secondPageView: UIView!
    @IBOutlet weak var thirdPageView: UIView!
    @IBOutlet weak var fourthPageView: UIView!
    
    static let pageCount = 4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    fileprivate func setup() {
        guard let view = Bundle.main.loadNibNamed("TutorialPage", owner: self, options: nil)?.first as? UIView else {
            return
        }
        
        
        let viewList = [firstPageView, secondPageView, thirdPageView, fourthPageView]
        let screenSize = UIScreen.main.bounds.size
        for i in 0..<viewList.count {
            guard let page = viewList[i] else {
                continue
            }
            page.translatesAutoresizingMaskIntoConstraints = true
            let pageRectangle = CGRect(x: CGFloat(i)*screenSize.width, y: 0, width: screenSize.width, height: screenSize.height)
            page.frame = pageRectangle
        }
        view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:  TutorialPage.viewSize())
        //view.frame = bounds
        addSubview(view)
    }
    
    static func viewSize() -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        return CGSize(width: CGFloat(TutorialPage.pageCount)*screenSize.width, height: screenSize.height)
    }
}

