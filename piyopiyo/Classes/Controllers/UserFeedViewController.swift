import UIKit
import WebKit
class UserFeedViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
            avatarImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var feedTableView: UITableView! {
        didSet {
            let cellName = "FeedTableViewCell"
            feedTableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - UITableViewDataSource

extension UserFeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellName = "FeedTableViewCell"

        guard let cell = feedTableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? FeedTableViewCell else {
            return UITableViewCell()
        }

        return cell
    }
}
