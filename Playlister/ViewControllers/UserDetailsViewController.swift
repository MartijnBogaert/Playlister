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
        if let tokens = Storage.shared.spotifyTokens, tokens.accessTokenIsValid() {
            Storage.shared.removeByKey(Storage.Keys.spotifyTokens)
            updateUI()
        } else {
            safariViewController = SFSafariViewController(url: SpotifyAuthorizationRequest().url)
            safariViewController!.delegate = self
            present(safariViewController!, animated: true)
        }
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        if let url = URLComponents(url: URL, resolvingAgainstBaseURL: false),
           url.host == "www.spotify.com", let code = url.queryItems?.first(where: { $0.name == "code" })?.value {
            safariViewController?.dismiss(animated: true, completion: nil)
            
            SpotifyTokensRequest(code: code).send { result in
                if case .success(let tokens) = result {
                    Storage.shared.spotifyTokens = SpotifyTokensStorage(
                        accessToken: tokens.accessToken,
                        refreshToken: tokens.refreshToken,
                        accessTokenExpiresIn: tokens.accessTokenExpiresIn
                    )
                    
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                }
            }
        }
    }
    
    func updateUI() {
        if let tokens = Storage.shared.spotifyTokens, tokens.accessTokenIsValid() {
            connectToSpotifyButton.setTitle("Disconnect from Spotify", for: .normal)
        } else {
            connectToSpotifyButton.setTitle("Connect to Spotify", for: .normal)
        }
    }
}
