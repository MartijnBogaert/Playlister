//
//  SpotifyService.swift
//  Playlister
//
//  Created by Martijn Bogaert on 03/08/2021.
//

import UIKit

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

struct SpotifyTokensRequest: APIRequest {
    typealias Response = SpotifyTokensResponse
    
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

struct SpotifyAccessTokenRequest: APIRequest {
    typealias Response = SpotifyAccessTokenResponse
    
    var refreshToken: String
    
    var host: String { "accounts.spotify.com" }
    var path: String { "/api/token" }
    var queryItems: [URLQueryItem]? {
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "grant_type", value: "refresh_token"))
        queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
        
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


struct SpotifyPersonalPlaylistsRequest: APIRequest {
    typealias Response = SpotifyPagingObject<SpotifyPlaylist>
    
    var accessToken: String
    
    var host: String { "api.spotify.com" }
    var path: String { "/v1/me/playlists" }
    var queryItems: [URLQueryItem]? { [URLQueryItem(name: "limit", value: "50")] }
    
    var request: URLRequest {
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}

struct SpotifyImageRequest: APIRequest {
    typealias Response = UIImage
    
    init?(fromURL urlString: String) {
        guard let url = URLComponents(string: urlString) else { return nil }
        self.url = url
    }
    
    var url: URLComponents
    
    var host: String { url.host ?? "mosaic.scdn.co" }
    var path: String { url.path }
}

struct SpotifyDataRequest: APIRequest {
    typealias Response = Data
    
    init?(fromURL urlString: String) {
        guard let url = URLComponents(string: urlString) else { return nil }
        self.url = url
    }
    
    var url: URLComponents
    
    var host: String { url.host ?? "mosaic.scdn.co" }
    var path: String { url.path }
}

struct SpotifyPlaylistTracksRequest: APIRequest {
    typealias Response = SpotifyPagingObject<SpotifyTrackContainer>
    
    var playlistId: String
    var accessToken: String
    
    var host: String { "api.spotify.com" }
    var path: String { "/v1/playlists/\(playlistId)/tracks" }
    var queryItems: [URLQueryItem]? {
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "market", value: "from_token"))
        queryItems.append(URLQueryItem(name: "fields", value: "next,items.track(id,name,artists(name))"))
        
        return queryItems
    }
    
    var request: URLRequest {
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
