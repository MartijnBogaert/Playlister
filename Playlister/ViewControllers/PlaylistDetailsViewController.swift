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
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressViewHeight: NSLayoutConstraint!
    
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
        progressViewHeight.constant = 0
        
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
        cell.detailTextLabel?.text =  track.artistName
        
        switch track.conversionState {
        case .unconverted:
            cell.imageView?.image = UIImage(named: "SpotifyIcon")
        case .converted:
            cell.imageView?.image = UIImage(named: "AppleMusicIcon")
        case .failed:
            cell.imageView?.image = UIImage(named: "WarningIcon")
        }
        
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
        let unconvertedOrFailedTracks = playlist.tracks.filter({ $0.conversionState != .converted })
        
        if !unconvertedOrFailedTracks.isEmpty, let developerToken = Storage.shared.appleDeveloperToken, developerToken.isValid {
            var numberOfConvertedOrFailedTracks = 0
            
            progressView.progress = 0.0
            progressViewHeight.constant = 4
            
            for (index, track) in playlist.tracks.enumerated() {
                if track.conversionState != .converted {
                    let cleanedArtistName = track.artistName
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .joined(separator: " ")
                    let searchTerm = "\(track.name) \(cleanedArtistName)"
                    
                    AppleMusicSearchRequest(searchTerm: searchTerm, storefront: "be", developerToken: developerToken.token).send { result in
                        var updatedTrack = self.playlist.tracks[index]
                        
                        if case .success(let response) = result, let appleMusicTrack = response.results.tracksSearchResult.tracks.first {
                            updatedTrack.appleMusicId = appleMusicTrack.id
                            updatedTrack.name = appleMusicTrack.attributes?.name ?? ""
                            updatedTrack.artistName = appleMusicTrack.attributes?.artistName ?? ""
                            updatedTrack.conversionState = .converted
                        } else {
                            updatedTrack.appleMusicId = nil
                            updatedTrack.conversionState = .failed
                        }
                        
                        self.playlist.tracks[index] = updatedTrack
                        numberOfConvertedOrFailedTracks += 1
                        
                        DispatchQueue.main.async {
                            let progress = Float(numberOfConvertedOrFailedTracks) / Float(unconvertedOrFailedTracks.count)
                            if progress == 1.0 {
                                self.progressViewHeight.constant = 0
                            } else {
                                self.progressView.progress = progress
                            }
                            
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
}
