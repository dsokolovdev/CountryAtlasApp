//
//  UserDataModel.swift
//
//  Created by Dmitri  on 08.12.25.
//
//  Description:
//  Defines user-selected study configuration:
//  - Study mode (learning / testing) from segmented control
//  - Region (world / continent) from picker
//  Includes Codable support for persistence.
//

import UIKit

// MARK: - Study Configuration

/// Selection in StudyModeViewController:
/// - `mode`   -> segmented control
/// - `region` -> picker (world / specific continent)
struct StudyConfiguration: Codable {
    var mode: StudyMode
    var region: Region
}

// MARK: - Study Mode

/// Segmented control data source.
enum StudyMode: Int, Codable {
    case learning
    case testing
}

// MARK: - Region (Picker)

/// Picker data (World or specific Continent).
/// Uses custom Codable implementation to encode/decode an enum with associated value.
enum Region: Codable {
    case world
    case continent(String)
    
    // MARK: Codable Keys
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
    
    // MARK: Codable - Encode
    
    /// Encodes Region into a keyed container:
    /// - world -> { type: "world" }
    /// - continent("Europe") -> { type: "continent", name: "Europe" }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .world:
            try container.encode("world", forKey: .type)
            
        case .continent(let name):
            try container.encode("continent", forKey: .type)
            try container.encode(name, forKey: .name)
        }
    }
    
    // MARK: Codable - Decode
    
    /// Decodes Region from a keyed container:
    /// - type == "world" -> .world
    /// - type == "continent" + name -> .continent(name)
    /// Throws if type is unknown/corrupted.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "world":
            self = .world
            
        case "continent":
            let name = try container.decode(String.self, forKey: .name)
            self = .continent(name)
            
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown region type"
            )
        }
    }
}
