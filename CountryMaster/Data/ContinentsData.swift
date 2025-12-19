//
//  Created by Dmitri on 07.12.25.
//

import UIKit

// MARK: - World Model

/// Root model representing the entire world.
/// Contains a list of continents.
struct World: Codable {
    
    /// All continents in the world
    var continents: [Continent]
    
    /// Designated initializer
    init(continents: [Continent]) {
        self.continents = continents
    }
    
    /// Empty world initializer
    init() {
        self.continents = []
    }
}

// MARK: - Continent Model

/// Represents a continent containing multiple countries.
struct Continent: Equatable, Codable {
    
    /// Continent name (e.g. "Europe", "Asia")
    let name: String
    
    /// Countries belonging to the continent
    var countries: [Country]
    
    /// UI helper flag (used for selection state)
    var isSelected: Bool = true
    
    /// Equality based only on continent name
    static func == (lhs: Continent, rhs: Continent) -> Bool {
        lhs.name == rhs.name
    }
}

// MARK: - Country Model

/// Represents a country with learning and testing progress.
struct Country: Equatable, Comparable, Codable {
    
    /// Country name
    let name: String
    
    /// Capital city
    let capital: String
    
    /// Flag emoji
    let flag: String
    
    /// Learning progress flag
    var isLearned: Bool
    
    /// Test results for each testing aspect
    var testResults: [TestingAspect: TestResult]
    
    /// Equality based on name, capital, and flag
    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.name == rhs.name && lhs.capital == rhs.capital && lhs.flag == rhs.flag
    }
    
    /// Alphabetical sorting by country name
    static func < (lhs: Country, rhs: Country) -> Bool {
        lhs.name < rhs.name
    }
}

// MARK: - API DTO Models

/// DTO model for decoding data from restcountries API
struct CountryAPI: Decodable {
    
    /// Nested name object
    struct Name: Decodable {
        let common: String
    }
    
    let name: Name
    let capital: [String]?
    let region: String?
    let flag: String?
}

// MARK: - Learning Statistics Models

/// Statistics model used for learning progress UI
struct ContinentStats {
    
    /// Continent name
    let name: String
    
    /// Total number of countries
    let total: Int
    
    /// Number of learned countries
    let learned: Int
    
    /// Number of countries left to learn
    let toLearn: Int
    
    /// Learned progress ratio (0.0 ... 1.0)
    let learnedProgress: Double
    
    /// Remaining progress ratio (0.0 ... 1.0)
    let toLearnProgress: Double
}

// MARK: - Testing Statistics Models

/// Statistics model used for testing progress UI
struct ContinentTestStats {
    
    /// Continent name
    let name: String
    
    /// Total number of countries
    let total: Int
    
    /// Number of passed tests
    let passed: Int
    
    /// Number of failed tests
    let failed: Int
    
    /// Number of untested countries
    let untested: Int
    
    /// Ratio of finished tests (passed + failed)
    let finishedRatio: Double
    
    /// Ratio of passed tests within finished tests
    let passedRatio: Double
    
    /// Ratio of failed tests within finished tests
    let failedRatio: Double
}
