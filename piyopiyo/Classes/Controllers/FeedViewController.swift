//
//  ViewController.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/09/25.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = UIScreen.main.bounds.size
        let hiyokoHeight: CGFloat = 100.0
        let balloonWidth = screenSize.width - 30 * 2
        let balloonHeight = balloonWidth / 2
        let balloonX = (screenSize.width - balloonWidth) / 2
        var balloonY = screenSize.height - (balloonHeight + hiyokoHeight + 10)
        
        for _ in 0...4 {
            let balloonView = BalloonView(frame: CGRect(x: balloonX, y: balloonY, width: balloonWidth, height: balloonHeight))
            
            view.addSubview(balloonView)
            
            balloonY -= 85.0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
