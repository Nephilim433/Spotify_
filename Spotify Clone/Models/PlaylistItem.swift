//
//  PlaylistItem.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/30/22.
//

import Foundation

// MARK: - Item
struct PlaylistItem: Codable {
    let collaborative: Bool?
    let itemDescription: String?
    let externalUrls: ExternalUrls?
    let href: String
    let id: String
    let images: [Image]
    let name: String
    let owner: Owner
    let snapshotID: String?
    let tracks: PlaylistItemTracks
    let type, uri: String

    enum CodingKeys: String, CodingKey {
          case collaborative
          case itemDescription = "description"
          case externalUrls = "external_urls"
          case href, id, images, name, owner
          case snapshotID
          case tracks, type, uri
      }
}
