//
//  AppleMusicSearchResponse.swift
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
