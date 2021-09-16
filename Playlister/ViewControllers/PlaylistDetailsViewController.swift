//
//  PlaylistDetailsViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit
import SafariServices
import MediaPlayer

enum StorageSource {
    case personalPlaylists
    case publicPlaylists
}

class PlaylistDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    
    var playlist: Playlist!
    var coverURL: String?
    var musicPlayerController: MPMusicPlayerController?
    let storageSource: StorageSource
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressViewHeight: NSLayoutConstraint!
    
    var storedPlaylists: Set<Playlist> {
        get {
            switch storageSource {
            case .personalPlaylists:
                return Storage.shared.personalPlaylists
            case .publicPlaylists:
                return Storage.shared.publicPlaylists
            }
        }
        set {
            switch storageSource {
            case .personalPlaylists:
                Storage.shared.personalPlaylists = newValue
            case .publicPlaylists:
                Storage.shared.publicPlaylists = newValue
            }
        }
    }
    
    init?(coder: NSCoder, playlist: Playlist, coverURL: String?, storageSource: StorageSource) {
        self.playlist = playlist
        self.coverURL = coverURL
        self.storageSource = storageSource
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
        
        let storedPlaylist = storedPlaylists.first { $0.spotifyId == playlist.spotifyId }
        playlist.tracks = storedPlaylist?.tracks ?? []
        
        if let token = Storage.shared.spotifyTokens?.accessToken {
            loadTracks(for: token, withIndex: 0, storedPlaylist: storedPlaylist)
        }
        
        if let data = storedPlaylist?.coverImageData {
            coverImageView.image = UIImage(data: data)
        } else if let coverURL = coverURL {
            SpotifyDataRequest(fromURL: coverURL)?.send { result in
                if case .success(let data) = result {
                    self.playlist.coverImageData = data
                    
                    DispatchQueue.main.async {
                        self.coverImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    private func loadTracks(for token: String, withIndex pagingIndex: Int, storedPlaylist: Playlist?) {
        SpotifyPlaylistTracksRequest(playlistId: playlist.spotifyId, offset: pagingIndex, accessToken: token).send { result in
            print("New call -- index \(pagingIndex)")
            
            if case .success(let spotifyPagingObject) = result {
                print("Success -- index \(pagingIndex)")
                
                let newTracks = spotifyPagingObject.items.reduce(into: [Track]()) { partial, spotifyTrackContainer in
                    if let track = Track(spotifyTrack: spotifyTrackContainer.track) {
                        if let storedPlaylist = storedPlaylist {
                            if !storedPlaylist.tracks.contains(track) {
                                partial.append(track)
                            }
                        } else {
                            partial.append(track)
                        }
                    }
                }
                self.playlist.tracks += newTracks
                
                if let urlString = spotifyPagingObject.URLNextPage,
                   let url = URLComponents(string: urlString),
                   let nextPagingIndexString = url.queryItems?.first(where: { $0.name == "offset" })?.value,
                   let nextPagingIndex = Int(nextPagingIndexString) {
                    self.loadTracks(for: token, withIndex: nextPagingIndex, storedPlaylist: storedPlaylist)
                }
            } else if case .failure(let error) = result {
                print("Error -- index \(pagingIndex) -- \(error)")
            } else {
                print("Unknown error -- index \(pagingIndex)")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        let track = playlist.tracks[indexPath.row]
        if let _ = track.appleMusicId {
            tableView.deselectRow(at: indexPath, animated: true) // Otherwise very long highlight time due to slow music player preparation
            
            if musicPlayerController == nil {
                musicPlayerController = MPMusicPlayerController.systemMusicPlayer
            }
            
            let storeIds = playlist.tracks[indexPath.row...].reduce(into: [String](), { partial, track in
                if let id = track.appleMusicId {
                    partial.append(id)
                }
            })
            let queue  = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIds)
            
            musicPlayerController!.shuffleMode = MPMusicShuffleMode.off
            musicPlayerController!.setQueue(with: queue)
            musicPlayerController!.play()
        } else {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "open.spotify.com"
            urlComponents.path = "/track/\(track.spotifyId)"

            if let url = urlComponents.url {
                let safariViewController = SFSafariViewController(url: url)
                safariViewController.delegate = self
                present(safariViewController, animated: true)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
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
                            self.progressView.progress = Float(numberOfConvertedOrFailedTracks) / Float(unconvertedOrFailedTracks.count)
                            self.tableView.reloadData()
                        }
                        
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.addPlaylistToLibrary()
                self.progressViewHeight.constant = 0
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
                    
                    storedPlaylists.update(with: self.playlist)
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
