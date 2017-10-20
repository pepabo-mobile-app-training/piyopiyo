//
//  MenuView.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/18.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

protocol MenuViewDelegate: class {
    func closeMenuButtonDidTap()
    func showTutorialButtonDidTap()
    func showAppInformationButtonDidTap()
}

class MenuView: UIView {
    
    weak var delegate: MenuViewDelegate?
   
    @IBOutlet weak var showTutorialButton: UIButton!
    @IBOutlet weak var showAppInformationButton: UIButton!
    @IBOutlet weak var closeMenuButton: UIButton!
    
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
    
    @IBAction func showTutorialButtonDidTap(_ sender: Any) {
        self.isHidden = true
        delegate?.showTutorialButtonDidTap()
    }
    
    @IBAction func showAppInformationDidTap(_ sender: Any) {
        self.isHidden = true
        delegate?.showAppInformationButtonDidTap()
    }
    
    @IBAction func closeMenuButtonDidTap(_ sender: Any) {
        self.isHidden = true
        delegate?.closeMenuButtonDidTap()
    }
    
}
