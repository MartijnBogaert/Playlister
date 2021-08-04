//
//  SpotifyPlaylist.swift
//  Playlister
//
//  Created by Martijn Bogaert on 03/08/2021.
//

import Foundation

// MARK: SpotifyPlaylist

struct SpotifyPlaylist {
    let id: String
    let name: String
    let snapshotId: String
    let tracks: SpotifyPlaylistTracksRefObject
    let images: [SpotifyImageObject]
}

extension SpotifyPlaylist: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case snapshotId = "snapshot_id"
        case tracks
        case images
    }
}

// MARK: SpotifyPagingObject

struct SpotifyPagingObject {
    let playlists: [SpotifyPlaylist]
    let URLNextPage: String?
}

extension SpotifyPagingObject: Codable {
    enum CodingKeys: String, CodingKey {
        case playlists = "items"
        case URLNextPage = "next"
    }
}

// MARK: SpotifyPlaylistTracksRefObject

struct SpotifyPlaylistTracksRefObject {
    let href: String
}

extension SpotifyPlaylistTracksRefObject: Codable { }

// MARK: SpotifyImageObject

struct SpotifyImageObject {
    let url: String
    let height: Int?
    let width: Int?
}

extension SpotifyImageObject: Codable { }


