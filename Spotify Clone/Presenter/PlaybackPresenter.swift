//
//  PlaybackPresenter.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/27/22.
//

import Foundation
import UIKit
import AVFoundation
protocol PlayerDataSource: AnyObject {
    var songName: String? {get}
    var subtitle: String? {get}
    var imageURL: URL? {get}
    var externalURL: URL? {get}
    var duration: Int? {get}
}

final class PlaybackPresenter {

    static let shared = PlaybackPresenter()

    private var track: Track?
    private var tracks: [Track] = []
    private var items = [AVPlayerItem]()
    private var index: UInt = 0
    var currentTrack: Track? {
        if !tracks.isEmpty {
            return tracks[Int(index)]
        } else if let track = track {
            return track
        }
//        if let track = track, tracks.isEmpty {
//            return track
//        } else if !tracks.isEmpty {
//            return tracks[index]
//        }
        return nil
    }

    var player: AVPlayer?
    
    var playerVC: PlayerViewController?

    func startPlayback(from viewController: UIViewController, tracks: [Track], at index: Int) {

        self.index = UInt(index)
        guard let url = URL(string: tracks[index].preview_url ?? "") else { return }
        player = AVPlayer(url: url)
        player?.volume = 0.5

        self.tracks = tracks

        items = tracks.compactMap {
            if let url = URL(string: $0.preview_url ?? "")  {
                return AVPlayerItem.init(url: url)
            }
            return nil
        }

        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self


        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        viewController.present(nav, animated: true, completion: {
            self.player?.play()
        })
        self.playerVC = vc

    }
    func startPlayback(from viewController: UIViewController, track: Track) {

        guard let url = URL(string: track.preview_url ?? "") else { return }
        player = AVPlayer(url: url)
        player?.volume = 0.5
        self.track = track
        self.tracks = []

        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self


        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        viewController.present(nav, animated: true, completion: {
            self.player?.play()
        })
        self.playerVC = vc
        
    }

    func startPlayback(from viewController: UIViewController, tracks: [Track]) {

        self.index = 0
        self.player = nil
        self.tracks = tracks
        self.track = nil
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self


        items = tracks.compactMap {
            if let url = URL(string: $0.preview_url ?? "")  {
                return AVPlayerItem.init(url: url)
            }
            return nil
        }
        //guard let url = URL(string: tracks[0].preview_url ?? "") else { return }
        //player = AVPlayer(url: url)
        self.player = AVPlayer(playerItem: items[0])
        playTrack()

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        viewController.present(nav, animated: true, completion: nil)
        self.playerVC = vc
    }

}

extension PlaybackPresenter: PlayerDataSource {
    var duration: Int? {
        print("currentTrack?.durationMS \(currentTrack?.durationMS)")
        return currentTrack?.durationMS
    }

    var songName: String? {
        return currentTrack?.name
    }

    var subtitle: String? {
        return currentTrack?.artists?.first?.name
    }

    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }

    var externalURL: URL? {
        return URL(string: currentTrack?.externalUrls?.spotify ?? "")
    }
}
extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didSlideSlider(_ value: Float) {
//        let duration = Float(CMTimeGetSeconds((player?.currentItem?.duration)!))
//
//        let target = (duration/100.0)*value
//        print("duration = \(duration)")
//        print("target = \(target)")
//        let seconds: Int64 = Int64(target)
//        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
//        player?.seek(to: targetTime)
//
//        if player?.rate == 0 {
//            player?.play()
//        }

//        if let player = player {
//            
//            player.volume = value
//        }
    }

    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }

    func didTapNext() {
        guard !tracks.isEmpty else { return }
        index + 1 > tracks.count ? (index = 0) : (index += 1)
        playTrack()
    }

    func playTrack() {
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { _ in
            if self.player?.currentItem?.status == .readyToPlay {
                let time: Float = Float(CMTimeGetSeconds((self.player?.currentTime())!))
                self.didSlideSlider(time)
            }
        })
    if tracks.count > 0, index != tracks.count  {
        player?.replaceCurrentItem(with: items[Int(index)])
        player?.play()
        playerVC?.resfreshUI()
    } else if items != [] {
        index = 0
        player?.replaceCurrentItem(with: items[0])
        player?.play()
        playerVC?.resfreshUI()
        }
    }

    func didTapBack() {
        if index == 0 {
            playTrack()
        } else {
            index -= 1
            playTrack()
        }
    }
}
