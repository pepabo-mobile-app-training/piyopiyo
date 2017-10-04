//
//  ViewController.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/09/25.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, TutorialDelegate, BalloonViewDelegate , ProfileViewDelegate {

    static let screenSize = UIScreen.main.bounds.size
    static let hiyokoHeight: CGFloat = 100.0
    
    static let trailingMargin: CGFloat = 30.0
    static let bottomMargin = hiyokoHeight + 10
    
    static let balloonWidth = screenSize.width - trailingMargin * 2
    static let balloonHeight = balloonWidth / 2

    static let initialBalloonX = trailingMargin + balloonWidth
    static let initialBalloonY = screenSize.height - bottomMargin

    static let balloonCount = 3
    
    private var balloonCycleCount: Int = 0
    private var balloonViews = [BalloonView]()
    
    static let originalProfileSize = CGSize(width: 300, height: 533.5)
    static let originalProfilePoint = CGPoint(x: (screenSize.width - originalProfileSize.width)/2, y: (screenSize.height - originalProfileSize.height)/2)

    private var tutorialView: TutorialView?
    private let profileView = ProfileView(frame: CGRect(origin: FeedViewController.originalProfilePoint, size: FeedViewController.originalProfileSize))
    private var profileBackgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: FeedViewController.screenSize))

    override func viewDidLoad() {
        super.viewDidLoad()

        balloonView.delegate = self
        tutorialView = TutorialView(frame: self.view.frame)
        if let tutorialView = tutorialView {
            tutorialView.delegate = self
            addTutorial(tutorialView: tutorialView)
        }
        profileView.delegate = self
        profileBackgroundView.backgroundColor = ColorPalette.profileBackgroundColor
    }

    private func addTutorial(tutorialView: TutorialView?) {
        guard let tutorialView = tutorialView else {
            return
        }

        view.addSubview(tutorialView)
    }
    
    func makeBalloons(_ count: Int) {
        for i in 0..<count {
            let balloonView = BalloonView(frame: CGRect(x: FeedViewController.initialBalloonX, y: FeedViewController.initialBalloonY, width: 0, height: 0))
            balloonView.textView.accessibilityIdentifier = "balloonText\(i)"
            balloonViews += [balloonView]
            view.addSubview(balloonView)
        }
    }
    
    func startButtonDidTap() {
        makeBalloons(FeedViewController.balloonCount)
        
        for i in 0..<FeedViewController.balloonCount {
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(1.7 * Double(i))
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.animateBalloon(self.balloonViews[i], numberOfBalloon: i)
            }
        }

    }

    private func animateBalloon(_ balloonView: BalloonView, numberOfBalloon: Int) {
        let originBalloonX = FeedViewController.initialBalloonX - FeedViewController.balloonWidth
        let originBalloonY = FeedViewController.initialBalloonY - FeedViewController.balloonHeight

        balloonView.frame = CGRect(x: FeedViewController.initialBalloonX, y: FeedViewController.initialBalloonY, width: 0, height: 0)
        balloonView.layoutIfNeeded()

        let animator = UIViewPropertyAnimator(duration: 5.0, curve: .easeIn, animations: nil)

        let inflateAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .linear) {
            balloonView.frame = CGRect(x: originBalloonX, y: originBalloonY, width: FeedViewController.balloonWidth - 0.1, height: FeedViewController.balloonHeight - 0.1)
            balloonView.layoutIfNeeded()
        }

        func completeInflationAnimator() {
            balloonView.frame.size = CGSize(width: FeedViewController.balloonWidth, height: FeedViewController.balloonHeight)
            balloonView.layoutIfNeeded()
        }

        func flyAnimator() {
            balloonView.frame.origin.y = -FeedViewController.balloonHeight
            balloonView.layoutIfNeeded()
        }

        animator.addAnimations(inflateAnimator.startAnimation)
        animator.addAnimations(completeInflationAnimator, delayFactor: 0.2)
        animator.addAnimations(flyAnimator, delayFactor: 0.2)

        animator.addCompletion {_ in
            self.balloonCycleCount += 1
            if numberOfBalloon == 2 {
                self.balloonCycleCount = 0
            }
            balloonView.layer.zPosition = CGFloat(self.balloonCycleCount)
            self.animateBalloon(balloonView, numberOfBalloon: numberOfBalloon)
        }

        animator.startAnimation()
    }

    func textViewDidTap() {
        view.addSubview(profileBackgroundView)
        view.addSubview(profileView)
    }

    func closeButtonDidTap() {
        profileBackgroundView.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //画面遷移時にURLを設定する実装にひとまずしてある状態
        let vc = segue.destination as? UserFeedViewController
        vc!.userFeedURL = URL(string: "https://www.google.com")
    }
}
