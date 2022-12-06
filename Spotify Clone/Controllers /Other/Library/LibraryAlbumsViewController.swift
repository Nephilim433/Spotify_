//
//  LibraryAlbumsViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/29/22.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {

//MARK: - iMPLEMENT RELOAD DATA WITH spinner
    private let noAlbumView = ActionLabelView()
    var albums = [LibraryAlbumsResponseItem]()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNoPlaylistsView()
        fetchAlbumData()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noAlbumView.center = view.center
        tableView.frame = view.bounds
    }
    func fetchAlbumData() {

            APICaller.shared.getCurrentUserAlbums { [weak self] result in
                DispatchQueue.main.async {
                switch result {
                case .success(let albums): 
                    self?.albums = albums
                    self?.updateUI()
                case .failure(let error):
                    print(error)
                }
            }
        }

    }
    private func setUpNoPlaylistsView() {
        noAlbumView.configure(with: ActionLabelViewViewModel(text: "You don't have any saved albums yet...", actionTitle: "Browse"))
        noAlbumView.delegate = self
        view.addSubview(noAlbumView)
    }
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }

    private func updateUI() {
        if albums.isEmpty {
            //show label
            noAlbumView.isHidden = false
            tableView.isHidden = true
        } else {
            //show table of actual playlists
            noAlbumView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

extension LibraryAlbumsViewController : ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
}

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }

        let album = albums[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: album.album.name, subTitle: album.album.artists.first?.name ?? "-", imageURL: URL(string: album.album.images.first?.url ?? "")))
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row].album


        let vc = AlbumViewController(album: album)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }

}
