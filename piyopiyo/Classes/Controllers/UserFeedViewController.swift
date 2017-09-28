import UIKit
import WebKit
class UserFeedViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var userFeedURL: URL?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myRequest = URLRequest(url: userFeedURL!)
        webView.load(myRequest)      
    }
    
}
