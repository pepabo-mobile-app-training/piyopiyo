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
    
    private var microposts = ContinuityMicroposts()
    private let profileView = ProfileView(frame: CGRect(origin: FeedViewController.originalProfilePoint, size: FeedViewController.originalProfileSize))
    private var profileBackgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: FeedViewController.screenSize))
    private var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
            activityIndicator.layer.zPosition = CGFloat(FeedViewController.balloonCount + 3)
        }
    }
    private var showingUserProfile: UserProfile?
    
    private var isDismiss = false

    override func viewDidLoad() {
        super.viewDidLoad()

        microposts.fetchMicroposts()
        tutorialView = TutorialView(frame: self.view.frame)
        if let tutorialView = tutorialView {
            tutorialView.delegate = self
            addTutorial(tutorialView: tutorialView)
        }
        profileView.delegate = self
        profileBackgroundView.backgroundColor = ColorPalette.profileBackgroundColor
        activityIndicator = UIActivityIndicatorView()
        view.addSubview(activityIndicator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)

        if isDismiss {
            setupBalloons(FeedViewController.balloonCount)
            isDismiss = false
        }
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
            balloonView.delegate = self
            view.addSubview(balloonView)
        }
    }
    
    func setupBalloons(_ count: Int) {
        for i in 0..<count {
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(1.7 * Double(i))
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.animateBalloon(self.balloonViews[i], numberOfBalloon: i)
            }
        }
    }

    func startButtonDidTap() {
        makeBalloons(FeedViewController.balloonCount)
        setupBalloons(FeedViewController.balloonCount)
    }

    private func animateBalloon(_ balloonView: BalloonView, numberOfBalloon: Int) {
        let originBalloonX = FeedViewController.initialBalloonX - FeedViewController.balloonWidth
        let originBalloonY = FeedViewController.initialBalloonY - FeedViewController.balloonHeight

        balloonView.frame = CGRect(x: FeedViewController.initialBalloonX, y: FeedViewController.initialBalloonY, width: 0, height: 0)
        balloonView.layoutIfNeeded()
        
        balloonView.micropost = microposts.getMicropost()

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

            if !self.isDismiss {
                self.animateBalloon(balloonView, numberOfBalloon: numberOfBalloon)
            }
        }

        animator.startAnimation()
    }

    func textViewDidTap(_ micropost: Micropost?) {
        activityIndicator.startAnimating()
        
        if let micropost = micropost {
            UserProfile.fetchUserProfile(userID: micropost.userID) { profile in
                self.profileView.profile = profile
                self.activityIndicator.stopAnimating()
                self.view.addSubview(self.profileView)
            }
        }
        view.addSubview(profileBackgroundView)

        profileBackgroundView.layer.zPosition = CGFloat(FeedViewController.balloonCount + 1)
        profileView.layer.zPosition = CGFloat(FeedViewController.balloonCount + 2)
    }

    func closeButtonDidTap() {
        profileBackgroundView.removeFromSuperview()
    }

    func showUserFeedButtonDidTap() {
        profileBackgroundView.removeFromSuperview()
        isDismiss = true
        showingUserProfile = profileView.profile
        performSegue(withIdentifier: "showUserFeed", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let showingUserProfile = showingUserProfile else {
            return
        }
        let vc = segue.destination as? UserFeedViewController
        vc!.userFeedURL = APIClient.userFeedURL(showingUserProfile)
        showingUserProfile = nil
    }
}
