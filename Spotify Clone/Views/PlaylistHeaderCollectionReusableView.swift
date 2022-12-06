//
//  PlaylistHeaderCollectionReusableView.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/19/22.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()

    private let playAllButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.8431372549, blue: 0.3764705882, alpha: 1)
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(playAllButton)
        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }
    @objc private func  didTapPlayAll() {
        delegate?.playlistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .systemBackground
        //layouting ...
        let imageSize: CGFloat = height/1.8
        imageView.frame = CGRect(x: (width-imageSize)/2, y: 20, width: imageSize, height: imageSize)

        nameLabel.frame = CGRect(x: 10, y: imageView.bottom, width: width-20, height: 44)
        descriptionLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width-20, height: 44)
        ownerLabel.frame = CGRect(x: 10, y: descriptionLabel.bottom, width: width-20, height: 44)

        playAllButton.frame = CGRect(x: width-80, y: height-80, width: 60, height: 60)
    }
    func configure(with viewModel: PlaylistHeaderViewModel) {
        nameLabel.text = viewModel.playlistName
        ownerLabel.text = viewModel.ownerName

        descriptionLabel.text = viewModel.descriptionName
        imageView.sd_setImage(with: viewModel.artworkULR, placeholderImage: UIImage(named: "music_note"), completed: nil)
    }
}
