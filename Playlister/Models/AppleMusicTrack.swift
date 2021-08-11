//
//  AppleMusicTrack.swift
//  Playlister
//
//  Created by Martijn Bogaert on 10/08/2021.
//

import Foundation

// MARK: AppleMusicTrack

struct AppleMusicTrack {
    let id: String?
    let attributes: AppleMusicTrackAttributes?
}

extension AppleMusicTrack: Codable { }

// MARK: AppleMusicTracksSearchResult

struct AppleMusicTracksSearchResult {
    let tracks: [AppleMusicTrack]
}

extension AppleMusicTracksSearchResult: Codable {
    enum CodingKeys: String, CodingKey {
        case tracks = "data"
    }
}

// MARK: AppleMusicTrackAttributes

struct AppleMusicTrackAttributes {
    let artistName: String
    let name: String
}

extension AppleMusicTrackAttributes: Codable { }
