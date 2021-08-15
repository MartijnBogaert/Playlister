//
//  LaunchScreenViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 15/08/2021.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Regenerate Apple Developer Token if necessary
        if Storage.shared.appleDeveloperToken == nil || !Storage.shared.appleDeveloperToken!.isValid {
            Storage.shared.appleDeveloperToken = AppleToken.generateDeveloperToken()
        }
        
        // Remove Apple Music User Token if invalid
        if let appleMusicUserToken = Storage.shared.appleMusicUserToken, !appleMusicUserToken.isValid {
            Storage.shared.removeByKey(Storage.Keys.appleMusicUserToken)
        }
        
        // Refresh Spotify Access Token if necessary/possible
        if let tokens = Storage.shared.spotifyTokens, !tokens.accessTokenIsValid {
            SpotifyAccessTokenRequest(refreshToken: tokens.refreshToken).send { result in
                if case .success(let response) = result {
                    Storage.shared.spotifyTokens = SpotifyTokensStorage(
                        accessToken: response.accessToken,
                        refreshToken: tokens.refreshToken,
                        accessTokenExpiresIn: response.accessTokenExpiresIn
                    )
                } else {
                    Storage.shared.removeByKey(Storage.Keys.spotifyTokens)
                }
                
                DispatchQueue.main.async {
                    self.presentRootController()
                }
            }
        } else {
            presentRootController()
        }
    }
    
    private func presentRootController() {
        let rootViewController = storyboard?.instantiateViewController(identifier: "RootController") as! UITabBarController
        UIApplication.shared.windows.first?.rootViewController = rootViewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

}
