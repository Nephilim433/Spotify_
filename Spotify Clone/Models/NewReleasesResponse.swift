//
//  NewReleasesResponse.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/15/22.
//


import Foundation

// MARK: - NewReleasesResponse
struct NewReleasesResponse: Codable {
    let albums: Albums
}

// MARK: - Albums
struct Albums: Codable {
    let href: String
    let items: [Album]
    let limit: Int?
    let next: String?
    let offset: Int?
    let total: Int?
}





