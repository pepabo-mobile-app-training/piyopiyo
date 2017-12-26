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
    
    private var recentResetTime: Date?                      //ふきだし初期位置移動時刻
    static let intervalTorelanceRate = 0.23                 //ふきだしアニメーション間隔の許容誤差
    
    static let originalProfileSize = CGSize(width: 300, height: 480)
    static let originalProfilePoint = CGPoint(x: (screenSize.width - originalProfileSize.width)/2, y: (screenSize.height - originalProfileSize.height)/2)

    private var tutorialView: TutorialView?
    
    private var microContents: ContinuityMicroContents = ContinuityTweets(consumerKey: "", consumerSecret: "", oauthToken: "", oauthTokenSecret: "")
    private let profileView = ProfileView(frame: CGRect(origin: FeedViewController.originalProfilePoint, size: FeedViewController.originalProfileSize))

    @IBOutlet weak var profileBackgroundView: UIView! {
        didSet {
            profileBackgroundView.isHidden = true
        }
    }
    
    @IBOutlet weak var grassImageView: UIImageView!
    @IBOutlet weak var hiyokoButton: UIButton!
    @IBOutlet weak var miniHiyokoButton: UIButton!
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
    private var connectionAlertClosed = false

    private var objectionableWords: [String] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        objectionableWords = ObjectionableWords.readTextFile()

        if !UserDefaults.standard.bool(forKey: "startApp") {
            showTutorial()
        } else {
            setupContents(isReset: false)
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
            tutorialView.isFirstTutorial = !UserDefaults.standard.bool(forKey: "startApp")
            addTutorial(tutorialView: tutorialView)
        }
    }
    
    func restartView() {
        if self.isEnterBackground {
            self.isEnterBackground = false
            if self.resetTrigger == ResetBalloonAnimation.none {
                //ふきだしリセットが完了していたら開始を行う
                self.setupBalloons()
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
    
    func initializeTwitterAuthorization(isReset: Bool, handle: @escaping (_ result: Bool) -> Void) {
        if twitterAuthorization == nil {
            let env = ProcessInfo.processInfo.environment
            twitterAuthorization = try? TwitterAuthorization(consumerKey: env["consumerKey"], consumerSecret:  env["consumerSecret"])
        }
        
        if let twitterAuthorization = twitterAuthorization {
            twitterAuthorization.authorize(isReset: isReset, presentFrom: self, handle: handle)
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
    
    func makeBalloons() {
        for i in 0..<FeedViewController.balloonCount {
            let balloonView = BalloonView(frame: CGRect(x: FeedViewController.initialBalloonX, y: FeedViewController.initialBalloonY, width: 0, height: 0))
            balloonView.microContentLabel.accessibilityIdentifier = "balloonText\(i)"
            balloonViews += [balloonView]
            balloonView.delegate = self
            view.addSubview(balloonView)
        }
    }
    
    func setupBalloons() {
        for i in 0..<FeedViewController.balloonCount {
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
            setupContents(isReset: false)
        }
    }
    
    private func setupContents(isReset: Bool) {
        initializeTweets(isReset)
        makeBalloons()
        setupBalloons()

    }

    private func initializeTweets(_ isReset: Bool) {
        let env = ProcessInfo.processInfo.environment
        let defaults = UserDefaults.standard

        self.initializeTwitterAuthorization(isReset: isReset) { _ in
            guard let consumerKey = env["consumerKey"],
                  let consumerSecret = env["consumerSecret"] else {
                    return
            }
            if let oauthToken = defaults.string(forKey: "twitter_key"),
               let oauthTokenSecret = defaults.string(forKey: "twitter_secret") {
                self.microContents = ContinuityTweets(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: oauthToken, oauthTokenSecret: oauthTokenSecret, objectionableWords: self.objectionableWords)
            } else {
                self.microContents = ContinuityTweets(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: "", oauthTokenSecret: "", objectionableWords: self.objectionableWords)
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
        let noConnectionText = "通信中…"

        latestAppearanceBalloonNumber = numberOfBalloon
        balloonCycleCount += 1
        animatingBalloonCount += 1
        balloonView.layer.zPosition = CGFloat(balloonCycleCount)

        balloonView.frame = CGRect(x: FeedViewController.initialBalloonX, y: FeedViewController.initialBalloonY, width: 0, height: 0)
        balloonView.layoutIfNeeded()

        if let tweets = microContents as? ContinuityTweets {
            if !tweets.isAuthorized {
                tweets.isAuthorized = true
                alertResetToken()
            } else if !tweets.isConnected {
                tweets.isConnected = true
                balloonView.microContentLabel.text = noConnectionText
                if !connectionAlertClosed {
                    alertConnection()
                }
            } else {
                balloonView.micropost = microContents.getMicroContent()
            }
        }

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
                        self.recentResetTime = nil
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
                } else if let recentResetTime = self.recentResetTime {
                    let elapsed = Date().timeIntervalSince(recentResetTime) as Double
                    let targetInterval = (self.balloonDuration / Double(FeedViewController.balloonCount))
                    let torelanceSecond = targetInterval * FeedViewController.intervalTorelanceRate
                    if abs(targetInterval - elapsed) > torelanceSecond {
                        self.resetTrigger = .reset
                    }
                }
                self.recentResetTime = Date()
                nextBalloon()
            }
        }

        animator.startAnimation()
    }

    func textViewDidTap(_ microContent: MicroContent?) {
        activityIndicator.startAnimating()
        
        if let microContent = microContent {
            if let tweet = microContent as? Tweet {
                setupProfile(profile: tweet.profile, microContent: tweet)
            }
            activityIndicator.stopAnimating()
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
            self.setupBalloons()
            self.resetTrigger = ResetBalloonAnimation.none
            self.recentResetTime = nil
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
        hideBackgroundView()
        showingUserProfile = profileView.profile

        if let id = showingUserProfile?.userID {
            if let url = URL(string: "twitter://user?id=\(id)") {
                if UIApplication.shared.canOpenURL(url) {
                    prepareViewClosing()
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    let alert: UIAlertController = UIAlertController(title: "ほかのつぶやきを見ることができません", message: "ほかのつぶやきを見るには、Twitterアプリをインストールしてください", preferredStyle:  .alert)
                    let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: nil)
                }
            }
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
        alertInformation()
        resetMiniHiyokoPosition()
    }
    
    func setBalloonUserInteractionEnabled(_ isEnabled: Bool) {
        balloonViews.forEach { (balloonView) in
            balloonView.isUserInteractionEnabled = isEnabled
        }
    }

    private func alertResetToken() {
        let title = "Twitter認証に失敗しました"
        let message = "アプリを使用するためには、Twitterで認証する必要があります。"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.initializeTweets(true)
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func alertConnection() {
        let title = "通信状況が不安定です"
        let message = "ネットワークに接続できる状態にしてください。"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.connectionAlertClosed = true
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    private func alertInformation() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        var message = ""
        if let version = version {
            message = "現在のバージョン \(version)"
        }
        let alert = UIAlertController(title: "ぴよぴよ", message: message, preferredStyle: .alert)
        let information = UIAlertAction(title: "アプリ情報", style: .default, handler: { _ in
            if let url = URL(string: "https://github.com/pepabo-mobile-app-training/piyopiyo") {
            UIApplication.shared.canOpenURL(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }})
        let close = UIAlertAction(title: "閉じる", style: .cancel, handler: nil)
        alert.addAction(information)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
}
