//
//  NasaImageCollection.swift
//  NasaImageBrowser
//
//  Created by Joshua Homann on 10/26/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

// MARK: - NasaImageCollection
struct NasaMediaCollection: Codable {
  let collection: Collection?
}

// MARK: - Collection
struct Collection: Codable {
  let links: [CollectionLink]?
  let items: [Item]
  let version: String
  let href: String
  let metadata: Metadata
}

// MARK: - Item
struct Item: Codable, Hashable {
  static func == (lhs: Item, rhs: Item) -> Bool {
    return lhs.data == rhs.data
  }
  func hash(into hasher: inout Hasher) {
    data.forEach { hasher.combine($0)}
  }

  let data: [Datum]
  let links: [ItemLink]?
  let href: String
}

// MARK: - Datum
struct Datum: Codable, Hashable {
  let datumDescription: String?
  let dateCreated: String?
  let center: String?
  let keywords: [String]?
  let nasaID, title: String
  let mediaType: MediaType
  let description508, secondaryCreator, photographer, location: String?
  let album: [String]?
  
  enum CodingKeys: String, CodingKey {
    case datumDescription = "description"
    case dateCreated = "date_created"
    case center, keywords
    case nasaID = "nasa_id"
    case title
    case mediaType = "media_type"
    case description508 = "description_508"
    case secondaryCreator = "secondary_creator"
    case photographer, location, album
  }
}

enum MediaType: String, Codable, CaseIterable {
  case image = "image"
  case audio = "audio"
  case video = "video"
}

// MARK: - ItemLink
struct ItemLink: Codable {
  let render: MediaType?
  let href: String
  let rel: Rel
}

enum Rel: String, Codable {
  case captions = "captions"
  case preview = "preview"
}

// MARK: - CollectionLink
struct CollectionLink: Codable {
  let prompt: String
  let href: String
  let rel: String
}

// MARK: - Metadata
struct Metadata: Codable {
  let totalHits: Int
  
  enum CodingKeys: String, CodingKey {
    case totalHits = "total_hits"
  }
}
