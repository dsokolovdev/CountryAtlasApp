//
//  AtlasModel.swift
//  AtlasMaster
//
//  Created by Dmitri  on 07.12.25.
//

import UIKit

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

struct Continent: Equatable, Codable {
    let name: String
    var countries: [Country]
    var isSelected: Bool = true
    
    static func == (lhs: Continent, rhs: Continent) -> Bool {
        lhs.name == rhs.name
    }
}

struct Country: Equatable, Comparable, Codable {
    let name: String
    let capital: String
    let flag: String
    var isLearned: Bool
    var testResults: [TestingAspect: TestResult]
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.name == rhs.name && lhs.capital == rhs.capital && lhs.flag == rhs.flag
    }
    
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

struct ContinentStats {
    let name: String
    let total: Int
    let learned: Int
    let toLearn: Int
    
    let learnedProgress: Double     // 0.0 ... 1.0
    let toLearnProgress: Double
}

