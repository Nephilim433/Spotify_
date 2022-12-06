//
//  LibraryAlbumsResponse.swift
//  Spotify Clone
//
//  Created by Nephilim  on 12/4/22.
//

import Foundation

struct LibraryAlbumsResponse: Decodable {
    let href: String
    let items: [LibraryAlbumsResponseItem]
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
}

// MARK: - LibraryAlbumsResponseItem
struct LibraryAlbumsResponseItem: Codable {
    let addedAt: Date?
    let album: Album

    enum CodingKeys: String, CodingKey {
        case addedAt
        case album
    }
}
