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
    static let screenSize = UIScreen.main.bounds.size
    
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
        self.translatesAutoresizingMaskIntoConstraints = true

        let viewList = [firstPageView, secondPageView, thirdPageView, fourthPageView]
        for i in 0..<viewList.count {
            guard let page = viewList[i] else {
                continue
            }
            page.translatesAutoresizingMaskIntoConstraints = true
            page.frame = CGRect(x: CGFloat(i)*TutorialPage.screenSize.width, y: 0, width: TutorialPage.screenSize.width, height: TutorialPage.screenSize.height)
        }
        view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: TutorialPage.viewSize())
        addSubview(view)
    }
    
    static func viewSize() -> CGSize {
        return CGSize(width: CGFloat(TutorialPage.pageCount)*TutorialPage.screenSize.width, height: TutorialPage.screenSize.height)
    }
}
