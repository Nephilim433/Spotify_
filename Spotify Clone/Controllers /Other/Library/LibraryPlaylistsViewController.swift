//
//  LibraryPlaylistsViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/29/22.
//
//TODO FIX switching ANIMaTION IN LIBRARY

import UIKit

class LibraryPlaylistsViewController: UIViewController {
    var selectionHandler : ((PlaylistItem) -> Void)?

    private let noPlaylistView = ActionLabelView()
    var playlists = [PlaylistItem]()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNoPlaylistsView()
        fetchPlaylistData()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlaylistView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlaylistView.center = view.center

        tableView.frame = view.bounds
    }
    func fetchPlaylistData() {
            APICaller.shared.getCurrentUserPlaylists { [weak self] result in
                DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.updateUI()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    private func setUpNoPlaylistsView() {
        noPlaylistView.configure(with: ActionLabelViewViewModel(text: "You don't have any playlists yet...", actionTitle: "Create"))
        noPlaylistView.delegate = self
        view.addSubview(noPlaylistView)
    }
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    @objc func didTapAdd() {
        showCreatePlaylistAlert()
    }

    private func updateUI() {
        if playlists.isEmpty {
            //show label
            noPlaylistView.isHidden = false
            tableView.isHidden = true
        } else {
            //show table of actual playlists
            tableView.reloadData()
            noPlaylistView.isHidden = true
            tableView.isHidden = false
        }
    }
    public func showCreatePlaylistAlert() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter playlist name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Your Coolest Playlist"
        }
        alert.addAction(UIAlertAction(title: "Cencel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let field = alert.textFields?.first?.text, !field.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            APICaller.shared.createPlaylists(with: field) { [weak self] success in
                DispatchQueue.main.async {
                    if success {
                        //refresh playlist
                        HapticsManager.shared.vibrate(for: .success)
                        self?.tableView.reloadData()
                        self?.fetchPlaylistData()
                    } else {
                        HapticsManager.shared.vibrate(for: .error)
                        print("Failed to crate a playlist ")
                    }
                }
            }
        }))
        present(alert,animated: true)
    }
}

extension LibraryPlaylistsViewController : ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
}
extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }

        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: playlist.name, subTitle: playlist.owner.displayName, imageURL: URL(string: playlist.images.first?.url ?? "")))
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let playlist = playlists[indexPath.row]

        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true, completion: nil)
            return
        }
        let vc = PlaylistViewController(playlist: playlist)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
