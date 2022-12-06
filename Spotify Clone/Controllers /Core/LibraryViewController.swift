//
//  LibraryViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import UIKit

class LibraryViewController: UIViewController {

    private let playlistsVC = LibraryPlaylistsViewController()
    private let albumsVC = LibraryAlbumsViewController()

    private let scrollView : UIScrollView = {
        let scollView = UIScrollView()
        scollView.isPagingEnabled = true
        scollView.bounces = true
        return scollView
    }()

    private let toggleView = LibraryToggleView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        toggleView.delegate = self
        scrollView.delegate = self
        view.addSubview(scrollView)
        view.addSubview(toggleView)
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
        addChildren()

        updateBarButtons()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.width, height: view.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-55)

        toggleView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: 200, height: 55)
    }
    private func updateBarButtons() {
        switch toggleView.state {
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddPlaylist))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }
    @objc private func didTapAddPlaylist() {
        playlistsVC.showCreatePlaylistAlert()
    }
    private func addChildren() {
        addChild(playlistsVC)
        scrollView.addSubview(playlistsVC.view)
        playlistsVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        playlistsVC.didMove(toParent: self)

        addChild(albumsVC)
        scrollView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumsVC.didMove(toParent: self)
    }


}

extension LibraryViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width - 100) {
            toggleView.update(for: .album)
            updateBarButtons()
        } else {
            toggleView.update(for: .playlist)
            updateBarButtons()
        }
    }
}

extension LibraryViewController: LibraryToggleViewDelegate {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        updateBarButtons()
    }

    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        updateBarButtons()
    }
}
