//
//  APIRequest.swift
//  Playlister
//
//  Created by Martijn Bogaert on 03/08/2021.
//

import UIKit

protocol APIRequest {
    associatedtype Response
    
    var host: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var postData: Data? { get }
    
    var url: URL { get }
    var request: URLRequest { get }
}

extension APIRequest {
    var queryItems: [URLQueryItem]? { nil }
    var postData: Data? { nil }
}

extension APIRequest {
    var url: URL {
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = host
        components.path = path
        components.queryItems = queryItems
        
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: ":", with: "%3A")
            .replacingOccurrences(of: "/", with: "%2F")
        
        return components.url!
    }
    
    var request: URLRequest {
        var request = URLRequest(url: url)
        
        if let data = postData {
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
        }
        
        return request
    }
}

extension APIRequest where Response: Decodable {
    func send(completion: @escaping (Result<Response, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            do {
                if let data = data {
                    let decoded = try JSONDecoder().decode(Response.self, from: data)
                    completion(.success(decoded))
                } else if let error = error {
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

extension APIRequest {
    func sendForDebugging(completion: @escaping (String) -> Void) {
        URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            if let urlResponse = urlResponse {
                print("URL Response: \(urlResponse)")
            }
            
            if let data = data {
                print("Data: \(data)")
                completion(String(data: data, encoding: .utf8) ?? "Data couldn't be decoded")
            } else if let error = error {
                print("Error: \(error)")
                completion(error.localizedDescription)
            } else {
                print("Not clear what happened")
                completion("Not clear what happened")
            }
        }.resume()
    }
}

enum ImageRequestError: Error {
    case couldNotInitializeFromData
}

// SOURCE: https://books.apple.com/be/book/develop-in-swift-data-collections/id1556365920
extension APIRequest where Response == UIImage {
    func send(completion: @escaping (Result<Response, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(ImageRequestError.couldNotInitializeFromData))
            }
        }.resume()
    }
}
