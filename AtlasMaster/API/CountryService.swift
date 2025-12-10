//
//  AtlasModel.swift
//  AtlasMaster
//
//  Created by Dmitri  on 07.12.25.
//
import UIKit

struct CountryService {
    
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
            
            country = Country(name: name, capital: capital, flag: flag, isLearned: false)
            
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

