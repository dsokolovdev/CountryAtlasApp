//
//  UserDataModel.swift
//  AtlasMaster
//
//  Created by Dmitri  on 08.12.25.
//

import UIKit

//Selection in StudyModeViewController: mode - segmented control, region - picker
struct StudyConfiguration: Codable {
    var mode: StudyMode
    var region: Region
}
//segmented control data
enum StudyMode: Int, Codable {
    case learning
    case testing
}

enum TestingAspect {
    case capital
    case country
    case flag
    
    var iconName: String {
        switch self {
        case .capital: return "building.2.fill"
        case .country: return "globe.fill"
        case .flag: return "flag.fill"
        }
    }
}


//???
struct TestQuestion {
    let country: Country
    let options: [TestOption]
    let correctIndex: Int
}

struct TestOption {
    let title: String?
    let image: UIImage?
}



//picker data - Picker Continent
enum Region: Codable {
    case world
    case continent(String)

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }

    // encode
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

    // decode
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
