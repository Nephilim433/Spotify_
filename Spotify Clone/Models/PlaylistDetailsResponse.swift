//
//  PlaylistDetailsResponse.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/18/22.
//

import Foundation

// MARK: - PlaylistDetailsResponse
struct PlaylistDetailsResponse: Codable {

    let playlistDetailsResponseDescription: String?

    let externalUrls: ExternalUrls?
    //let followers: Followers
    let href, id: String
    let images: [Image]
    let name: String
    let owner: Owner
    let playlistDetailsResponsePublic: Bool?
    
    let tracks: PlaylistTrackResponse
    let type, uri: String

}

struct PlaylistTrackResponse: Codable {
    let items : [PlaylistTrackItem]
}
struct PlaylistTrackItem : Codable {
    let track : Track
}
