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
    var filterMode: Int = 0
    
    var startedLearning: Bool = false
    var startedTesting: Bool = false
    
    var onWorldUpdated: (() -> Void)?
    
    private let service = CountryService()
    private let dataStore = DataStore()
    
    
    func filteredWorld() -> World {
        guard let world = world else { return World() }

        let selectedRegion = currentConfig.region
        let currentStudyMode = currentConfig.mode
        
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
                
                if currentStudyMode == .learning {
                    switch filterMode {
                    case 0: return !country.isLearned // To learn
                    case 1: return country.isLearned  // Learned
                    case 2: return true               // Statistics: All Continents
                    default: return true
                    }
                } else {
                    switch filterMode {
                    case 0: return (country.testResults[testingAspect] ?? .notTested) == .notTested // Test
                    case 1: return (country.testResults[testingAspect] ?? .notTested) == .failed    // Review
                    case 2: return (country.testResults[testingAspect] ?? .notTested) == .passed    // Passed
                    case 3: return true                                             // Statiscits
                    default: return true
                    }
                }
            }.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            
            let finalCountries: [Country]
            
            //shuffle only test segment
            if currentStudyMode == .testing && filterMode == 0 {
                finalCountries = filteredCountries.shuffled()
            } else  {
                finalCountries = filteredCountries
            }
            
            //hide empty continents
            if (filterMode == 1 || filterMode == 2) && filteredCountries.isEmpty {
                return nil
            }
            
            return Continent(name: continent.name, countries: finalCountries)
        }
        
        return World(continents: filteredContinents)
    }
    
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
        
        startedLearning = world.continents.flatMap { $0.countries }.contains { $0.isLearned }
    }
    
    private func updateStartedTestingFlags() {
        guard let world else {
            startedTesting = false
            return
        }
        
        startedTesting = world.continents.flatMap {$0.countries }.contains {$0.testResults[testingAspect] ?? .notTested != .notTested }
    }
    
    func resetTestingProgress() {
        world?.continents.indices.forEach { cIndex in
            world?.continents[cIndex].countries.indices.forEach { countryIndex in
                world?.continents[cIndex].countries[countryIndex].testResults[testingAspect] = .notTested
            }
        }
        
        updateStartedTestingFlags()
        
        if let world {
            dataStore.saveWorldData(world)
        }
        
        onWorldUpdated?()
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
    
    func setTestingAspect(_ aspect: TestingAspect) {
        testingAspect = aspect
        updateStartedTestingFlags()
    }
    
    //MARK: - Update Study Mode logyc
    func updateFilterMode(_ mode: Int) {
        self.filterMode = mode
    }
    
    func updateWorldContinents(_ continents: [Continent]) {
        world?.continents = continents
    }
    
    //MARK: - Swipes logic
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
            updateStartedTestingFlags()
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

//MARK: - Make Questions
extension AtlasModel {
    
    func makeTestQuestion(for country: Country) -> TestQuestion {
        let aspect = testingAspect

        let correctOption: TestOption
        switch aspect {
        case .capital:
            correctOption = TestOption(title: country.capital)
        case .country:
            correctOption = TestOption(title: country.name)
        case .flag:
            correctOption = TestOption(title: country.flag)
        }

        var options = [correctOption]

        let distractors = randomDistractors(for: aspect, excluding: country, count: 3)
        options.append(contentsOf: distractors)

        options.shuffle()

        let correctIndex = options.firstIndex(where: { $0 == correctOption })!

        return TestQuestion(country: country, options: options, correctIndex: correctIndex)
    }
    
    func randomDistractors(for aspect: TestingAspect,excluding country: Country,count: Int) -> [TestOption] {
        
        guard let world else { return [] }
        
       
        
        let selectedRegion = currentConfig.region
        //print(selectedRegion)
        
        let pool: [Country] = world.continents.filter { continent in
            switch selectedRegion {
            case .world:
                return true
            case .continent(let name):
                return continent.name == name
            }
        }.flatMap { $0.countries }
            .filter {
                $0 != country && $0.testResults[aspect] ?? .notTested == .notTested
        }
        
        //print(pool)
        
        guard pool.count >= count else { return [] }
        
        let selected = pool.shuffled().prefix(count)
        
        return selected.map {
            switch aspect {
            case .capital:
                return TestOption(title: $0.capital)
            case .country:
                return TestOption(title: $0.name)
            case .flag:
                return TestOption(title: $0.flag)
            }
        }
    }
    
    func updateTestResult(for country: Country, aspect: TestingAspect, result: Bool) {
        guard
            let continentIndex = world?.continents.firstIndex(where: { $0.countries.contains(country) } ),
            let countryIndex = world?.continents[continentIndex].countries.firstIndex(of: country)
        else { return }

        world?.continents[continentIndex].countries[countryIndex].testResults[aspect] = result ? .passed : .failed
        
        updateStartedTestingFlags()

        if let world {
            dataStore.saveWorldData(world)
        }

        onWorldUpdated?()
    }
}
