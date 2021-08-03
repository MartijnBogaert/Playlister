//
//  SpotifyService.swift
//  Playlister
//
//  Created by Martijn Bogaert on 03/08/2021.
//

import Foundation

private let clientId = "5d5fa918fe334462b607122c264f8686"
private let clientSecret = "0f183b42d68e4b7f8a9f4f44e89953f5"
private let redirectURI = "https://www.spotify.com/"

struct SpotifyAuthorizationRequest: APIRequest {
    typealias Response = Void
    
    var host: String { "accounts.spotify.com" }
    var path: String { "/authorize" }
    var queryItems: [URLQueryItem]? {
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "client_id", value: clientId))
        queryItems.append(URLQueryItem(name: "response_type", value: "code"))
        queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectURI))
        queryItems.append(URLQueryItem(name: "scope", value: "playlist-read-private,playlist-read-collaborative"))
        
        return queryItems
    }
}

struct SpotifyAccessTokenRequest: APIRequest {
    typealias Response = SpotifyTokens
    
    var code: String
    
    var host: String { "accounts.spotify.com" }
    var path: String { "/api/token" }
    var queryItems: [URLQueryItem]? {
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "grant_type", value: "authorization_code"))
        queryItems.append(URLQueryItem(name: "code", value: code))
        queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectURI))
        
        return queryItems
    }
    
    var request: URLRequest {
        let authorizationString = "\(clientId):\(clientSecret)"
            .data(using: .utf8)?
            .base64EncodedString()
        
        var request = URLRequest(url: url)
        
        request.addValue("Basic \(authorizationString ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        return request
    }
}
