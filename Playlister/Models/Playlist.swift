//
//  LocalPlaylist.swift
//  Playlister
//
//  Created by Martijn Bogaert on 04/08/2021.
//

import Foundation

// MARK: Playlist

struct Playlist {
    let spotifyId: String
    let name: String
    let spotifySnapshotId: String
    var tracks: [Track] = []
}

extension Playlist: Codable { }

// MARK: Track

struct Track {
    let spotifyId: String
    var appleMusicId: String?
    var name: String
    var artistName: String
    var conversionState: TrackConversionState = .unconverted
}

extension Track: Codable { }

extension Track: Equatable {
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.spotifyId == rhs.spotifyId
    }
}

// MARK: TrackConversionState

enum TrackConversionState: Int {
    case unconverted
    case converted
    case failed
}

extension TrackConversionState: Codable { }
