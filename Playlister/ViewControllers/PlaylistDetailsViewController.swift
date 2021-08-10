//
//  PlaylistDetailsViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit
import SafariServices

class PlaylistDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    
    var playlist: Playlist!
    var coverURL: String?
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    init?(coder: NSCoder, playlist: Playlist, coverURL: String?) {
        self.playlist = playlist
        self.coverURL = coverURL
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        title = playlist.name
        
        if let token = Storage.shared.spotifyTokens?.accessToken {
            SpotifyPlaylistTracksRequest(playlistId: playlist.spotifyId, accessToken: token).send { result in
                if case .success(let spotifyPagingObject) = result {
                    let tracks = spotifyPagingObject.items.reduce(into: [Track]()) { partial, spotifyTrackContainer in
                        if let track = spotifyTrackContainer.track.convertToTrack() {
                            partial.append(track)
                        }
                    }
                    self.playlist.tracks = tracks
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        if let coverURL = coverURL {
            SpotifyImageRequest(fromURL: coverURL)?.send(completion: { result in
                if case .success(let image) = result {
                    DispatchQueue.main.async {
                        self.coverImageView.image = image
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Track", for: indexPath)
        let track = playlist.tracks[indexPath.row]
        
        cell.textLabel?.text = track.name
        cell.detailTextLabel?.text =  track.artists.map { $0.name }.joined(separator: " - ")
        cell.imageView?.image = UIImage(named: "SpotifyIcon")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "open.spotify.com"
        urlComponents.path = "/track/\(playlist.tracks[indexPath.row].spotifyId)"
        
        if let url = urlComponents.url {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = self
            present(safariViewController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
    }
}
