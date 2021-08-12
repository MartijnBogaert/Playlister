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
