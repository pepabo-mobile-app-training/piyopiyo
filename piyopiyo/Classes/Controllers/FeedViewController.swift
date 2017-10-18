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

    private var twitterAuthorization: TwitterAuthorization?
    
    static let balloonCount = 3                             //ふきだしViewの個数
    static let resetBalloonCountValue = 100                 //ふきだしアニメーションをリセットするタイミング（ふきだしをいくつアニメーションしたらリセットするか）
    
    enum MicroContentType {
        case micropost
        case twitter
    }
    private var microContentType: MicroContentType = MicroContentType.micropost
    
    enum ResetBalloonAnimation {
        case reset                                          //ふきだしループのリセット
        case cancel                                         //ふきだしループの停止
        case none                                           //リセットフラグなし（既定値）
    }
    
    private var resetTrigger: ResetBalloonAnimation = ResetBalloonAnimation.none                  //アニメーションのリセットフラグ
    private var animatingBalloonCount = 0                   //アニメーション再生中のふきだし数
    private var latestAppearanceBalloonNumber = 0           //さいごに表示を開始したふきだしの番号
    private var balloonDuration: Double = 6.0               //ふきだしアニメーション時間
    private var balloonCycleCount: Int = 0
    private var pendingSetupBalloonCount: Int = 0           //アニメーション再生待ち吹き出し数
    private var balloonViews = [BalloonView]()
    private var isEnterBackground: Bool = false             //バックグラウンド中かどうか
    
    static let originalProfileSize = CGSize(width: 300, height: 480)
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
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "もどる", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver (
            forName: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil,
            queue: OperationQueue.main,
            using: { _ in
               self.restartView()
            })
        
        NotificationCenter.default.addObserver (
            forName:NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil,
            queue: OperationQueue.main,
            using: { _ in
                self.prepareViewClosing()
            })
    }
    
    func restartView() {
        if self.isEnterBackground {
            self.isEnterBackground = false
            if self.resetTrigger == ResetBalloonAnimation.none {
                //ふきだしリセットが完了していたら開始を行う
                self.setupBalloons(FeedViewController.balloonCount)
            } else {
                //ふきだしキャンセル完了前ならふきだしループをリセットする
                self.resetAnimateBalloon()
            }
        }
    }
    
    func prepareViewClosing() {
        self.resetTrigger = ResetBalloonAnimation.cancel
        self.isEnterBackground = true
    }
    
    func initializeTwitterAuthorization(handle: @escaping (_ result: Bool) -> Void) {
        if twitterAuthorization == nil {
            let env = ProcessInfo.processInfo.environment
            twitterAuthorization = try? TwitterAuthorization(consumerKey: env["consumerKey"], consumerSecret:  env["consumerSecret"])
        }
        
        if let twitterAuthorization = twitterAuthorization {
            twitterAuthorization.authorize(presentFrom: self, handle: handle)
        } else {
            handle(false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
        restartView()
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
            pendingSetupBalloonCount += 1
            let balloonDuration = self.balloonDuration
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(balloonDuration / Double(FeedViewController.balloonCount) * Double(i))
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.pendingSetupBalloonCount -= 1
  
                switch self.resetTrigger {
                case .none:
                     self.animateBalloon(self.balloonViews[i], numberOfBalloon: i, duration: balloonDuration)
                case .reset:
                    if self.pendingSetupBalloonCount == 0 {
                        //ふきだしアニメーション開始待機中にリセットがかかった場合はリセットをかける
                        self.restartAnimation()
                    }
                case .cancel:
                    if self.pendingSetupBalloonCount == 0 {
                        self.resetTrigger = ResetBalloonAnimation.none
                    }
                }
            }
        }
    }
    
    func startButtonDidTap() {
        UserDefaults.standard.set(true, forKey: "startApp")

        makeBalloons(FeedViewController.balloonCount)
        setupBalloons(FeedViewController.balloonCount)
    }
    
    func resetAnimateBalloon() {
        resetTrigger = ResetBalloonAnimation.reset
        balloonCycleCount = 0
    }

    private func animateBalloon(_ balloonView: BalloonView, numberOfBalloon: Int, duration: Double) {
        let originBalloonX = FeedViewController.initialBalloonX - FeedViewController.balloonWidth
        let originBalloonY = FeedViewController.initialBalloonY - FeedViewController.balloonHeight
        
        latestAppearanceBalloonNumber = numberOfBalloon
        balloonCycleCount += 1
        animatingBalloonCount += 1
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
            self.animateBalloon(balloonView, numberOfBalloon: numberOfBalloon, duration: duration)
        }
        
        animator.addCompletion {_ in
            self.animatingBalloonCount -= 1
            
            switch self.resetTrigger {
            case .cancel:
                //キャンセル処理の場合はアニメーション終了後にキャンセル処理を行う
                if self.animatingBalloonCount == 0 {
                    if self.pendingSetupBalloonCount == 0 {
                        self.resetTrigger = ResetBalloonAnimation.none
                    }
                    self.balloonCycleCount = 0
                }
            case .reset:
                //リセット処理の場合はアニメーション終了後に再開する
                self.restartAnimation()
            default:
                if self.balloonCycleCount == (FeedViewController.resetBalloonCountValue - 1) {
                    //リセット条件を満たした場合（ふきだしカウンタが閾値を超えたら）リセットフラグを立てる
                    self.resetTrigger = ResetBalloonAnimation.reset
                }
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
                self.profileView.microContent = micropost
                self.activityIndicator.stopAnimating()
                self.view.addSubview(self.profileView)
            }
        }
        profileBackgroundView.isHidden = false
        setBalloonUserInteractionEnabled(false)

        profileBackgroundView.layer.zPosition = CGFloat(FeedViewController.resetBalloonCountValue + 1)
        profileView.layer.zPosition = CGFloat(FeedViewController.resetBalloonCountValue + 2)
    }
    
    func restartAnimation() {
        if self.animatingBalloonCount == 0  && self.pendingSetupBalloonCount == 0 {
            self.balloonCycleCount = 0
            self.setupBalloons(FeedViewController.balloonCount)
            self.resetTrigger = ResetBalloonAnimation.none
        }
    }

    func closeButtonDidTap() {
        profileBackgroundView.isHidden = true
        setBalloonUserInteractionEnabled(true)
    }

    @IBAction func profileBackgroundDidTap(_ sender: UITapGestureRecognizer) {
        profileView.removeFromSuperview()
        profileBackgroundView.isHidden = true
        setBalloonUserInteractionEnabled(true)
    }

    func showUserFeedButtonDidTap() {
        prepareViewClosing()
        profileBackgroundView.isHidden = true
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
        switch microContentType {
        case .micropost:
            microContentType = MicroContentType.twitter
            initializeTwitterAuthorization { result in
                if !result {
                    self.microContentType = MicroContentType.micropost
                }
            }
        case .twitter:
            microContentType = MicroContentType.micropost
        }
    }
    
    func setBalloonUserInteractionEnabled(_ isEnabled: Bool) {
        balloonViews.forEach { (balloonView) in
            balloonView.isUserInteractionEnabled = isEnabled
        }
    }
    
}
