//
//  SpotifyPagingObject.swift
//  Playlister
//
//  Created by Martijn Bogaert on 04/08/2021.
//

import Foundation

struct SpotifyPagingObject<SpotifyElement> where SpotifyElement: Codable {
    let items: [SpotifyElement]
    let URLNextPage: String?
}

extension SpotifyPagingObject: Codable {
    enum CodingKeys: String, CodingKey {
        case items
        case URLNextPage = "next"
    }
}
