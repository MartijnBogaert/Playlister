//
//  SpotifyTrack.swift
//  Playlister
//
//  Created by Martijn Bogaert on 04/08/2021.
//

import Foundation

// MARK: SpotifyTrack

struct SpotifyTrack {
    let id: String?
    let name: String?
    let artists: [SpotifyTrackArtist]?
}

extension SpotifyTrack: Codable { }

// MARK: SpotifyTrackArtist

struct SpotifyTrackArtist {
    let name: String?
}

extension SpotifyTrackArtist: Codable { }
