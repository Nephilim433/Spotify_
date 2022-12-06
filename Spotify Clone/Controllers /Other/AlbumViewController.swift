//
//  AlbumViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/18/22.
//

import UIKit

class AlbumViewController: UIViewController {
    private let album: Album

    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [Track]()

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
        //item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(1.0)))

        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)

        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(0.08)),subitem: item,count: 1)
        //section
        let section = NSCollectionLayoutSection(group: verticalGroup)
        section.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]

        return section
    }))

    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        //register reusable view
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)

        APICaller.shared.getAlbumsDetails(for: album) { result in
            print("getPlaylistDetails executed")
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    let newTracks = model.tracks.items.filter { $0.preview_url != nil }
                    self.tracks = newTracks
                    //RecommendedTrackCellViewModel
                    self.viewModels = newTracks.compactMap({
                        RecommendedTrackCellViewModel(name: $0.name , artistName: $0.artists?.first?.name ?? "-", artWorkURL: URL(string: model.images.first?.url ?? ""))
                    })
                    self.collectionView.reloadData()
                case .failure(let erorr):
                    print("\(erorr.localizedDescription) -_- error")
                }
            }
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        //adding gesture recognizer
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.addGestureRecognizer(gesture)

    }


    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let touchPoing = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoing) else { return }
        let track = tracks[indexPath.row]

        let addActionSheet = UIAlertController(title: track.name, message: "Would you like to add this song to a playlist?", preferredStyle: .actionSheet)
        addActionSheet.addAction(UIAlertAction(title: "Cencel", style: .cancel, handler: nil))
        addActionSheet.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    APICaller.shared.addTrackToPlaylists(track: track, playlist: playlist) { success in
                        print("Added to a playlist: \(success)")
                    }
                }
                vc.title = "Select playlist"
                self?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            }
        }))
        present(addActionSheet, animated: true, completion: nil)
    }


    @objc private func didTapShare() {
        var activityItems = [Any]()
        if let url2 = URL(string: album.externalUrls?.spotify ?? "") {
            print("url2 = \(url2)")
            activityItems.append(url2)
        }
        DispatchQueue.main.async {
            let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(vc, animated: true, completion: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    

}

extension AlbumViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("viewModels.count = \(viewModels.count)")
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {return UICollectionViewCell()}

        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        collectionView.deselectItem(at: indexPath, animated: true)
        //MARK: - IS this CRENGE?
        let newTracks = tracks.compactMap({ Track(album: self.album, artists: $0.artists, discNumber: $0.discNumber, durationMS: $0.durationMS, explicit: $0.explicit, externalUrls: $0.externalUrls, id: $0.id, name: $0.name, popularity: $0.popularity, preview_url: $0.preview_url, trackNumber: $0.trackNumber, type: $0.type)
        })


        PlaybackPresenter.shared.startPlayback(from: self, tracks: newTracks, at: indexPath.row)
        //play song
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as? PlaylistHeaderCollectionReusableView else { return UICollectionReusableView() }

        let headerViewModel = PlaylistHeaderViewModel(playlistName: album.name, ownerName: album.artists.first?.name, descriptionName: "Release Date: \(String.formattedDate(string: album.releaseDate ))", artworkULR: URL(string: album.images.first?.url ?? ""))

        header.configure(with: headerViewModel)
        header.delegate = self

        return header
    }
}
//MARK: - DidTapPlayAll
extension AlbumViewController : PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        //start playlist play all in queue
        print("playing all")

        let tracksWithAlbums: [Track] = tracks.compactMap {
            var track = $0
            track.album = self.album
            return track
        }

        if !tracksWithAlbums.isEmpty {
            PlaybackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbums)
        } else {

            let alert = UIAlertController(title: "oh no!", message: "Whoops, seems like this album doesn't have any preview song", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert,animated: true)
            print("tracksWithAlbums is empty...")
        }
    }
}
