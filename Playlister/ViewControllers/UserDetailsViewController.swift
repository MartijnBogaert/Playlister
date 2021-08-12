//
//  UserDetailsViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit
import SafariServices
import StoreKit

class UserDetailsViewController: UIViewController, SFSafariViewControllerDelegate, SKCloudServiceSetupViewControllerDelegate {
    
    var safariViewController: SFSafariViewController?
    @IBOutlet weak var connectToSpotifyButton: UIButton!
    @IBOutlet weak var connectToAppleMusicButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }

    @IBAction func connectToSpotifyButtonPressed() {
        if let tokens = Storage.shared.spotifyTokens, tokens.accessTokenIsValid {
            Storage.shared.removeByKey(Storage.Keys.spotifyTokens)
            updateUI()
        } else {
            safariViewController = SFSafariViewController(url: SpotifyAuthorizationRequest().url)
            safariViewController!.delegate = self
            present(safariViewController!, animated: true)
        }
    }
    
    @IBAction func connectToAppleMusicButtonPressed() {
        if let musicToken = Storage.shared.appleMusicUserToken, musicToken.isValid {
            Storage.shared.removeByKey(Storage.Keys.appleMusicUserToken)
            updateUI()
        } else {
            guard let developerToken = Storage.shared.appleDeveloperToken, developerToken.isValid else { return }
            
            let controller = SKCloudServiceController()
            
            // Request User Music Token
            controller.requestUserToken(forDeveloperToken: developerToken.token) { musicUserToken, _ in
                if let musicUserToken = musicUserToken {
                    
                    // Request access to music library
                    SKCloudServiceController.requestAuthorization { status in
                        if case .authorized = status {
                            
                            // Request device's Apple Music capabilities
                            controller.requestCapabilities { capabilities, _ in
                                // Check if Apple Music tracks can be played and added to library
                                if capabilities.contains(.musicCatalogPlayback) {
                                    
                                    // Apple Music is set up -> Store User Music Token
                                    Storage.shared.appleMusicUserToken = AppleToken(token: musicUserToken)
                                    self.updateUI()
                                    
                                } else if capabilities.contains(.musicCatalogSubscriptionEligible) {
                                    
                                    // Apple Music isn't set up -> Show Apple Music sign up screen
                                    self.showAppleMusicSignup()
                                    
                                }
                            }
                        }
                    }
                }
            }
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
        if let spotifyTokens = Storage.shared.spotifyTokens, spotifyTokens.accessTokenIsValid {
            connectToSpotifyButton.setTitle("Disconnect from Spotify", for: .normal)
        } else {
            connectToSpotifyButton.setTitle("Connect to Spotify", for: .normal)
        }
        
        if let appleMusicUserToken = Storage.shared.appleMusicUserToken, appleMusicUserToken.isValid {
            connectToAppleMusicButton.setTitle("Disconnect from Apple Music", for: .normal)
        } else {
            connectToAppleMusicButton.setTitle("Connect to Apple Music", for: .normal)
        }
    }
    
    // SOURCE: https://crunchybagel.com/integrating-apple-music-into-your-ios-app/
    private func showAppleMusicSignup() {
            let vc = SKCloudServiceSetupViewController()
            vc.delegate = self

            let options: [SKCloudServiceSetupOptionsKey: Any] = [
                .action: SKCloudServiceSetupAction.subscribe,
                .messageIdentifier: SKCloudServiceSetupMessageIdentifier.playMusic
            ]
                
            vc.load(options: options) { success, error in
                if success {
                    self.present(vc, animated: true)
                }
            }

        }
}
