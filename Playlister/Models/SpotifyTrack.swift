//
//  SpotifyTrack.swift
//  Playlister
//
//  Created by Martijn Bogaert on 04/08/2021.
//

import Foundation

// MARK: SpotifyTrack

struct SpotifyTrack {
    var id: String? // Local tracks have no Spotify ID
    let name: String
    let artists: [SpotifyTrackArtist]
}

extension SpotifyTrack: Codable { }

extension SpotifyTrack {
    func convertToTrack() -> Track? {
        guard let id = id else { return nil }
        return Track(spotifyId: id, name: name, artistName: artists.map { $0.name }.joined(separator: ", "))
    }
}

// MARK: SpotifyTrackContainer

struct SpotifyTrackContainer {
    let track: SpotifyTrack
}

extension SpotifyTrackContainer: Codable { }

// MARK: SpotifyTrackArtist

struct SpotifyTrackArtist {
    let name: String
}

extension SpotifyTrackArtist: Codable { }
