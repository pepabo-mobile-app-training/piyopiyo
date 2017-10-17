//
//  ViewController.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/09/25.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, TutorialDelegate, BalloonViewDelegate, ProfileViewDelegate {

    static let screenSize = UIScreen.main.bounds.size
    static let hiyokoHeight: CGFloat = 100.0
    
    static let trailingMargin: CGFloat = 30.0
    static let bottomMargin = hiyokoHeight + 30
    
    static let balloonWidth = screenSize.width - trailingMargin * 2
    static let balloonHeight = balloonWidth / 2

    static let initialBalloonX = trailingMargin + balloonWidth
    static let initialBalloonY = screenSize.height - bottomMargin

    private var twitterAuthorization: TwitterAuthorization? = nil
    
    static let balloonCount = 3                             //ふきだしViewの個数
    static let resetBalloonCountValue = 100                 //ふきだしアニメーションをリセットするタイミング（ふきだしをいくつアニメーションしたらリセットするか）
    private var resetTriggerBalloonNumber: Int?             //リセットのタイミング（nil以外でリセットをかける）
    private var latestAppearanceBalloonNumber = 0           //さいごに表示を開始したふきだしの番号
    private var balloonDuration: Double = 6.0               //ふきだしアニメーション時間
    
    private var balloonCycleCount: Int = 0
    private var balloonViews = [BalloonView]()
    
    static let originalProfileSize = CGSize(width: 300, height: 390)
    static let originalProfilePoint = CGPoint(x: (screenSize.width - originalProfileSize.width)/2, y: (screenSize.height - originalProfileSize.height)/2)

    private var tutorialView: TutorialView?
    
    private var microposts = ContinuityMicroposts()
    private let profileView = ProfileView(frame: CGRect(origin: FeedViewController.originalProfilePoint, size: FeedViewController.originalProfileSize))

    @IBOutlet weak var profileBackgroundView: UIView! {
        didSet {
            profileBackgroundView.isHidden = true
        }
    }
    
    @IBOutlet weak var hiyokoButton: UIButton!
    @IBOutlet weak var miniHiyokoButton: UIButton!
    
    private var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
            activityIndicator.layer.zPosition = CGFloat(FeedViewController.balloonCount + 3)
        }
    }
    private var showingUserProfile: userProfile?
    
    private var isDismiss = false

    override func viewDidLoad() {
        super.viewDidLoad()

        microposts.fetchMicroposts()

        if !UserDefaults.standard.bool(forKey: "startApp") {
            tutorialView = TutorialView(frame: self.view.frame)
            if let tutorialView = tutorialView {
                tutorialView.delegate = self
                addTutorial(tutorialView: tutorialView)
            }
        } else {
            makeBalloons(FeedViewController.balloonCount)
            setupBalloons(FeedViewController.balloonCount)
        }
        profileView.delegate = self
        activityIndicator = UIActivityIndicatorView()
        view.addSubview(activityIndicator)
        
       
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "もどる", style: .plain, target: nil, action: nil)
    }
    
    func initializeTwitterAuthorization() {
        let env = ProcessInfo.processInfo.environment
        guard let consumerKey = env["consumerKey"], let consumerSecret = env["consumerSecret"] else {
            return
        }
        twitterAuthorization = try? TwitterAuthorization(consumerKey: consumerKey, consumerSecret: consumerSecret)
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
            let balloonDuration = self.balloonDuration
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(balloonDuration / Double(FeedViewController.balloonCount) * Double(i))
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                if self.resetTriggerBalloonNumber != nil {
                    return
                }
                self.animateBalloon(self.balloonViews[i], numberOfBalloon: i, duration: balloonDuration)
            }
        }
    }

    func startButtonDidTap() {
        UserDefaults.standard.set(true, forKey: "startApp")

        makeBalloons(FeedViewController.balloonCount)
        setupBalloons(FeedViewController.balloonCount)
    }
    
    func resetAnimateBalloon() {
        resetTriggerBalloonNumber = latestAppearanceBalloonNumber
        balloonCycleCount = 0
    }

    private func animateBalloon(_ balloonView: BalloonView, numberOfBalloon: Int, duration: Double) {
        let originBalloonX = FeedViewController.initialBalloonX - FeedViewController.balloonWidth
        let originBalloonY = FeedViewController.initialBalloonY - FeedViewController.balloonHeight
        
        latestAppearanceBalloonNumber = numberOfBalloon
        balloonCycleCount += 1
        balloonView.layer.zPosition = CGFloat(balloonCycleCount)

        balloonView.frame = CGRect(x: FeedViewController.initialBalloonX, y: FeedViewController.initialBalloonY, width: 0, height: 0)
        balloonView.layoutIfNeeded()
        
        balloonView.micropost = microposts.getMicropost()

        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: nil)

        let inflateAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut) {
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

        func nextBalloon() {
            if !self.isDismiss {
                self.animateBalloon(balloonView, numberOfBalloon: numberOfBalloon, duration: duration)
            }
        }
        
        animator.addCompletion {_ in
            if let resetTriggerBalloonIndex = self.resetTriggerBalloonNumber {
                if resetTriggerBalloonIndex == numberOfBalloon {
                    self.resetTriggerBalloonNumber = nil
                    self.balloonCycleCount = 0
                    self.setupBalloons(FeedViewController.balloonCount)
                }
            } else if self.balloonCycleCount == (FeedViewController.resetBalloonCountValue - 1) {
                self.resetTriggerBalloonNumber = numberOfBalloon
                nextBalloon()
            } else {
                nextBalloon()
            }
        }

        animator.startAnimation()
    }

    func textViewDidTap(_ micropost: MicroContent?) {
        activityIndicator.startAnimating()
        
        if let micropost = micropost {
            MicropostUserProfile.fetchUserProfile(userID: micropost.userID) { profile in
                self.profileView.profile = profile
                self.activityIndicator.stopAnimating()
                self.view.addSubview(self.profileView)
            }
        }
        profileBackgroundView.isHidden = false

        profileBackgroundView.layer.zPosition = CGFloat(FeedViewController.resetBalloonCountValue + 1)
        profileView.layer.zPosition = CGFloat(FeedViewController.resetBalloonCountValue + 2)
    }

    func closeButtonDidTap() {
        profileBackgroundView.isHidden = true
    }

    @IBAction func profileBackgroundDidTap(_ sender: UITapGestureRecognizer) {
        profileView.removeFromSuperview()
        profileBackgroundView.isHidden = true
    }

    func showUserFeedButtonDidTap() {
        profileBackgroundView.isHidden = true
        isDismiss = true
        showingUserProfile = profileView.profile
        performSegue(withIdentifier: "showUserFeed", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            case let vc as UserFeedViewController:
                guard let showingUserProfile = showingUserProfile else {
                    return
                }

                vc.profile = showingUserProfile
                self.showingUserProfile = nil
            default:
                break
        }
    }
    
    func jumpHiyoko() {
        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeIn, animations: nil)
        
        let jumpingMotion = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.hiyokoButton.layer.position.y -= 20
         }
  
        func landingMotion() {
            self.hiyokoButton.layer.position.y += 20
        }
        animator.addAnimations(jumpingMotion.startAnimation)
        animator.addAnimations(landingMotion, delayFactor: 0.5)

        animator.startAnimation()

    }
    
    @IBAction func hiyokoTapped(_ sender: Any) {
        if balloonDuration >= 9.0 {
            balloonDuration = 3.0
        } else {
            balloonDuration += 3.0
        }
        jumpHiyoko()
        resetAnimateBalloon()
    }
    
    @IBAction func miniHiyokoTapped(_ sender: Any) {
        
    }
    
}
