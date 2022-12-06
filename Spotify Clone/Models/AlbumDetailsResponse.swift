//
//  AlbumDetailsResponse.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/18/22.
//

import Foundation

struct AlbumDetailsResponse: Codable {
    let album_type: String
    let artists : [Artist]
    let external_urls : [String:String]?
    let id : String
    let images: [Image]
    let label: String
    let name: String
    let popularity: Int
    let release_date: String
    let total_tracks: Int
    let tracks: TracksResponse
}




