//
//  PublicPlaylistsCollectionViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit

class PublicPlaylistsCollectionViewController: PlaylistsCollectionViewController {
    
    override func update() {
        model.savedPlaylists = Array(Storage.shared.publicPlaylists)
        model.spotifyPlaylists = Array(Storage.shared.importedPlaylists)
        
        super.update()
    }
    
    override func removeSavedPlaylist(_ playlist: Playlist) {
        Storage.shared.publicPlaylists.remove(playlist)
    }

}
