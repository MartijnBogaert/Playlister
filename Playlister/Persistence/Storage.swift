//
//  Storage.swift
//  Playlister
//
//  Created by Martijn Bogaert on 03/08/2021.
//

import Foundation
import OrderedCollections

struct Storage {
    static var shared = Storage()
    
    enum Keys {
        static let spotifyTokens = "spotifyTokens"
        static let appleDeveloperToken = "appleDeveloperToken"
        static let appleMusicUserToken = "appleMusicUserToken"
        static let personalPlaylists = "personalPlaylists"
        static let publicPlaylists = "publicPlaylists"
        static let importedPlaylists = "importedPlaylists"
    }
    
    var spotifyTokens: SpotifyTokensStorage? {
        get {
            unarchiveJSON(key: Keys.spotifyTokens) ?? nil
        }
        set {
            archiveJSON(value: newValue, key: Keys.spotifyTokens)
        }
    }
    
    var appleDeveloperToken: AppleToken? {
        get {
            unarchiveJSON(key: Keys.appleDeveloperToken) ?? nil
        }
        set {
            archiveJSON(value: newValue, key: Keys.appleDeveloperToken)
        }
    }
    
    var appleMusicUserToken: AppleToken? {
        get {
            unarchiveJSON(key: Keys.appleMusicUserToken) ?? nil
        }
        set {
            archiveJSON(value: newValue, key: Keys.appleMusicUserToken)
        }
    }
    
    var personalPlaylists: Set<Playlist> {
        get {
            if let playlists: Set<Playlist> = unarchiveJSON(key: Keys.personalPlaylists) {
                return playlists
            }
            
            let emptySet = Set<Playlist>()
            archiveJSON(value: emptySet, key: Keys.personalPlaylists)
            
            return emptySet
        }
        set {
            archiveJSON(value: newValue, key: Keys.personalPlaylists)
        }
    }
    
    var publicPlaylists: Set<Playlist> {
        get {
            if let playlists: Set<Playlist> = unarchiveJSON(key: Keys.publicPlaylists) {
                return playlists
            }
            
            let emptySet = Set<Playlist>()
            archiveJSON(value: emptySet, key: Keys.publicPlaylists)
            
            return emptySet
        }
        set {
            archiveJSON(value: newValue, key: Keys.publicPlaylists)
        }
    }
    
    var importedPlaylists: OrderedSet<SpotifyPlaylist> {
        get {
            if let playlists: OrderedSet<SpotifyPlaylist> = unarchiveJSON(key: Keys.importedPlaylists) {
                return playlists
            }
            
            let emptySet = OrderedSet<SpotifyPlaylist>()
            archiveJSON(value: emptySet, key: Keys.importedPlaylists)
            
            return emptySet
        }
        set {
            archiveJSON(value: newValue, key: Keys.importedPlaylists)
        }
    }
    
    private init() { }
    
    private func archiveJSON<T: Encodable>(value: T, key: String) {
        let data = try! JSONEncoder().encode(value)
        let string = String(data: data, encoding: .utf8)
        UserDefaults.standard.set(string, forKey: key)
    }

    
    private func unarchiveJSON<T: Decodable>(key: String) -> T? {
        guard let string = UserDefaults.standard.string(forKey: key), let data = string.data(using: .utf8) else {
            return nil
        }
        return try! JSONDecoder().decode(T.self, from: data)
    }
    
    func removeByKey(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
