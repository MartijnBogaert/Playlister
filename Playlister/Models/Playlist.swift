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
    let name: String
    let spotifySnapshotId: String
    let creationDate: Date
    
    var appleMusicId: String?
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

extension Playlist: Comparable {
    static func < (lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.creationDate < rhs.creationDate
    }
}

extension Playlist {
    init(spotifyPlaylist: SpotifyPlaylist) {
        self.spotifyId = spotifyPlaylist.id
        self.name = spotifyPlaylist.name
        self.spotifySnapshotId = spotifyPlaylist.snapshotId
        self.creationDate = Date()
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

extension Track {
    init?(spotifyTrack: SpotifyTrack) {
        guard let spotifyId = spotifyTrack.id else { return nil }
        
        self.spotifyId = spotifyId
        self.name = spotifyTrack.name
        self.artistName = spotifyTrack.artists.map { $0.name }.joined(separator: ", ")
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
