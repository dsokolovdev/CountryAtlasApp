//
//  AtlastDataModel.swift
//  AtlasMaster
//
//  Created by Dmitri  on 08.12.25.
//
import UIKit

final class AtlasModel {
    var currentConfig = StudyConfiguration(mode: .learning, region: .world)
    var world: World?
    var currentWorld: World? {
        //Define continent which is selected on picker in StudyModeViewController
        let continentName: String
        let region = currentConfig.region
        var filteredContinents: [Continent] = []
        if let w = world {
            filteredContinents = w.continents
        }
        
        switch region {
        case .continent(let name): continentName = name
        case .world : continentName = "World"
        }
        
        if continentName == "World" {
            filteredContinents = filteredContinents.map {
                var c = $0
                c.isSelected = true
                return c
            }
        } else {
            filteredContinents = filteredContinents.map {
                var c = $0
                c.name == continentName ? (c.isSelected = true) : (c.isSelected = false)
                return c
            }
        }
        
        let showLearned = filterMode == 1
        
        filteredContinents = filteredContinents.filter{ $0.isSelected }.map { continent in
            let filteredCountries = continent.countries.filter { $0.isLearned == showLearned }
            return Continent(name: continent.name, countries: filteredCountries)
        }
        
        return World(continents: filteredContinents)
    }
    var filterMode: Int = 0
    var onWorldUpdated: (() -> Void)?
    
    private let service = CountryService()
    private let dataStore = DataStore()
    
    func updateFilterMode(_ mode: Int) {
        self.filterMode = mode
    }
    
    func updateWorldContinents(_ continents: [Continent]) {
        world?.continents = continents
    }
    
    func loadUserConfiguration() {
        if let savedConfig = dataStore.loadUserConfig() {
            currentConfig = savedConfig
        }
    }
    
    func loadEntireWorlddData() {
        if let savedWorld = dataStore.loadWorldData() {
            world = savedWorld
        } else {
            loadCountriesFromAPI()
        }
    }
    
    func saveUserConfiguratin(_ config: StudyConfiguration) {
        dataStore.saveUserConfig(config)
    }
   
    
    
    
    
    func loadCountriesFromAPI() {
        service.fetchAllCountries { apiCountries in
            let world = self.service.buildAtlas(from: apiCountries)
            
            DispatchQueue.main.async {
                self.world = world
                self.dataStore.saveWorldData(world)
                self.onWorldUpdated?()
            }
            
            //Print
            for (index,continent) in world.continents.enumerated() {
                print("******", index + 1, continent.name)
                for ((index),country) in continent.countries.enumerated() {
                    print("\(index + 1): \(country.name) - \(country.capital)")
                }
            }
        }
    }
}
