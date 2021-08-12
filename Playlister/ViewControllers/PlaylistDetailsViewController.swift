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
        updateUI()
        
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
        case .convertedAndNotSaved:
            cell.imageView?.image = UIImage(named: "AppleMusicIcon")
        case .convertedAndSaved:
            cell.imageView?.image = UIImage(named: "AppleMusicSavedIcon")
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

    @objc func saveButtonTouched() {
        let unconvertedOrFailedTracks = playlist.tracks.filter { $0.conversionState == .unconverted || $0.conversionState == .failed }
        
        if !unconvertedOrFailedTracks.isEmpty, let developerToken = Storage.shared.appleDeveloperToken, developerToken.isValid {
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            var numberOfConvertedOrFailedTracks = 0
            
            progressView.progress = 0.0
            progressViewHeight.constant = 4
            
            let group = DispatchGroup()
            
            for (index, track) in playlist.tracks.enumerated() {
                if track.conversionState == .unconverted || track.conversionState == .failed {
                    group.enter()
                    
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
                            updatedTrack.conversionState = .convertedAndNotSaved
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
                        
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.addPlaylistToLibrary()
            }
        } else {
            addPlaylistToLibrary()
        }
    }
    
    private func addPlaylistToLibrary() {
        if let developerToken = Storage.shared.appleDeveloperToken, developerToken.isValid, let musicUserToken = Storage.shared.appleMusicUserToken, musicUserToken.isValid {
            let tracksToAdd = self.playlist.tracks.filter { $0.conversionState == .convertedAndNotSaved }
            
            if !tracksToAdd.isEmpty {
                func updateTracks() {
                    for (index, track) in playlist.tracks.enumerated() {
                        if track.conversionState == .convertedAndNotSaved {
                            playlist.tracks[index].conversionState = .convertedAndSaved
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    Storage.shared.personalPlaylists?.update(with: self.playlist)
                }
                
                if let playlistId = playlist.appleMusicId {
                    AppleMusicPlaylistUpdateRequest(
                        newTracks: AppleMusicPlaylistTrackContainer(tracks: tracksToAdd),
                        playlistId: playlistId,
                        developerToken: developerToken.token,
                        musicUserToken: musicUserToken.token
                    ).send { result in
                        if case .success = result {
                            updateTracks()
                        }
                        
                        DispatchQueue.main.async {
                            self.updateUI()
                        }
                    }
                } else {
                    AppleMusicPlaylistCreationRequest(
                        playlist: AppleMusicPlaylistCreationObject(name: playlist.name, description: "Created using Playlister", tracks: tracksToAdd),
                        developerToken: developerToken.token,
                        musicUserToken: musicUserToken.token
                    ).send { result in
                        if case .success(let response) = result {
                            self.playlist.appleMusicId = response.createdPlaylists.first?.id
                            updateTracks()
                        }
                        
                        DispatchQueue.main.async {
                            self.updateUI()
                        }
                    }
                }
            } else {
                updateUI()
            }
        } else {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let _ = playlist.appleMusicId {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(saveButtonTouched))
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTouched))
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}
