//
//  AtlastDataModel.swift
//  AtlasMaster
//
//  Created by Dmitri  on 08.12.25.
//
import UIKit

final class AtlasModel {
    var testingAspect: TestingAspect = .capital
    var currentConfig = StudyConfiguration(mode: .learning, region: .world)
    var world: World?
    var startedLearning: Bool = false
//    var currentWorld: World? {
//        //Define continent which is selected on picker in StudyModeViewController
//        let continentName: String
//        let region = currentConfig.region
//        var filteredContinents: [Continent] = []
//        if let w = world {
//            filteredContinents = w.continents
//        }
//        
//        switch region {
//        case .continent(let name): continentName = name
//        case .world : continentName = "World"
//        }
//        
//        if continentName == "World" {
//            filteredContinents = filteredContinents.map {
//                var c = $0
//                c.isSelected = true
//                return c
//            }
//        } else {
//            filteredContinents = filteredContinents.map {
//                var c = $0
//                c.name == continentName ? (c.isSelected = true) : (c.isSelected = false)
//                return c
//            }
//        }
//        
//        let showLearned = filterMode == 1
//        
//        filteredContinents = filteredContinents.filter{ $0.isSelected }.map { continent in
//            let filteredCountries = continent.countries.filter { $0.isLearned == showLearned }
//            return Continent(name: continent.name, countries: filteredCountries)
//        }
//        
//        return World(continents: filteredContinents)
//    }
    var filterMode: Int = 0
    var onWorldUpdated: (() -> Void)?
    
    private let service = CountryService()
    private let dataStore = DataStore()
    
    
    func filteredWorld() -> World {
        guard let world = world else { return World() }

        let selectedRegion = currentConfig.region
        //let showLearned = filterMode == 1
        
        let sortedContinents = world.continents.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }

        let filteredContinents = sortedContinents.compactMap { continent -> Continent? in
            
            // фильтр по региону
            switch selectedRegion {
            case .world: break
            case .continent(let name):
                if continent.name != name { return nil }
            }
            
            // фильтр по изученности
            let filteredCountries = continent.countries.filter { country in
                switch filterMode {
                case 0: return !country.isLearned // To learn
                case 1: return country.isLearned  // Learned
                case 2: return true               // Statistics → нужен полный список
                default: return true
                }
            }.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            
            if filterMode == 1 && filteredCountries.isEmpty {
                return nil
            }
            
            return Continent(name: continent.name, countries: filteredCountries)
        }
        
        
        
        return World(continents: filteredContinents)
    }
    
//    func getStatistics() -> [ContinentStats] {
//        guard let world = world else { return [] }
//        
//        return world.continents.map { c in
//            let total = c.countries.count
//            let learned = c.countries.filter { $0.isLearned }.count
//            let toLearn = total - learned
//            
//            return ContinentStats(
//                name: c.name,
//                total: total,
//                learned: learned,
//                toLearn: toLearn,
//                learnedProgress: Double(learned) / Double(total) * 100.0,
//                toLearnProgress: (1.0 - Double(learned) / Double(total)) * 100.0
//            )
//        }
//    }
    
    func getStatistics() -> [ContinentStats] {
        guard let world = world else { return [] }
        
        // World stats
        let worldTotals = world.continents.flatMap { $0.countries }.reduce((total: 0, learned: 0)) { acc, country in
            (total: acc.total + 1, learned: acc.learned + (country.isLearned ? 1 : 0))
        }
        let learnedRatio = worldTotals.total == 0 ? 0 : Double(worldTotals.learned) / Double(worldTotals.total)
        
        let worldStats = ContinentStats(
            name: "World",
            total: worldTotals.total,
            learned: worldTotals.learned,
            toLearn: worldTotals.total - worldTotals.learned,
            learnedProgress: learnedRatio,
            toLearnProgress: 1 - learnedRatio
        )
        
        // Continent stats
        let continentStats = world.continents.map { c in
            let total = c.countries.count
            let learned = c.countries.filter { $0.isLearned }.count
            let toLearn = total - learned
            let learnedRatio = total == 0 ? 0 : Double(learned) / Double(total)
            
            return ContinentStats(
                name: c.name,
                total: total,
                learned: learned,
                toLearn: toLearn,
                learnedProgress: learnedRatio,
                toLearnProgress: 1 - learnedRatio
            )
        }
        
        let sortedContinents = continentStats.sorted {
            if $0.learnedProgress != $1.learnedProgress {
                return $0.learnedProgress > $1.learnedProgress
            } else {
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }
        
        return [worldStats] + sortedContinents
    }
    
    //MARK: - Update Reset Button state
    private func updateStartedLearningFlag() {
        guard let world else {
            startedLearning = false
            return
        }
        
        startedLearning = world.continents
            .flatMap { $0.countries }
            .contains { $0.isLearned }
    }
    
    func resetLearningProgress() {
        world?.continents.indices.forEach { cIndex in
            world?.continents[cIndex].countries.indices.forEach { countryIndex in
                world?.continents[cIndex].countries[countryIndex].isLearned = false
            }
        }

        updateStartedLearningFlag()

        if let world {
            dataStore.saveWorldData(world)
        }

        onWorldUpdated?()
    }
    
    //MARK: - Update Study Mode logyc
    func updateFilterMode(_ mode: Int) {
        self.filterMode = mode
    }
    
    func updateWorldContinents(_ continents: [Continent]) {
        world?.continents = continents
    }
    
    //MARK: - Swipes logyc
    
    func markCountryAsLearned(at indexPath: IndexPath) {
        
        let currentContinent = filteredWorld().continents[indexPath.section]
        let tappedCountry = currentContinent.countries[indexPath.item]

        // 1. Находим континент в исходном world
        guard
            let continentIndex = world?.continents.firstIndex(where: { $0 == currentContinent })
        else { return }

        // 2. Находим оригинальный индекс страны
        guard
            let countryIndex = world?.continents[continentIndex].countries.firstIndex(where: { $0 == tappedCountry })
        else { return }

        // 3. Обновляем
        world?.continents[continentIndex].countries[countryIndex].isLearned.toggle()
        updateStartedLearningFlag()
        // ✅ Save Progress
           if let world {
               dataStore.saveWorldData(world)
           }
        
    }
    
    func getTotal(for indexPath: IndexPath) -> Int {
        let currentContinent = filteredWorld().continents[indexPath.section]
        guard
            let world = world,
            let continentIndex = world.continents.firstIndex(where: { $0 == currentContinent })
        else { return 0}
        
        return world.continents[continentIndex].countries.count
    }
    
    func getCurrentCount(for indexPath: IndexPath) -> Int {
        filteredWorld().continents[indexPath.section].countries.count
    }
    
    
    
    //MARK: - Load saved data
    func loadUserConfiguration() {
        if let savedConfig = dataStore.loadUserConfig() {
            currentConfig = savedConfig
        }
    }
    
    func loadEntireWorlddData() {
        if let savedWorld = dataStore.loadWorldData() {
            world = savedWorld
            updateStartedLearningFlag()
        } else {
            loadCountriesFromAPI()
        }
    }
    
    //MARK: - Save data
    func saveUserConfiguratin(_ config: StudyConfiguration) {
        dataStore.saveUserConfig(config)
    }
   
    //MARK: - Load API Data
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
