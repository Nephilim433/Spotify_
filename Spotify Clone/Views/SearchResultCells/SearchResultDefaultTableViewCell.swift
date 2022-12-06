//
//  SearchResultDefaultTableViewCell.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/22/22.
//

import UIKit
import SDWebImage


class SearchResultDefaultTableViewCell: UITableViewCell {

    private let label : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .heavy)
        return label
    }()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    static let identifier = "SearchResultDefaultTableViewCell"


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height-10

        iconImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
        iconImageView.layer.cornerRadius = imageSize/2
        iconImageView.layer.masksToBounds = true

        label.frame = CGRect(x: iconImageView.right+10, y: 0, width: contentView.width-iconImageView.width-20, height: contentView.height)

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
    }
    func configure(with viewModel:SearchResultDefaultTableViewCellViewModel){
        self.label.text = viewModel.title
        self.iconImageView.sd_setImage(with: viewModel.imageURL, placeholderImage: UIImage(named: "music_note"), completed: nil)
    }
}
