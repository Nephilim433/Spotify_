//
//  RecommendedTrackCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/17/22.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTrackCollectionViewCell"

    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.layer.masksToBounds = true
//        imageView.layer.cornerRadius = 8
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()

    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()



    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
//        contentView.backgroundColor = .red
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)

        //this is for "nothing goes out" of frame
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let imageSize = contentView.height - 10

        albumCoverImageView.frame = CGRect(x: (contentView.height-imageSize)/2, y: (contentView.height-imageSize)/2, width: imageSize, height: imageSize)

        trackNameLabel.frame = CGRect(x: albumCoverImageView.right+10, y: 0, width: contentView.width-albumCoverImageView.right-20, height: contentView.height/2)

        artistNameLabel.frame = CGRect(x: albumCoverImageView.right+10, y: contentView.height/2, width: contentView.width-albumCoverImageView.right-20, height: contentView.height/2)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        //to unsure that we are not leaking state of prev cell
        //very smart
        trackNameLabel.text = nil
        artistNameLabel.text = nil
        albumCoverImageView.image = nil
    }

    func configure(with viewModel:RecommendedTrackCellViewModel) {
        //doing configuration business....
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        albumCoverImageView.sd_setImage(with: viewModel.artWorkURL, placeholderImage: UIImage(named: "music_note"), completed: nil)
    }
}
