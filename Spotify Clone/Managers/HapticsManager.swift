//
//  HapticsManager.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//Dunno why this is not working

import UIKit

final class HapticsManager {
    static let shared = HapticsManager()

    private init() {
    }

    public func vibrateForSelection() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    public func impact() {
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator()
            generator.impactOccurred()
        }
    }
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
