//
//  AuthResponse.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/13/22.
//

import Foundation

struct AuthResponse: Decodable {

        let accessToken: String
        let expiresIn: Int
        let refreshToken : String?
        let scope, tokenType: String


        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
            case refreshToken = "refresh_token"
            case scope
            case tokenType = "token_type"
        }

}
