//
//  FeaturedPlaylistCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/17/22.
//

import UIKit

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistCollectionViewCell"

    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()


    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .thin)
        return label
    }()



    override init(frame: CGRect) {
        super.init(frame: frame)
        //contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(creatorNameLabel)

        //this is for "nothing goes out" of frame
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playlistNameLabel.sizeToFit()
        creatorNameLabel.sizeToFit()
        let imageSize = contentView.height - 45
        playlistCoverImageView.frame = CGRect(x: (contentView.width-imageSize)/2,
                                              y: 3,
                                              width: imageSize, height: imageSize)


        playlistNameLabel.frame = CGRect(x: 3,
                                         y: playlistCoverImageView.bottom-2,
                                        width: contentView.width-6,
                                        height: 30)
        creatorNameLabel.frame = CGRect(x: 3,
                                        y: contentView.height - 22,
                                        width: contentView.width-6,
                                        height: 20)



    }
    override func prepareForReuse() {
        super.prepareForReuse()
        //to unsure that we are not leaking state of prev cell
        //very smart
        playlistNameLabel.text = nil
        creatorNameLabel.text = nil

        playlistCoverImageView.image = nil
    }

    func configure(with viewModel:FeaturedPlaylistCellViewModel) {
        //doing configuration business....
        playlistNameLabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL, placeholderImage: UIImage(named: "music_note"), completed: nil)
    }
}
