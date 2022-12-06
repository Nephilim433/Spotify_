//
//  SettingsModels.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/14/22.
//

import Foundation

struct Section {
    let title : String
    let options : [Option]
}

struct Option {
    let title : String
    let handler: () -> Void
}
