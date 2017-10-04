//
//  ViewController.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/09/25.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, TutorialDelegate {

    static let screenSize = UIScreen.main.bounds.size
    static let hiyokoHeight: CGFloat = 100.0
    
    static let trailingMargin: CGFloat = 30.0
    static let bottomMargin = hiyokoHeight + 10
    
    static let balloonWidth = screenSize.width - trailingMargin * 2
    static let balloonHeight = balloonWidth / 2

    static let initialBalloonX = trailingMargin + balloonWidth
    static let initialBalloonY = screenSize.height - bottomMargin

    private let balloonView = BalloonView(frame: CGRect(x: FeedViewController.initialBalloonX, y: FeedViewController.initialBalloonY, width: 0, height: 0))
    private var tutorialView: TutorialView?

    override func viewDidLoad() {
        super.viewDidLoad()

        tutorialView = TutorialView(frame: self.view.frame)
        if let tutorialView = tutorialView {
            tutorialView.delegate = self
            addTutorial(tutorialView: tutorialView)
        }
    }

    private func addTutorial(tutorialView: TutorialView?) {
        guard let tutorialView = tutorialView else {
            return
        }

        view.addSubview(tutorialView)
    }

    
    func startButtonDidTap() {
        view.addSubview(balloonView)
        animateBalloon()
    }

    private func animateBalloon() {
        UIView.animate(withDuration: 1, delay: 0.5, animations: {
            let originBalloonX = FeedViewController.initialBalloonX - FeedViewController.balloonWidth
            let originBalloonY = FeedViewController.initialBalloonY - FeedViewController.balloonHeight
            
            self.balloonView.frame = CGRect(x: originBalloonX, y: originBalloonY, width: FeedViewController.balloonWidth, height: FeedViewController.balloonHeight)
            self.balloonView.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: 5, delay: 0.5, animations: {
                self.balloonView.frame.origin.y = -FeedViewController.balloonHeight
                self.balloonView.layoutIfNeeded()
            }) { _ in
                self.balloonView.frame = CGRect(x: FeedViewController.initialBalloonX, y: FeedViewController.initialBalloonY, width: 0, height: 0)
                self.balloonView.layoutIfNeeded()
                self.animateBalloon()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        //画面遷移時にURLを設定する実装にひとまずしてある状態
        let vc = segue.destination as? UserFeedViewController
        vc!.userFeedURL = URL(string: "https://www.google.com")
    }
}
