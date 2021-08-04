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

extension SpotifyPlaylist: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SpotifyPlaylist, rhs: SpotifyPlaylist) -> Bool {
        return lhs.id == rhs.id
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

extension SpotifyPlaylistTracksRefObject: Hashable { }

// MARK: SpotifyImageObject

struct SpotifyImageObject {
    let url: String
    let height: Int?
    let width: Int?
}

extension SpotifyImageObject: Codable { }

extension SpotifyImageObject: Hashable { }


