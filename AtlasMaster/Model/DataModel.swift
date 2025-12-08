//
//  AtlasModel.swift
//  AtlasMaster
//
//  Created by Dmitri  on 07.12.25.
//



//Regions and Countries
struct World: Codable {
    let continents: [Continent]
    
    init(continents: [Continent]) {
        self.continents = continents
    }
    
    init() {
        self.continents = []
    }
}

struct Continent: Codable {
    let name: String
    let countries: [Country]
}

struct Country: Comparable, Codable {
    let name: String
    let capital: String
    let flag: String
    
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




