//
//  TracksResponse.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/18/22.
//

import Foundation
// MARK: - TracksResponse
struct TracksResponse: Codable {
    let href: String
    let items: [Track]
    //let limit: Int
    //let offset: Int
    let total: Int
}
