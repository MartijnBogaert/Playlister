//
//  AppleMusicPlaylistCreationObject.swift
//  Playlister
//
//  Created by Martijn Bogaert on 11/08/2021.
//

import Foundation

// MARK: AppleMusicPlaylistCreationObject

struct AppleMusicPlaylistCreationObject {
    let attributes: AppleMusicPlaylistAttributes
    let relationships: AppleMusicPlaylistRelationships
}

extension AppleMusicPlaylistCreationObject: Codable { }

extension AppleMusicPlaylistCreationObject {
    init(playlist: Playlist) {
        self.attributes = AppleMusicPlaylistAttributes(name: playlist.name, description: "Created using Playlister")
        
        let tracks = playlist.tracks.reduce(into: [AppleMusicPlaylistTrack]()) { partial, track in
            if let id = track.appleMusicId {
                partial.append(AppleMusicPlaylistTrack(id: id, type: "songs"))
            }
        }
        self.relationships = AppleMusicPlaylistRelationships(trackContainer: AppleMusicPlaylistTrackContainer(tracks: tracks))
    }
}

// MARK: AppleMusicPlaylistAttributes

struct AppleMusicPlaylistAttributes {
    let name: String
    let description: String
}

extension AppleMusicPlaylistAttributes: Codable { }

// MARK: AppleMusicPlaylistRelationships

struct AppleMusicPlaylistRelationships {
    let trackContainer: AppleMusicPlaylistTrackContainer
}

extension AppleMusicPlaylistRelationships: Codable {
    enum CodingKeys: String, CodingKey {
        case trackContainer = "tracks"
    }
}

// MARK: AppleMusicPlaylistTrackContainer

struct AppleMusicPlaylistTrackContainer {
    let tracks: [AppleMusicPlaylistTrack]
}

extension AppleMusicPlaylistTrackContainer: Codable {
    enum CodingKeys: String, CodingKey {
        case tracks = "data"
    }
}

// MARK: AppleMusicPlaylistTrack

struct AppleMusicPlaylistTrack {
    let id: String
    let type: String
}

extension AppleMusicPlaylistTrack: Codable { }
