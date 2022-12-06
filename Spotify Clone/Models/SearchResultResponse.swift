//
//  SearchResultResponse.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/22/22.
//

import Foundation

struct SearchResultResponse: Codable {
    let albums: SearchAlbumResponse
    let artists: SearchArtistsResponse
    let playlists : SearchPlaylistsResponse
    let tracks : SearchTrackResponse
}

struct SearchAlbumResponse: Codable {
    // MARK: - Albums
        let href: String
        let items: [Album]
        let limit: Int?
        let next: String?
        let offset: Int?
        let total: Int?
}

struct SearchArtistsResponse: Codable {
    let items: [Artist]
}
struct SearchPlaylistsResponse: Codable {
    let href: String
    let items: [PlaylistItem]
    let limit: Int
    let next: String?
    let offset: Int
    let total: Int
}
struct SearchTrackResponse: Codable {

        let href: String
        let items: [Track]
        let total: Int
}
