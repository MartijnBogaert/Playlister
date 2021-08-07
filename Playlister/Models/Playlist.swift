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
    var name: String
    var artists: [Artist]
    var conversionState: TrackConversionState = .converting
}

extension Track: Codable { }

// MARK: Artist

struct Artist {
    let name: String
}

extension Artist: Codable { }

// MARK: TrackConversionState

enum TrackConversionState: Int {
    case converting
    case converted
    case failed
}

extension TrackConversionState: Codable { }
