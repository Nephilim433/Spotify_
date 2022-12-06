//
//  Owner.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/16/22.
//

import Foundation
// MARK: - Owner
struct Owner: Codable {
    let displayName: String
    let externalUrls: ExternalUrls?
    let href: String
    let id, type, uri: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case externalUrls = "external_urls"
        case href, id, type, uri
    }
}
