//
//  FeaturedPlaylistResponse.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/15/22.
//

import Foundation


// MARK: - FeaturedPlaylistResponse
struct FeaturedPlaylistResponse: Codable {
    let message: String
    let playlists: Playlists
}

// MARK: - FeaturedPlaylistResponse
struct CategoryPlaylistResponse: Codable {
    
    let playlists: Playlists
}

// MARK: - Playlists
struct Playlists: Codable {
    let href: String
    let items: [PlaylistItem]
    let limit: Int
    let next: String?
    let offset: Int
    let total: Int
}


// MARK: - Tracks
struct PlaylistItemTracks: Codable {
    let href: String
    let total: Int
}


