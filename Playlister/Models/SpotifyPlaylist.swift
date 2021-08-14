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
    let images: [SpotifyImageObject]
}

extension SpotifyPlaylist: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case snapshotId = "snapshot_id"
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

// MARK: SpotifyImageObject

struct SpotifyImageObject {
    let url: String
    let height: Int?
    let width: Int?
}

extension SpotifyImageObject: Codable { }

extension SpotifyImageObject: Hashable { }
