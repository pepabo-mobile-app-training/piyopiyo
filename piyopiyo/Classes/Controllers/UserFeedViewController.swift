import UIKit
import SDWebImage

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
    
    var profile: UserProfile?
    var microposts = [Micropost]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let profile = profile {
            fetchProfile(profile: profile)
            Micropost.fetchUsersMicroposts(userID: profile.userID) { microposts in
                self.microposts = microposts
                self.feedTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func fetchProfile(profile: UserProfile) {
        nameLabel.text = profile.name
        avatarImageView.sd_setImage(with: profile.avatarURL, placeholderImage: UIImage(named: "avatar"))
    }
}

// MARK: - UITableViewDataSource

extension UserFeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return microposts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellName = "FeedTableViewCell"

        guard let cell = feedTableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? FeedTableViewCell, let profile = profile else {
            return UITableViewCell()
        }

        cell.update(profile: profile, micropost: microposts[indexPath.row])
        return cell
    }
}
