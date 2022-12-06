//
//  CategoriesResponse.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/21/22.
//

import Foundation

// MARK: - CategoriesResponse
struct CategoriesResponse: Codable {
    let categories: Categories
}

// MARK: - Categories
struct Categories: Codable {
    let href: String
    let items: [CategoriesItem]
    let limit: Int
    let next: String
    let offset: Int
    let total: Int
}

// MARK: - Item
struct CategoriesItem: Codable {
    let href: String
    let icons: [Icon]
    let id, name: String
}

// MARK: - Icon
struct Icon: Codable {
    let height: Int?
    let url: String
    let width: Int?
}
