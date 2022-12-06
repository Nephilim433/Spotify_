//
//  PlaylistViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import UIKit

class PlaylistViewController: UIViewController {
    private let playlist: PlaylistItem
    public var isOwner = false 


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

    init(playlist: PlaylistItem) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [Track]()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        //register reusable view
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)

        APICaller.shared.getPlaylistDetails(for: playlist) { result in
            print("getPlaylistDetails executed")
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self.tracks = model.compactMap({ $0.track })
                    self.viewModels = model.compactMap({ RecommendedTrackCellViewModel(name: $0.track.name , artistName: $0.track.artists?.first?.name ?? "-", artWorkURL: URL(string: $0.track.album?.images.first?.url ?? ""))
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

        let deleteActionSheet = UIAlertController(title: "\(track.name) - \(track.artists?.first?.name ?? "")", message: "Remove this song from playlist?", preferredStyle: .actionSheet)
        deleteActionSheet.addAction(UIAlertAction(title: "Cencel", style: .cancel, handler: nil))
        deleteActionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            [weak self] _ in
            guard let strongSelf = self else { return }
                APICaller.shared.removeTrackFromPlaylists(track: track, playlist: strongSelf.playlist) { success in
                    DispatchQueue.main.async {
                        strongSelf.tracks.remove(at: indexPath.row)
                        strongSelf.viewModels.remove(at: indexPath.row)
                        strongSelf.collectionView.reloadData()
                        print("Removed from playlist: \(success)")
                    }
                }
        }))

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

        if self.isOwner == true {
            present(deleteActionSheet, animated: true)
        } else {
            present(addActionSheet, animated: true, completion: nil)
        }
    }

    @objc private func didTapShare() {

        var activityItems = [Any]()
        if let url2 = URL(string: playlist.externalUrls?.spotify ?? "something went wrogn") {
            print("url 2 = \(url2)")
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
//MARK: - CollectionView Delegate and DataSource Methods

extension PlaylistViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {return UICollectionViewCell()}
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks, at: indexPath.row)
        //play song
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as? PlaylistHeaderCollectionReusableView else { return UICollectionReusableView() }

        let headerViewModel = PlaylistHeaderViewModel(playlistName: playlist.name, ownerName: playlist.owner.displayName, descriptionName: playlist.itemDescription?.description, artworkULR: URL(string: playlist.images.first?.url ?? ""))
        
        header.configure(with: headerViewModel)
        header.delegate = self

        return header
    }
}
//MARK: - DidTapPlayAll

extension PlaylistViewController : PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        //start playlist play all in queue
        print("playing all")
        if !tracks.isEmpty {
            PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks)
        } else {
            let alert = UIAlertController(title: "oh no!", message: "Whoops, seems like this album doesn't have any preview song", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert,animated: true)
            print("tracksWithAlbums is empty...")
        }
    }
}
