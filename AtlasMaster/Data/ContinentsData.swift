//
//  AtlasModel.swift
//  AtlasMaster
//
//  Created by Dmitri  on 07.12.25.
//



//Regions and Countries
struct World: Codable {
    var continents: [Continent]
    
    init(continents: [Continent]) {
        self.continents = continents
    }
    
    init() {
        self.continents = []
    }
}

struct Continent: Codable {
    let name: String
    var countries: [Country]
    var isSelected: Bool = true
}

struct Country: Comparable, Codable {
    let name: String
    let capital: String
    let flag: String
    var isLearned: Bool
    
    static func < (lhs: Country, rhs: Country) -> Bool {
        lhs.name < rhs.name
    }
}

// DTO под JSON с restcountries
struct CountryAPI: Decodable {
    struct Name: Decodable {
        let common: String
    }
    
    let name: Name
    let capital: [String]?
    let region: String?
    let flag: String?
}



struct Progress {
    var currentStudyConfiguration: StudyConfiguration
    var learned: [String]
    var left: [String]
}




