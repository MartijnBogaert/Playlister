//
//  Playlist.swift
//  Playlister
//
//  Created by Martijn Bogaert on 04/08/2021.
//

import Foundation

// MARK: Playlist

struct Playlist {
    let spotifyId: String
    var appleMusicId: String?
    let name: String
    let spotifySnapshotId: String
    var tracks: [Track] = []
}

extension Playlist: Codable { }

extension Playlist: Hashable {
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.spotifyId == rhs.spotifyId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(spotifyId)
    }
}

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
    case convertedAndNotSaved
    case convertedAndSaved
    case failed
}

extension TrackConversionState: Codable { }
