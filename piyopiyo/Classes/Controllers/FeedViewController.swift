//
//  ViewController.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/09/25.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    static let screenSize = UIScreen.main.bounds.size
    static let hiyokoHeight: CGFloat = 100.0
    static let balloonWidth = screenSize.width - 30 * 2
    static let balloonHeight = balloonWidth / 2

    static let balloonX = 30.0 + balloonWidth
    static let balloonY = screenSize.height - (hiyokoHeight + 10)

    private let balloonView = BalloonView(frame: CGRect(x: FeedViewController.balloonX, y: FeedViewController.balloonY, width: 0, height: 0))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(balloonView)
        setBalloon()
    }

    private func setBalloon() {
        UIView.animate(withDuration: 1, delay: 0.5, animations: {
            let originBalloonY = FeedViewController.balloonY - FeedViewController.balloonHeight
            
            self.balloonView.frame = CGRect(x: 30.0, y: originBalloonY, width: FeedViewController.balloonWidth, height: FeedViewController.balloonHeight)
            self.balloonView.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: 5, delay: 0.5, animations: {
                self.balloonView.frame.origin.y = -FeedViewController.balloonHeight
                self.balloonView.layoutIfNeeded()
            }) { _ in
                self.balloonView.frame = CGRect(x: FeedViewController.balloonX, y: FeedViewController.balloonY, width: 0, height: 0)
                self.balloonView.layoutIfNeeded()
                self.setBalloon()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
