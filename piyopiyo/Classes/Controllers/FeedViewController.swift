//
//  ViewController.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/09/25.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, TutorialDelegate, BalloonViewDelegate, ProfileViewDelegate, MenuViewDelegate {

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
    private var microContentType: MicroContentType = .twitter
    
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
    
    private var microContents: ContinuityMicroContents = ContinuityMicroposts()
    private let profileView = ProfileView(frame: CGRect(origin: FeedViewController.originalProfilePoint, size: FeedViewController.originalProfileSize))

    @IBOutlet weak var profileBackgroundView: UIView! {
        didSet {
            profileBackgroundView.isHidden = true
        }
    }
    
    @IBOutlet weak var grassImageView: UIImageView!
    @IBOutlet weak var hiyokoButton: UIButton!
    @IBOutlet weak var miniHiyokoButton: UIButton!
    @IBOutlet weak var switchingClientButton: UIButton!
    @IBOutlet weak var menuView: MenuView! {
        didSet {
            menuView.isHidden = true
            menuView.delegate = self
        }
    }
    
    private var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
            activityIndicator.layer.zPosition = CGFloat(FeedViewController.resetBalloonCountValue + 3)
        }
    }
    private var showingUserProfile: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !UserDefaults.standard.bool(forKey: "startApp") {
            showTutorial()
        } else {
            setupContents(FeedViewController.balloonCount)
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
               self.setBalloonUserInteractionEnabled(true)
            })
        
        NotificationCenter.default.addObserver (
            forName:NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil,
            queue: OperationQueue.main,
            using: { _ in
                self.prepareViewClosing()
            })
    }
    
    func showTutorial() {
        tutorialView = TutorialView(frame: self.view.frame)
        if let tutorialView = tutorialView {
            tutorialView.delegate = self
            addTutorial(tutorialView: tutorialView)
        }
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
        tutorialView.layer.zPosition = CGFloat(FeedViewController.resetBalloonCountValue + 1)
        view.addSubview(tutorialView)
    }
    
    func makeBalloons(_ count: Int) {
        for i in 0..<count {
            let balloonView = BalloonView(frame: CGRect(x: FeedViewController.initialBalloonX, y: FeedViewController.initialBalloonY, width: 0, height: 0))
            balloonView.microContentLabel.accessibilityIdentifier = "balloonText\(i)"
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
        //初回起動時のみアニメーションが再生されていない状態なのでアニメーションを開始する
        if !UserDefaults.standard.bool(forKey: "startApp") {
            UserDefaults.standard.set(true, forKey: "startApp")
            setupContents(FeedViewController.balloonCount)
        }
    }

    private func setupContents(_ count: Int) {
        initializeTweets()
        makeBalloons(count)
        setupBalloons(count)
    }

    private func initializeTweets() {
        let env = ProcessInfo.processInfo.environment
        let defaults = UserDefaults.standard

        self.initializeTwitterAuthorization { result in
            if result {
                self.microContentType = MicroContentType.twitter
                if let consumerKey = env["consumerKey"],
                    let consumerSecret = env["consumerSecret"],
                    let oauthToken = defaults.string(forKey: "twitter_key"),
                    let oauthTokenSecret = defaults.string(forKey: "twitter_secret") {
                    self.microContents = ContinuityTweets(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: oauthToken, oauthTokenSecret: oauthTokenSecret)
                    self.restartView()
                }
            } else {
                self.microContentType = MicroContentType.micropost
            }
        }
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
        
        balloonView.micropost = microContents.getMicroContent()

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

    func textViewDidTap(_ microContent: MicroContent?) {
        activityIndicator.startAnimating()
        
        if let microContent = microContent {
            switch microContentType {
            case .twitter:
                if let tweet = microContent as? Tweet {
                    setupProfile(profile: tweet.profile, microContent: tweet)
                }
                activityIndicator.stopAnimating()
            case .micropost:
                MicropostUserProfile.fetchUserProfile(userID: microContent.userID) { profile in
                    self.setupProfile(profile: profile, microContent: microContent)
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        showBackgroundView()
        profileView.layer.zPosition = CGFloat(FeedViewController.resetBalloonCountValue + 2)
    }
    
    func showBackgroundView() {
        profileBackgroundView.isHidden = false
        setBalloonUserInteractionEnabled(false)
        profileBackgroundView.layer.zPosition = CGFloat(FeedViewController.resetBalloonCountValue + 1)
    }
    
    func hideBackgroundView() {
        profileBackgroundView.isHidden = true
        setBalloonUserInteractionEnabled(true)
        activityIndicator.stopAnimating()                   //読み込み中インジケータが表示されたままになることを防ぐために実行
    }

    private func setupProfile(profile: UserProfile, microContent: MicroContent) {
        profileView.profile = profile
        profileView.microContent = microContent
        view.addSubview(profileView)
    }

    func restartAnimation() {
        if self.animatingBalloonCount == 0  && self.pendingSetupBalloonCount == 0 {
            self.balloonCycleCount = 0
            self.setupBalloons(FeedViewController.balloonCount)
            self.resetTrigger = ResetBalloonAnimation.none
        }
    }

    func closeButtonDidTap() {
        hideBackgroundView()
    }

    @IBAction func profileBackgroundDidTap(_ sender: UITapGestureRecognizer) {
        if profileView.isDescendant(of: self.view) {
            profileView.removeFromSuperview()
        } else if !menuView.isHidden {
            menuView.isHidden = true
            resetMiniHiyokoPosition()
        }
        hideBackgroundView()
    }

    func showUserFeedButtonDidTap() {
        prepareViewClosing()
        profileBackgroundView.isHidden = true
        showingUserProfile = profileView.profile

        switch microContentType {
        case .twitter:
            if let id = showingUserProfile?.userID {
                if let url = URL(string: "twitter://user?id=\(id)") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        case .micropost:
            performSegue(withIdentifier: "showUserFeed", sender: nil)
        }
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
        showBackgroundView()
        menuView.isHidden = false
        menuView.layer.zPosition = CGFloat(FeedViewController.resetBalloonCountValue + 2)
        miniHiyokoButton.layer.zPosition += CGFloat(FeedViewController.resetBalloonCountValue + 3)
        grassImageView.layer.zPosition += CGFloat(FeedViewController.resetBalloonCountValue + 4)
    }
    
    func resetMiniHiyokoPosition() {
        miniHiyokoButton.layer.zPosition -= CGFloat(FeedViewController.resetBalloonCountValue + 3)
        grassImageView.layer.zPosition -= CGFloat(FeedViewController.resetBalloonCountValue + 4)
    }
    
    func closeMenuButtonDidTap() {
        hideBackgroundView()
        resetMiniHiyokoPosition()
    }
    
    func showTutorialButtonDidTap() {
        hideBackgroundView()
        resetMiniHiyokoPosition()
        showTutorial()
    }
    
    func showAppInformationButtonDidTap() {
        hideBackgroundView()
        resetMiniHiyokoPosition()
    }
    
    @IBAction func switchingClientButtonTapped(_ sender: Any) {
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
