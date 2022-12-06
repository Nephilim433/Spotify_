//
//  CategoryViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/21/22.
//

import UIKit

class CategoryViewController: UIViewController {

    let category : CategoriesItem
    private var playlists = [PlaylistItem]()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout  { _, _ -> NSCollectionLayoutSection in

    //item
    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)))

    item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
    // vertical group
    let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .fractionalWidth(0.4)),
                                                         subitem: item,
                                                         count: 2)
    //horizontal group
    let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .fractionalWidth(0.4)),
                                                             subitem: horizontalGroup,
                                                             count: 1)

    //section
    let section = NSCollectionLayoutSection(group: verticalGroup)
    

    return section
    })

    //MARK: - Init
    init(category: CategoriesItem) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.name
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        APICaller.shared.getCategoryPlaylists(category: category) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self.playlists = playlists
                    self.collectionView.reloadData()
                case .failure(_):
                    break
                }
            }
        }
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

}

extension CategoryViewController :UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else { return UICollectionViewCell() }
        let item = playlists[indexPath.row]
        cell.configure(with: FeaturedPlaylistCellViewModel(name: item.name, artworkURL: URL(string: item.images.first?.url ?? ""), creatorName: item.owner.displayName))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = PlaylistViewController(playlist: playlists[indexPath.row])
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
