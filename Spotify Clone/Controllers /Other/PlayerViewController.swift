//
//  PlayerViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapNext()
    func didTapBack()
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {

    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let controlsView = PlayerControlsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        configureBarButtons()

        configureWithDataSource()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        let oldHeight = view.height-imageView.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-15
        //213
        print("oldHeight = \(oldHeight)")
        controlsView.frame = CGRect(x: 10, y: imageView.bottom+10, width: view.width-20, height: oldHeight)
    }
    private func configureBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
        navigationItem.rightBarButtonItem?.tintColor = .label
    }

    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapAction() {

        var activityItems = [Any]()
        DispatchQueue.main.async {

            if let url = self.dataSource?.externalURL {
                activityItems.append(url)
            }
            let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(vc, animated: true, completion: nil)
        }
    }

    func configureWithDataSource() {
        DispatchQueue.main.async {
            self.imageView.sd_setImage(with: self.dataSource?.imageURL, placeholderImage: UIImage(named: "music_note"), completed: nil)
            self.controlsView.configure(with: PlayerControlsViewViewModel(title: self.dataSource?.songName, subtitle: self.dataSource?.subtitle, seconds: self.dataSource?.duration))
        }
    }
    func resfreshUI() {
        configureWithDataSource()
    }
}

extension PlayerViewController: PlayerControlsViewDelegate {
    func playerContolsViewDidChangeVolumeValue(_ playerControlsView: PlayerControlsView, didChangeVolume value: Float) {
        delegate?.didSlideSlider(value)
    }

    func playerContolsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }

    func playerContolsViewDidTapNextButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapNext()
    }

    func playerContolsViewDidTapBackButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBack()
    }
}
