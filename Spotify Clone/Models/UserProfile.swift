//
//  UserProfile.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import Foundation

// MARK: - UserProfile
struct UserProfile: Codable {
    let country, displayName: String
    let explicitContent: ExplicitContent
    let externalUrls: ExternalUrls
    let followers: Followers
    let href: String
    let id: String
    let images: [Image]
    let product, type, uri: String

    enum CodingKeys: String, CodingKey {
        case country
        case displayName = "display_name"
        case explicitContent = "explicit_content"
        case externalUrls = "external_urls"
        case followers, href, id, images, product, type, uri
    }
}

// MARK: - ExplicitContent
struct ExplicitContent: Codable {
    let filterEnabled, filterLocked: Bool

    enum CodingKeys: String, CodingKey {
        case filterEnabled = "filter_enabled"
        case filterLocked = "filter_locked"
    }
}



// MARK: - Followers
struct Followers: Codable {
    let href: String?
    let total: Int
}

