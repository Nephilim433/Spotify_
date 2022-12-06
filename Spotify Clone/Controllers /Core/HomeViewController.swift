//
//  HomeViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.


import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel])
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel])
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel])

    var title: String {
        switch self {
        case .newReleases:
            return "New Released Albums"
        case .featuredPlaylists:
            return "Featured Playlists"
        case .recommendedTracks:
            return "Recommended Tracks"
        }
    }
}

class HomeViewController: UIViewController {
    
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection in
        return HomeViewController.createSectionLayout(section: sectionIndex)
    })
    
    private let spinner : UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    private var sections = [BrowseSectionType]()

    var newAlbums = [Album]()
    var playlists = [PlaylistItem]()
    var tracks = [Track]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        // Do any additional setup after loading the view.
        fetchData()
        configureCollectionView()
        view.addSubview(spinner)

        addLongPressGesture()
        //tests
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    private func addLongPressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let touchPoint = gesture.location(in: collectionView)
        print(touchPoint)

        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else {return}
        //indexPath.section == 2 else { return }

        switch indexPath.section {
        case 0:
            let album = newAlbums[indexPath.row]
            let actionSheet = UIAlertController(title: album.name, message: "Would you like to save this album to your library?", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Cencel", style: .cancel, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
                print("Trying to add album!")
                DispatchQueue.main.async {
                    //APi CALL
                    APICaller.shared.saveAlbum(album: album) { success in
                        print("Saved:\(success)")
                    }

                }
            }))
            present(actionSheet, animated: true)
        case 1:
            break
//            let playlist = playlists[indexPath.row]
//            let actionSheet = UIAlertController(title: playlist.name, message: "Would you like to save this playlist to your library?", preferredStyle: .actionSheet)
//            actionSheet.addAction(UIAlertAction(title: "Cencel", style: .cancel, handler: nil))
//            actionSheet.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
//                DispatchQueue.main.async {
//
////                        APICaller.shared.savePlaylist(playlist: playlist) { success in
////                            print("Saved playlist: \(success)")
////                            //MARK: - add here a popup massege to notigy that playlist is saved!
////                        }
//                    print("Trying to add playlist!")
//                }
//            }))
//            present(actionSheet, animated: true, completion: nil)

        case 2:
            let track = tracks[indexPath.row]

            let actionSheet = UIAlertController(title: track.name, message: "Would you like to add this song to a playlist?", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Cencel", style: .cancel, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
                DispatchQueue.main.async {

                    let vc = LibraryPlaylistsViewController()
                    vc.selectionHandler = { playlist in
                        APICaller.shared.addTrackToPlaylists(track: track, playlist: playlist) { success in
                            print("Added to a playlist: \(success)")
                        }
                    }
                    vc.title = "Select playlist"
                    self?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        //            self.navigationController?.pushViewController(vc, animated: true)

                }
            }))
            present(actionSheet, animated: true, completion: nil)
        default:
            break
        }


    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
    }
    
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        let supplementaryViews = [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
        //MARK: - change it later so it matches the real spotify app design
        //group
        switch section {
        case 0:
            //the top collection
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            // vertical group
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(360)), subitem: item, count: 3)

            //horizontal group
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(360)), subitem: verticalGroup, count: 1)
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            //adding header for every section
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
        case 1:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            // vertical group
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(150),
                heightDimension: .absolute(300)),
                                                                 subitem: item,
                                                                 count: 2)
            //horizontal group
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(150),
                heightDimension: .absolute(300)),
                                                                     subitem: verticalGroup,
                                                                     count: 1)
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            //adding header for every section
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
        case 2:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.1)),
                subitem: item,
                count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: verticalGroup)
            //adding header for every section
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
        default:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //default
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(360)), subitem: item, count: 3)
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        // vertical group in horizontal group
        
        //        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(360)), subitem: item, count: 3)
        //
        //        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390)), subitem: verticalGroup, count: 1)
        //        //section
        //        let section = NSCollectionLayoutSection(group: horizontalGroup)
        //        section.orthogonalScrollingBehavior = .groupPaging
        //        return section
    }
    
    private func fetchData() {

        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        print("Start Fetching data...")
        var newReleases: NewReleasesResponse?
        var featuredPlaylist : FeaturedPlaylistResponse?
        var recommendations: [Track]?

        // what are we getting?
        // New Releases
        APICaller.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                newReleases = model
                print("getNewReleases succes <<<<<<<")
            case .failure(let error):
                print(error)

            }
        }
        // Featured Playlists
        APICaller.shared.getFeaturedPlaylist { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                featuredPlaylist = model
                print("getFeaturedPlaylist succes<<<<<<<")

            case .failure(let error):
                print(error)

            }
        }
        //Recommended tracks
        APICaller.shared.getRecommendedGanres { result in
            switch result {
            case .success(let model):
                print("YYE succes")
                let genras = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let randomElement = genras.randomElement() {
                        seeds.insert(randomElement)
                    }
                    
                }

                APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in
                    defer {
                        group.leave()
                    }
                    switch recommendedResult {
                    case .success(let model):
                        recommendations = model
                    case .failure(let error):
                        print(error)
                    }
                }

            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }

        group.notify(queue:.main) {
            guard let newAlbums = newReleases?.albums.items,
                  let playlists = featuredPlaylist?.playlists.items,
                  let tracks = recommendations else {
                      fatalError("Models are nil")
                  }
            print("Configuring viewModels")
            self.configureModels(newAlbums: newAlbums, playlists: playlists, tracks: tracks)
        }
    }

    //MARK: - configure models
    private func configureModels(newAlbums: [Album],playlists: [PlaylistItem], tracks:[Track] ) {
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks

        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(name: $0.name,
                                            artworkURL: URL(string: $0.images.first?.url ?? "-"),
                                            numberOfTrack: $0.totalTracks,
                                            artistName: $0.artists.first?.name ?? "-")
        })))

        sections.append(.featuredPlaylists(viewModels: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(name: $0.name, artworkURL: URL(string: $0.images.first?.url ?? ""), creatorName: $0.owner.displayName)
        })))

        sections.append(.recommendedTracks(viewModels: tracks.compactMap({
            return RecommendedTrackCellViewModel(name: $0.name , artistName: $0.artists?.first?.name ?? "none", artWorkURL: URL(string: $0.album?.images.first?.url ?? "-"))
        })))

        collectionView.reloadData()
    }
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .newReleases(let viewModels):

            return viewModels.count
        case .featuredPlaylists(let viewModels):

            return viewModels.count
        case .recommendedTracks(let viewModels):
            
            return viewModels.count
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.impact()
        let section = sections[indexPath.section]
        switch section {
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.navigationItem.largeTitleDisplayMode = .never
            
            navigationController?.pushViewController(vc, animated: true)
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks, at: indexPath.row)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as? NewReleaseCollectionViewCell else { return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
        case .featuredPlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else { return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)

            return cell
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else { return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
        }

    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView else { return UICollectionReusableView() }
        let section = indexPath.section
        let title = sections[section].title
        header.configure(with: title)
        
        return header
    }
}
