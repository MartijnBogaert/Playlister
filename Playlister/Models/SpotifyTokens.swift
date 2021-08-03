//
//  SpotifyTokens.swift
//  Playlister
//
//  Created by Martijn Bogaert on 03/08/2021.
//

import Foundation

// MARK: SpotifyTokensResponse - Spotify API response containing access token and refresh token

struct SpotifyTokensResponse {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresIn: Int
}

extension SpotifyTokensResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case accessTokenExpiresIn = "expires_in"
    }
}

// MARK: SpotifyAccessTokenResponse - Spotify API response containing access token

struct SpotifyAccessTokenResponse {
    let accessToken: String
    let accessTokenExpiresIn: Int
}

extension SpotifyAccessTokenResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case accessTokenExpiresIn = "expires_in"
    }
}

// MARK: SpotifyTokenStorage - Model for storing Spotify tokens on device

struct SpotifyTokensStorage {
    let accessToken: String?
    let refreshToken: String?
    let accessTokenExpiryDate: Date?
}

extension SpotifyTokensStorage: Codable { }

extension SpotifyTokensStorage {
    init(accessToken: String, refreshToken: String, accessTokenExpiresIn: Int) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiryDate = Date(timeIntervalSinceNow: Double(accessTokenExpiresIn) - 60.0)
    }
    
    func accessTokenIsValid() -> Bool {
        guard let _ = accessToken, let accessTokenExpiryDate = accessTokenExpiryDate else { return false }
        
        return Date() <= accessTokenExpiryDate
    }
}
