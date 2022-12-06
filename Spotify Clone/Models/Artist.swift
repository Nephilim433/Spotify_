//
//  Artist.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import Foundation

// MARK: - Artist
struct Artist: Codable {
    let externalUrls: ExternalUrls
    let href: String
    let id, name, type, uri: String
    let images : [Image]?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri, images
    }
}
