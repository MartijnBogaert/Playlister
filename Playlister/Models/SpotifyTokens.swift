//
//  SpotifyTokens.swift
//  Playlister
//
//  Created by Martijn Bogaert on 03/08/2021.
//

import Foundation

struct SpotifyTokens {
    let accessToken: String?
    let refreshToken: String?
}

extension SpotifyTokens: Codable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}
