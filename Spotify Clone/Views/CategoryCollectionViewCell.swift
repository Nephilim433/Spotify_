//
//  CategoryCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/21/22.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "GenreCollectionViewCell"
    private let colors: [UIColor] =
    [UIColor(hexString: "#B95E23"),UIColor(hexString: "#EA452E"),UIColor(hexString: "#0C72ED"),UIColor(hexString: "#D7412A"),UIColor(hexString: "#8B2731"),UIColor(hexString: "#E64432"),UIColor(hexString: "#40890D"),UIColor(hexString: "#777777"),UIColor(hexString: "#DC4A8B"),UIColor(hexString: "#8C67AB"),UIColor(hexString: "#E8485C"),UIColor(hexString: "#E54763"),UIColor(hexString: "#B14197"),UIColor(hexString: "#5479A1"),UIColor(hexString: "#A66752"),UIColor(hexString: "#1E3263"),UIColor(hexString: "#477E95"),UIColor(hexString: "#B16239"),UIColor(hexString: "#B95E23"),UIColor(hexString: "#EA452E"),UIColor(hexString: "#0C72ED"),UIColor(hexString: "#D7412A"),UIColor(hexString: "#8B2731"),UIColor(hexString: "#E64432"),UIColor(hexString: "#40890D"),UIColor(hexString: "#777777"),UIColor(hexString: "#DC4A8B"),UIColor(hexString: "#8C67AB"),UIColor(hexString: "#E8485C"),UIColor(hexString: "#E54763"),UIColor(hexString: "#B14197"),UIColor(hexString: "#5479A1"),UIColor(hexString: "#A66752"),UIColor(hexString: "#1E3263"),UIColor(hexString: "#477E95"),UIColor(hexString: "#B16239")]


    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.backgroundColor = .red

        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "music.note")
        //imageView.image = UIImage(systemName: "music.note")
        return imageView
    }()
    private let label : UILabel = {
        let label = UILabel()
        label.text = "League of Legends"
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.addSubview(imageView)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        
    }
    override func layoutSubviews() {
        super.layoutSubviews()


        let imageXpos = (contentView.width/20)*14
        let imgSize = (contentView.height/20)*14

        imageView.frame = CGRect(x: imageXpos, y: contentView.height/4, width: imgSize, height: imgSize)
        imageView.bounds = CGRect(x: 0, y: 0, width: imgSize, height: imgSize)
        //rotate image view ...
        imageView.rotate(degrees: 25)
        imageView.layer.cornerRadius = 10

        let labelWidth = (contentView.width/3)*2
        label.frame = CGRect(x: 10, y: 10, width: labelWidth, height: contentView.height-30)
        label.sizeToFit()

    }
    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = UIImage(systemName: "music.note")
        label.text = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(with viewModel: CategoryCollectionViewCellViewModel) {
        label.text = viewModel.title
        //MARK: - TODO COLOR
        contentView.backgroundColor = colors.randomElement()
        imageView.sd_setImage(with: viewModel.artWorkURL, placeholderImage: UIImage(named: "music_note"), completed: nil)
    }
}
