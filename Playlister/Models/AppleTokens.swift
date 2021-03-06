//
//  AppleTokens.swift
//  Playlister
//
//  Created by Martijn Bogaert on 09/08/2021.
//

import Foundation
import SwiftJWT

struct AppleToken {
    let token: String
    let tokenExpiryDate: Date
    
    init(token: String, tokenExpiryDate: Date = Date() + 2_592_000) { // 2 592 000 seconds = 30 days
        self.token = token
        self.tokenExpiryDate = tokenExpiryDate
    }
}

extension AppleToken: Codable { }

extension AppleToken {
    var isValid: Bool {
        Date() <= tokenExpiryDate
    }
}

extension AppleToken {
    static func generateDeveloperToken() -> AppleToken? {
        let tokenHeader = Header(kid: "252T9PZACS")

        struct TokenClaims: Claims {
            let iss: String
            let iat: Date
            let exp: Date
        }

        let currentDate = Date()
        let expiryDate = currentDate + 2_592_000 // 2 592 000 seconds = 30 days
        let tokenClaims = TokenClaims(iss: "KWYF279QMR", iat: currentDate, exp: expiryDate)

        var unsignedJWT = JWT(header: tokenHeader, claims: tokenClaims)
        
        guard let privateKeyPath = Bundle.main.url(forResource: "AppleMusicPrivateKey", withExtension: "p8") else { return nil }
        guard let privateKey = try? Data(contentsOf: privateKeyPath, options: .alwaysMapped) else { return nil }
        
        let jwtSigner = JWTSigner.es256(privateKey: privateKey)
        
        guard let signedJWT = try? unsignedJWT.sign(using: jwtSigner) else { return nil }
        
        return AppleToken(token: signedJWT, tokenExpiryDate: expiryDate)
    }
}
