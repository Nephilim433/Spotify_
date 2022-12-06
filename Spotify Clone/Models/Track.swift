//
//  Track.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/15/22.
//

import Foundation

// MARK: - Track
struct Track: Codable {
    var album: Album?
    let artists: [Artist]?
    let discNumber: Int?
    let durationMS: Int
    let explicit: Bool?
    let externalUrls: ExternalUrls?
    let id: String

    let name: String
    let popularity: Int?
    let preview_url: String?

    let trackNumber: Int?
    let type: String?

    enum CodingKeys: String, CodingKey {

        case artists
        case album
        case discNumber
        case durationMS = "duration_ms"
        case explicit
        case id
        case name
        case popularity
        case preview_url
        case trackNumber
        case type
        case externalUrls = "external_urls"

    }
}
