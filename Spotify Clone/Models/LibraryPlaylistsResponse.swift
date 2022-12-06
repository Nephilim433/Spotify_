//
//  LibraryPlaylistsResponse.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/30/22.
//

import Foundation

struct LibraryPlaylistsResponse: Decodable {
    let href: String
    let items: [PlaylistItem]
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
}
