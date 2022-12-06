//
//  SearchViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import UIKit
import SafariServices



class SearchViewController: UIViewController,UISearchResultsUpdating {

    let searchController : UISearchController = {
//        let results = UISearchController()
//        results.view.backgroundColor = .red
        let vc = UISearchController(searchResultsController: SearchResultsViewController())
        vc.searchBar.placeholder = "Songs, Artist, Albums"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()

    private var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

            item.contentInsets = .init(top: 0, leading: 7, bottom: 0, trailing: 7)

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.135)), subitem: item, count: 2)
            //heightDimension: .absolute(130))
            group.contentInsets = .init(top: 7, leading: 7, bottom: 7, trailing: 7)
            return NSCollectionLayoutSection(group: group)
        }))

        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        return collectionView
    }()
//
//    private var collectionView : UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
//        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180)), subitems: [item,item])
//
//        return NSCollectionLayoutSection(group: group)
//    }))
   
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        view.addSubview(collectionView)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground


        
        APICaller.shared.getCategories { result in
            print("getCategories executed")
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self.categoryPlaylists = model
                    self.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                    break
                }
            }
        }
        // Do any additional setup after loading the view.
    
    }
    


    private var categoryPlaylists = [CategoriesItem]()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }


    //MARK: - UpdateSearchResults Method
    func updateSearchResults(for searchController: UISearchController) {
        //MARK: - TODO finish autosearch every 1-2 secs
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
//        resultsController.update(with: results)
        //print(query)
        //perform search

    }

}
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        //print(query)
        //after we created resultsController we assign this vc as delegate
        resultsController.delegate = self

        APICaller.shared.search(with: query) { result in
            print("search executed!")
            switch result {
            case .success(let results):
                //print(results)
                resultsController.update(with: results)
            case .failure(let error):
                print(error)
            }
        }

    }
}
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryPlaylists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = categoryPlaylists[indexPath.row]
        cell.configure(with: CategoryCollectionViewCellViewModel(title: category.name, artWorkURL: URL(string: category.icons.first?.url ?? "")))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        let category = categoryPlaylists[indexPath.row]
        let vc = CategoryViewController(category: category)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - showResult method SearchResultsViewControllerDelegate
extension SearchViewController: SearchResultsViewControllerDelegate {
    func didTapResult(_ result: SearchResult) {
        switch result {
        case .artist(model: let model):
            //don't really like this
            //TODO: change this to normal vc and normal model
            guard let url = URL(string: model.externalUrls.spotify) else {return}
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        case .album(model: let model):
            let vc = AlbumViewController(album: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
        case .playlist(model: let model):
            let vc = PlaylistViewController(playlist: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
        case .track(model: let track):
            PlaybackPresenter.shared.startPlayback(from: self, track: track)
        }
    }
}
