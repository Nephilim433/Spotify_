//
//  Playlist.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import Foundation

struct Playlist: Codable {
    
    let itemDescription: String?
    let externalUrls: ExternalUrls
    let id: String
    let images: [Image]
    let name: String
    let owner: Owner
    let snapshotID: String?
    let tracks: Track?
    let type, uri: String?

    enum CodingKeys: String, CodingKey {

        case itemDescription = "description"
        case externalUrls = "external_urls"
        case id, images, name, owner

        case snapshotID = "snapshot_id"
        case tracks, type, uri
    }
}
