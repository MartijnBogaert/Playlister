//
//  PersonalPlaylistsCollectionViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit

class PersonalPlaylistsCollectionViewController: PlaylistsCollectionViewController {
    
    override func update() {
        model.savedPlaylists = Array(Storage.shared.personalPlaylists)
        
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
        Storage.shared.personalPlaylists.remove(playlist)
    }
    
    @IBSegueAction func showPlaylistDetails(_ coder: NSCoder, sender: UICollectionViewCell?) -> PlaylistDetailsViewController? {
        guard
            let cell = sender,
            let indexPath = collectionView.indexPath(for: cell),
            let item = dataSource.itemIdentifier(for: indexPath)
        else { return nil }
        
        switch item {
        case.savedPlaylist(let savedPlaylist):
            return PlaylistDetailsViewController(coder: coder, playlist: savedPlaylist, coverURL: nil, storageSource: .personalPlaylists)
        case .spotifyPlaylist(let spotifyPlaylist):
            return PlaylistDetailsViewController(coder: coder, playlist: Playlist(spotifyPlaylist: spotifyPlaylist), coverURL: spotifyPlaylist.images.first?.url, storageSource: .personalPlaylists)
        }
    }
}
