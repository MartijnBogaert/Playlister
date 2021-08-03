//
//  AppDelegate.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Refresh Spotify Access Token if necessary/possible
        if let tokens = Storage.shared.spotifyTokens, !tokens.accessTokenIsValid(), let refreshToken = tokens.refreshToken {
            SpotifyAccessTokenRequest(refreshToken: refreshToken).send { result in
                if case .success(let response) = result {
                    Storage.shared.spotifyTokens = SpotifyTokensStorage(
                        accessToken: response.accessToken,
                        refreshToken: refreshToken,
                        accessTokenExpiresIn: response.accessTokenExpiresIn
                    )
                } else {
                    Storage.shared.removeByKey(Storage.Keys.spotifyTokens)
                }
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

