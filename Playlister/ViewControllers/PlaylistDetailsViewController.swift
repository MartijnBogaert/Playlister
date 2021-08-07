//
//  PlaylistDetailsViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit

class PlaylistDetailsViewController: UIViewController {
    
    var playlist: Playlist!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    init?(coder: NSCoder, playlist: Playlist) {
        self.playlist = playlist
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = playlist.name
    }

}
