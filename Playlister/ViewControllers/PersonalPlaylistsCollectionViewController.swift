//
//  PersonalPlaylistsCollectionViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit

class PersonalPlaylistsCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()
    }
    
    func update() {
        if let token = Storage.shared.spotifyTokens?.accessToken {
            SpotifyPersonalPlaylistsRequest(accessToken: token).send { result in
                print(result)
            }
        }
    }

    @IBAction func unwindFromUserDetailsViewController(unwindSegue: UIStoryboardSegue) { }
    
}
