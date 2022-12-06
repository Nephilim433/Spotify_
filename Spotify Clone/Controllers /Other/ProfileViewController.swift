//
//  ProfileViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    private var models = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        fetchProfile()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func fetchProfile() {
        //skipping [weak self] before result
        APICaller.shared.getCurrentUserProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self.updateUI(with: model)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.failedToGetProfile()
                }
            }
        }
    }
    private func updateUI(with model: UserProfile) {
        tableView.isHidden = false
        //configure table models
        models.append("Full Name: \(model.displayName)")
        models.append("Country: \(model.country)")
        models.append("User ID: \(model.id)")
        createTableHeader(with: model.images.first?.url)

        tableView.reloadData()
        print("updateUI , reloadData <<")
    }
    private func createTableHeader(with string: String?) {
        guard let urlString = string , let url = URL(string: urlString) else  {
            return
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5))
        let imageSize : CGFloat = headerView.height/2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFill
        imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "music_note"), completed: nil)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize/2
        tableView.tableHeaderView = headerView
    }

    private func failedToGetProfile() {
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile"
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
}
//MARK: - Table view mathods
extension ProfileViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}
