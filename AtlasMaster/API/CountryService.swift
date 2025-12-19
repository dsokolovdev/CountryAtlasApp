
//  CountryService.swift
//
//  Created by Dmitri on 07.12.25.
//
//  Description:
//  Networking & data-mapping layer responsible for:
//  - Fetching country data from REST Countries API
//  - Converting API models into internal World / Continent / Country models
//

import UIKit

// MARK: - Country Service

struct CountryService {

    // MARK: - API Fetching

    /// Fetches all countries from REST Countries API.
    /// - Parameter completion: Completion handler returning an array of CountryAPI models.
    func fetchAllCountries(completion: @escaping ([CountryAPI]) -> Void) {
        let url = URL(string: "https://restcountries.com/v3.1/all?fields=name,capital,region,flag")!

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

    // MARK: - Atlas Building

    /// Builds internal World model from API country data.
    /// Groups countries by region (continent) and prepares default learning/testing state.
    ///
    /// - Parameter apiCountries: Array of CountryAPI objects received from the API.
    /// - Returns: Fully constructed World model.
    func buildAtlas(from apiCountries: [CountryAPI]) -> World {

        var continentsDict: [String: [Country]] = [:]
        var country: Country

        for item in apiCountries {
            let name = item.name.common
            let capital = item.capital?.first ?? "No capital"
            let region = item.region ?? ""
            let flag = item.flag ?? "🏳️"

            country = Country(
                name: name,
                capital: capital,
                flag: flag,
                isLearned: false,
                testResults: [
                    .capital: .notTested,
                    .country: .notTested,
                    .flag: .notTested
                ]
            )

            if continentsDict[region] == nil {
                continentsDict[region] = []
            }
            continentsDict[region]?.append(country)
        }

        // Convert dictionary into sorted Continent models
        let continents: [Continent] = continentsDict.map {
            Continent(name: $0.key, countries: $0.value.sorted())
        }

        return World(continents: continents)
    }
}
