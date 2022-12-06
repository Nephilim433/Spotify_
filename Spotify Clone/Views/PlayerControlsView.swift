//
//  PlayerControlsView.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/27/22.
//

import UIKit
import CoreMedia

protocol PlayerControlsViewDelegate: AnyObject {
    func playerContolsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerContolsViewDidTapNextButton(_ playerControlsView: PlayerControlsView)
    func playerContolsViewDidTapBackButton(_ playerControlsView: PlayerControlsView)
    func playerContolsViewDidChangeVolumeValue(_ playerControlsView: PlayerControlsView, didChangeVolume value: Float)
}

struct PlayerControlsViewViewModel {
    let title: String?
    let subtitle: String?
    let seconds: Int?
}

final class PlayerControlsView: UIView {

    private var isPlaying = true

    weak var delegate: PlayerControlsViewDelegate?

    private let slider: UISlider = {
        let slider = UISlider()
        slider.value = 0
        //MARK: - change it ?
        slider.isContinuous = true
        slider.maximumValue = 100.0
        slider.isHidden = true
        return slider
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "this is my song"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Drake (feat. Some Other Artist)"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    private let backButton : UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "backward.end", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    private let nextButton : UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "forward.end", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    private let playPauseButton : UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 47, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = .clear
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        addSubview(slider)
        addSubview(backButton)
        addSubview(nextButton)
        addSubview(playPauseButton)

        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        slider.addTarget(self, action: #selector(volumeDidChange), for: .valueChanged)
        clipsToBounds = true

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func volumeDidChange(slider:UISlider) {
        let value = slider.value
        
        delegate?.playerContolsViewDidChangeVolumeValue(self, didChangeVolume: value)
    }
    @objc private func didTapBackButton() {
        delegate?.playerContolsViewDidTapBackButton(self)
        self.isPlaying = true
        updatePausePlayIcon()
    }
    @objc private func didTapNextButton() {
        delegate?.playerContolsViewDidTapNextButton(self)
        self.isPlaying = true
        updatePausePlayIcon()
    }
    @objc private func didTapPlayPauseButton() {
        self.isPlaying = !isPlaying
        delegate?.playerContolsViewDidTapPlayPauseButton(self)
        //Update icon
        updatePausePlayIcon()
    }

    private func updatePausePlayIcon() {
        let pauseIcon = UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 47, weight: .regular))
        let playIcon = UIImage(systemName: "play", withConfiguration: UIImage.SymbolConfiguration(pointSize: 47, weight: .regular))
        playPauseButton.setImage(isPlaying ? pauseIcon : playIcon, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        subtitleLabel.frame = CGRect(x: 0, y: nameLabel.bottom+10, width: width, height: 50)
//        slider.frame = CGRect(x: 10, y: subtitleLabel.bottom+20, width: width-20, height: 44)
        let buttonSize: CGFloat = 60
//        playPauseButton.frame = CGRect(x: (width-buttonSize)/2, y: subtitleLabel.bottom+30, width: buttonSize, height: buttonSize)
        let yforPlayPauseButton = (frame.height-(frame.height/10))-60
        playPauseButton.frame = CGRect(x: (width-buttonSize)/2, y: yforPlayPauseButton, width: buttonSize, height: buttonSize)
        backButton.frame = CGRect(x: playPauseButton.left-80, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        nextButton.frame = CGRect(x: playPauseButton.right+80-buttonSize, y: playPauseButton.top, width: buttonSize, height: buttonSize)
    }

    func configure(with viewModel: PlayerControlsViewViewModel) {
        nameLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        let seconds = viewModel.seconds!/1000
        print("seconds = \(seconds)")
        slider.maximumValue = Float(seconds)
    }

}
