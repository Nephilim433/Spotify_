//
//  SearchResultsViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/21/22.
//

import UIKit

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultsViewController: UIViewController {

    weak var delegate : SearchResultsViewControllerDelegate?
    private var sections = [SearchSection]()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemBackground
        tableView.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)

        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func update(with results:[SearchResult]) {
        DispatchQueue.main.async {
//            let artists = results.filter {
//                switch $0 {
//                case .artist:
//                return true
//                default: return false
//
//                }
//            }
//            let tracks = results.filter {
//                switch $0 {
//                case .track: return true
//                default: return false
//
//                }
//            }
//            let playlists = results.filter {
//                switch $0 {
//                case .playlist: return true
//                default: return false
//
//                }
//            }
//            let albums = results.filter {
//                switch $0 {
//                case .album: return true
//                default: return false
//
//                }
//            }

            var artists: [SearchResult] = []
            var albums: [SearchResult] = []
            var playlists: [SearchResult] = []
            var tracks: [SearchResult] = []

            results.forEach { searchResult in
                switch searchResult {
                case .artist:
                    artists.append(searchResult)
                case .album:
                    albums.append(searchResult)
                case .playlist:
                    playlists.append(searchResult)
                case .track:
                    tracks.append(searchResult)
                }
            }
            self.sections = [
                SearchSection(title: "Songs", results: tracks),
                SearchSection(title: "Artists", results: artists),
                SearchSection(title: "Playlists", results: playlists),
                SearchSection(title: "Albums", results: albums)]

            self.tableView.isHidden = results.isEmpty
            //very smart
            self.tableView.reloadData()
        }
    }

}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let result = sections[indexPath.section].results[indexPath.row]
        switch result {
            //artist
        case .artist(model: let artist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else { return UITableViewCell() }
            cell.configure(with: SearchResultDefaultTableViewCellViewModel(title: artist.name, imageURL: URL(string: artist.images?.first?.url ?? "")))
            return cell
            //album
        case .album(model: let album):
            guard let subCell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
            subCell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: album.name, subTitle: album.artists.first?.name ?? "", imageURL: URL(string: album.images.first?.url ?? "")))
            return subCell
            //playlist
        case .playlist(model: let playlist):
            guard let subCell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
            subCell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: playlist.name, subTitle: playlist.owner.displayName, imageURL: URL(string: playlist.images.first?.url ?? "")))
            subCell.layoutIfNeeded()
            return subCell
            //track
        case .track(model: let track):
            guard let subCell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
            subCell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: track.name, subTitle: track.artists?.first?.name ?? "", imageURL: URL(string: track.album?.images.first?.url ?? "")))
            subCell.layoutIfNeeded()
            return subCell

        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let result = sections[indexPath.section].results[indexPath.row]
        switch result {
        case .artist(model: _):
            return 100
        case .album(model: _):
            return 69
        case .playlist(model: _):
            return 69
        case .track(model: _):
            return 55
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        //using delegate to push vc from another SearchViewController
        delegate?.didTapResult(result)
    }
}
