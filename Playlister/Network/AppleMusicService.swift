//
//  AppleMusicService.swift
//  Playlister
//
//  Created by Martijn Bogaert on 09/08/2021.
//

import Foundation

struct AppleMusicSearchRequest: APIRequest {
    typealias Response = Void
    
    let searchTerm: String
    let storefront: String
    let developerToken: String
    
    var host: String { "api.music.apple.com" }
    var path: String { "/v1/catalog/\(storefront)/search" }
    var queryItems: [URLQueryItem]? {
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "term", value: searchTerm))
        queryItems.append(URLQueryItem(name: "limit", value: "1"))
        queryItems.append(URLQueryItem(name: "types", value: "songs"))
        
        return queryItems
    }
    
    var request: URLRequest {
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
