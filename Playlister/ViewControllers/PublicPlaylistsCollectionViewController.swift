//
//  PublicPlaylistsCollectionViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit

extension String {
    func extractSpotifyId() -> String? {
        if let url = URLComponents(string: self),
           url.host == "open.spotify.com",
           url.path.contains("/playlist/"),
           let spotifyId = url.path.split(separator: "/").last,
           !spotifyId.isEmpty {
            return String(spotifyId)
        }
        
        return nil
    }
}

class PublicPlaylistsCollectionViewController: PlaylistsCollectionViewController {
    
    var addPlaylistAlert: UIAlertController?
    
    override func update() {
        model.savedPlaylists = Array(Storage.shared.publicPlaylists)
        model.spotifyPlaylists = Array(Storage.shared.importedPlaylists)
        
        print(model.savedPlaylists)
        print(model.spotifyPlaylists)
        
        super.update()
    }
    
    override func removeSavedPlaylist(_ playlist: Playlist) {
        Storage.shared.publicPlaylists.remove(playlist)
    }
    
    func addSpotifyPlaylist(fromId id: String) {
        if let spotifyTokens = Storage.shared.spotifyTokens, spotifyTokens.accessTokenIsValid {
            SpotifyPlaylistRequest(playlistId: id, accessToken: spotifyTokens.accessToken).send { result in
                if case .success(let spotifyPlaylist) = result {
                    Storage.shared.importedPlaylists.update(with: spotifyPlaylist)
                    
                    DispatchQueue.main.async {
                        self.update()
                    }
                }
            }
        }
    }

    @IBAction func addPlaylistButtonTapped(_ sender: UIBarButtonItem) {
        let alertMessage = "Provide the URL to a Spotify playlist. If the playlist is private, make sure you are logged in with a Spotify account that owns it."
        addPlaylistAlert = UIAlertController(title: "Add Playlist", message: alertMessage, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Adding Playlist"), style: .cancel)
        addPlaylistAlert!.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Add Playlist"), style: .default) { _ in
            let userInput = self.addPlaylistAlert!.textFields?.first?.text ?? ""
            if let id = userInput.extractSpotifyId() {
                self.addSpotifyPlaylist(fromId: id)
            }
        }
        addPlaylistAlert!.addAction(OKAction)
        addPlaylistAlert!.actions.last?.isEnabled = false
        
        addPlaylistAlert!.addTextField { textField in
            textField.addTarget(self, action: #selector(self.addPlaylistAlertTextFieldChanged), for: .editingChanged)
        }
        
        self.present(addPlaylistAlert!, animated: true, completion: nil)
    }
    
    @objc func addPlaylistAlertTextFieldChanged() {
        if let userInput = addPlaylistAlert?.textFields?.first?.text, let _ = userInput.extractSpotifyId() {
            addPlaylistAlert?.actions.last?.isEnabled = true
        } else {
            addPlaylistAlert?.actions.last?.isEnabled = false
        }
    }
}
