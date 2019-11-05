//
//  NasaImageService.swift
//  NasaImageBrowser
//
//  Created by Joshua Homann on 10/26/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import Foundation
import Combine

enum NasaMediaService {
  enum Error: Swift.Error {
    case invalidURL
  }
  private enum Constant {
    static let baseURL = URL(string:"https://images-api.nasa.gov/search")!
  }
  static func search(query: String, mediaType: MediaType) -> AnyPublisher<[Item], Swift.Error> {
    var components = URLComponents(url: Constant.baseURL, resolvingAgainstBaseURL: false)
    components?.queryItems = [
      URLQueryItem(name: "q", value: query),
      URLQueryItem(name: "media_type", value: mediaType.rawValue)
    ]
    guard let url = components?.url else {
      return Fail(error: Error.invalidURL)
        .eraseToAnyPublisher()
    }

    switch Int.random(in: 0..<3) {
    case 0:
      return Fail(error: Error.invalidURL).eraseToAnyPublisher()
    case 1:
      return Just([Item]())
        .mapError { _ in Error.invalidURL }
        .eraseToAnyPublisher()
    default:
      return URLSession
      .shared
      .dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: NasaMediaCollection.self, decoder: JSONDecoder())
      .map { $0.collection?.items ?? [] }
      .eraseToAnyPublisher()
    }
  }
}
