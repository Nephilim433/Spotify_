//
//  NewReleaseCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/17/22.
//

import UIKit
import SDWebImage

class NewReleaseCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleaseCollectionViewCell"

    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    private let numberOfTracksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.numberOfLines = 0
        return label
    }()

    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()



    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(numberOfTracksLabel)

        //nothing goes out
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        artistNameLabel.sizeToFit()
        numberOfTracksLabel.sizeToFit()
        let imageSize: CGFloat = contentView.height-10
        let albumLabelSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width-imageSize-10,
                                                                height: contentView.height-10))
        //albumNameLabel.sizeToFit()
        albumCoverImageView.frame = CGRect(x: 5,
                                           y: 5,
                                           width: imageSize,
                                           height: imageSize)

        albumNameLabel.frame = CGRect(x: albumCoverImageView.right+10,
                                      y: 5,
                                      width: albumLabelSize.width,
                                      height: min(50,albumLabelSize.height))

        artistNameLabel.frame = CGRect(x: albumCoverImageView.right+10,
                                       y: albumNameLabel.bottom,
                                       width: contentView.width-imageSize-20,
                                       height: 30)

        numberOfTracksLabel.frame = CGRect(x:albumCoverImageView.right+10,
                                           y:albumCoverImageView.bottom-numberOfTracksLabel.height,
                                           width: contentView.width-imageSize-20,
                                           height: numberOfTracksLabel.height)

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        //to unsure that we are not leaking state of prev cell
        //very smart
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
        albumCoverImageView.image = nil
    }

    func configure(with viewModel:NewReleasesCellViewModel) {
        //doing configuration business....
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTrack)"
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, placeholderImage: UIImage(named: "music_note"), completed: nil)
    }
}
