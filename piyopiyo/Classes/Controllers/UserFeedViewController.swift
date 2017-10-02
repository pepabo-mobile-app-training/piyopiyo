import UIKit
import WebKit
class UserFeedViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var userFeedURL: URL?
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backPageBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var forwardPageBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.accessibilityIdentifier = "userFeedWebView"
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let myRequest = URLRequest(url: userFeedURL!)
        webView.load(myRequest)
        checkCanNavigate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backPage(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func forwardPage(_ sender: Any) {
        webView.goForward()
    }
    
    func checkCanNavigate() {
        print(webView.url!.absoluteString)

        backPageBarButtonItem.isEnabled = webView.canGoBack
        forwardPageBarButtonItem.isEnabled = webView.canGoForward
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        checkCanNavigate()
    }

}
