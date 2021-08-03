//
//  UserDetailsViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit
import SafariServices

class UserDetailsViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var safariViewController: SFSafariViewController?
    @IBOutlet weak var connectToSpotifyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }

    @IBAction func connectToSpotifyButtonPressed() {
        safariViewController = SFSafariViewController(url: SpotifyAuthorizationRequest().url)
        safariViewController!.delegate = self
        present(safariViewController!, animated: true)
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        if let url = URLComponents(url: URL, resolvingAgainstBaseURL: false),
           url.host == "www.spotify.com", let code = url.queryItems?.first(where: { $0.name == "code" })?.value {
            connectToSpotifyButton.isEnabled = false
            safariViewController?.dismiss(animated: true, completion: nil)
            
            SpotifyAccessTokenRequest(code: code).send { result in
                if case .success(let tokens) = result, let _ = tokens.accessToken, let _ = tokens.refreshToken {
                    Storage.shared.spotifyTokens = tokens
                    
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.connectToSpotifyButton.setTitle("Try again later", for: .normal)
                    }
                }
            }
        }
    }
    
    func updateUI() {
        if let _ = Storage.shared.spotifyTokens?.accessToken {
            connectToSpotifyButton.setTitle("Connected to Spotify", for: .normal)
            connectToSpotifyButton.isEnabled = false
        } else {
            connectToSpotifyButton.setTitle("Connect to Spotify", for: .normal)
            connectToSpotifyButton.isEnabled = true
        }
    }
}
