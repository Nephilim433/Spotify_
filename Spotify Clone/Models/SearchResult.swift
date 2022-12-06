//
//  SearchResult.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/22/22.
//

import Foundation
enum SearchResult {
    case artist(model:Artist)
    case album(model:Album)
    case playlist(model: PlaylistItem)
    case track(model:Track)
}
