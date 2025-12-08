//
//  AtlasModel.swift
//  AtlasMaster
//
//  Created by Dmitri  on 07.12.25.
//
import UIKit

//struct AtlasModel {
//    let continents = ["World", "Africa", "Asia", "Europe", "North America", "South America", "Oceania"]
//    let world = World(continents: [])
//        
//}

//Selection in StudyModeViewController: mode - segmented control, region - picker
struct StudyConfiguration {
    var mode: StudyMode
    var region: Region
}
//segmented control data
enum StudyMode: Int {
    case learning
    case testing
}

//picker data - Picker Continent
enum Region {
    case world
    case continent(String)
}

//Regions and Countries
struct World {
    let continents: [Continent]
    
    init(continents: [Continent]) {
        self.continents = continents
    }
    
    init() {
        self.continents = []
    }
}

struct Continent: Equatable {
    let name: String
    let countries: [Country]
}

struct Country: Comparable {
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


final class CountryService {
    
    func fetchAllCountries(completion: @escaping ([CountryAPI]) -> Void) {
            let url = URL(string:"https://restcountries.com/v3.1/all?fields=name,capital,region,flag")!

            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let countries = try JSONDecoder().decode([CountryAPI].self, from: data)
                        completion(countries)
                    } catch {
                        print("Decode error:", error)
                    }
                }
            }.resume()
        }
    
    
    func buildAtlas(from apiCountries: [CountryAPI]) -> World {
        
        var continentsDict: [String: [Country]] = [:]
        var country: Country
        
        for item in apiCountries {
            let name = item.name.common
            let capital = item.capital?.first ?? "-"
            let region = item.region ?? ""
            let flag = item.flag ?? "🏳️"
            
            country = Country(name: name, capital: capital, flag: flag)
            
            if continentsDict[region] == nil {
                continentsDict[region] = []
            }
            continentsDict[region]?.append(country)
        }
        
//        let continents = continentsDict.map { key, value in
//            Continent(name: key, countries: value.sorted())
//        }
        
        let continents: [Continent] = continentsDict.map { Continent(name: $0.key, countries: $0.value.sorted()) }
        
        return World(continents: continents)
    }
}


//enum Region: String {
//    case africa = "Africa"
//    case asia = "Asia"
//    case europe = "Europe"
//    case northAmerica = "North America"
//    case southAmerica = "South America"
//    case oceania = "Oceania"
//    case world = "World"
//}


