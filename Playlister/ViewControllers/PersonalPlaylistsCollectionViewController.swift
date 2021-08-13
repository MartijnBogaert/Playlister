//
//  PersonalPlaylistsCollectionViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit

class PersonalPlaylistsCollectionViewController: PlaylistsCollectionViewController {
    
    override func update() {
        if let savedPlaylists = Storage.shared.personalPlaylists {
            model.savedPlaylists = Array(savedPlaylists)
        } else {
            model.savedPlaylists = []
        }
        
        if let token = Storage.shared.spotifyTokens?.accessToken {
            SpotifyPersonalPlaylistsRequest(accessToken: token).send { result in
                switch result {
                case .success(let spotifyPagingObject):
                    self.model.spotifyPlaylists = spotifyPagingObject.items
                case .failure:
                    self.model.spotifyPlaylists = []
                }
                
                DispatchQueue.main.async {
                    self.updateCollectionView()
                }
            }
        } else {
            model.spotifyPlaylists = []
        }
        
        super.update()
    }
    
    override func removeSavedPlaylist(_ playlist: Playlist) {
        Storage.shared.personalPlaylists?.remove(playlist)
    }
}
