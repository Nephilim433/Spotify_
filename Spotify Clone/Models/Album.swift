//
//  Album.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/15/22.
//

import Foundation

struct Album: Codable {
    let albumType: String   
    let artists: [Artist]
    let availableMarkets: [String]
    let externalUrls: ExternalUrls?
    let href: String
    let id: String
    var images: [Image]
    let name, releaseDate, releaseDatePrecision: String
    let totalTracks: Int
    let type, uri: String

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case totalTracks = "total_tracks"
        case type, uri
    }
}


