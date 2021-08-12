//
//  AppleMusicResponse.swift
//  Playlister
//
//  Created by Martijn Bogaert on 10/08/2021.
//

import Foundation

// MARK: AppleMusicSearchResponse

struct AppleMusicSearchResponse {
    let results: AppleMusicResults
}

extension AppleMusicSearchResponse: Codable { }

// MARK: AppleMusicResults

struct AppleMusicResults {
    let tracksSearchResult: AppleMusicTracksSearchResult
}

extension AppleMusicResults: Codable {
    enum CodingKeys: String, CodingKey {
        case tracksSearchResult = "songs"
    }
}

// MARK: AppleMusicPlaylistCreationResponse

struct AppleMusicPlaylistCreationResponse {
    let createdPlaylists: [AppleMusicCreatedPlaylist]
}

extension AppleMusicPlaylistCreationResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case createdPlaylists = "data"
    }
}

// MARK: AppleMusicCreatedPlaylist

struct AppleMusicCreatedPlaylist {
    let id: String
}

extension AppleMusicCreatedPlaylist: Codable { }
