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
    
    private var searchQuery: String?
    
    
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
                
                guard matchesSearch(continent: continent.name, country: country) else { return false }
                
                if currentStudyMode == .learning {
                    switch filterMode {
                    case 0: return !country.isLearned // To learn
                    case 1: return country.isLearned  // Learned
                    case 2: return true               // Statistics: All Continents
                    default: return true
                    }
                } else {
                    // ⛔️ исключаем страны без столицы для теста "country"
                    if testingAspect == .country && country.capital == "No capital" {
                        return false
                    }
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
        
        let continentsForStats = world.continents.filter { matchesContinentStats(name: $0.name) }
        
        // Continent stats
        let continentStats = continentsForStats.map { c in
            
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
    
    
//    func getTestStatistics() -> [ContinentTestStats] {
//        guard let world else { return [] }
//
//        let aspect = testingAspect
//
//        // фильтр континентов по поиску (как в learning stats)
//        let continentsForStats = world.continents
//            .filter { matchesContinentStats(name: $0.name) }
//
//        let continentStats = continentsForStats.map { continent -> ContinentTestStats in
//            let countries = continent.countries
//
//            let total = countries.count
//
//            let passed = countries.filter {
//                ($0.testResults[aspect] ?? .notTested) == .passed
//            }.count
//
//            let failed = countries.filter {
//                ($0.testResults[aspect] ?? .notTested) == .failed
//            }.count
//
//            let untested = countries.filter {
//                ($0.testResults[aspect] ?? .notTested) == .notTested
//            }.count
//
//            let finished = passed + failed
//
//            let finishedRatio =
//                total > 0 ? Double(finished) / Double(total) : 0
//
//            let passedRatio =
//                finished > 0 ? Double(passed) / Double(finished) : 0
//
//            let failedRatio =
//                finished > 0 ? Double(failed) / Double(finished) : 0
//
//            return ContinentTestStats(
//                name: continent.name,
//                total: total,
//                passed: passed,
//                failed: failed,
//                untested: untested,
//                finishedRatio: finishedRatio,
//                passedRatio: passedRatio,
//                failedRatio: failedRatio
//            )
//        }
//
//        // сортировка — сначала более завершённые
//        let sorted = continentStats.sorted {
//            if $0.finishedRatio != $1.finishedRatio {
//                return $0.finishedRatio > $1.finishedRatio
//            } else {
//                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
//            }
//        }
//
//        return sorted
//    }
    
    func getTestStatistics() -> [ContinentTestStats] {
            guard let world else { return [] }

            let aspect = testingAspect

            // 🔹 Фильтруем континенты по search (как в learning stats)
            let continentsForStats = world.continents.filter {
                matchesContinentStats(name: $0.name)
            }

            // MARK: - World stats

            // MARK: - World stats (❗️БЕЗ search-фильтра)

            let allWorldCountries = world.continents.flatMap { $0.countries }

            let worldPassed = allWorldCountries.filter { $0.testResults[aspect] == .passed }.count
            let worldFailed = allWorldCountries.filter { $0.testResults[aspect] == .failed }.count
            let worldUntested = allWorldCountries.filter { ($0.testResults[aspect] ?? .notTested) == .notTested }.count

            let worldTotal = allWorldCountries.count
            let worldFinished = worldPassed + worldFailed

            let worldStats = ContinentTestStats(
                name: "World",
                total: worldTotal,
                passed: worldPassed,
                failed: worldFailed,
                untested: worldUntested,
                finishedRatio: worldTotal > 0 ? Double(worldFinished) / Double(worldTotal) : 0,
                passedRatio: worldFinished > 0 ? Double(worldPassed) / Double(worldFinished) : 0,
                failedRatio: worldFinished > 0 ? Double(worldFailed) / Double(worldFinished) : 0
            )

            // MARK: - Continent stats

            let continentStats: [ContinentTestStats] = continentsForStats.map { continent in
                let countries = continent.countries

                let passed = countries.filter { $0.testResults[aspect] == .passed }.count
                let failed = countries.filter { $0.testResults[aspect] == .failed }.count
                let untested = countries.filter { ($0.testResults[aspect] ?? .notTested) == .notTested }.count
                let total = countries.count
                let finished = passed + failed

                return ContinentTestStats(
                    name: continent.name,
                    total: total,
                    passed: passed,
                    failed: failed,
                    untested: untested,
                    finishedRatio: total > 0 ? Double(finished) / Double(total) : 0,
                    passedRatio: finished > 0 ? Double(passed) / Double(finished) : 0,
                    failedRatio: finished > 0 ? Double(failed) / Double(finished) : 0
                )
            }

            // MARK: - Sorting (по завершённости, затем по имени)

            let sortedContinents = continentStats.sorted {
                if $0.finishedRatio != $1.finishedRatio {
                    return $0.finishedRatio > $1.finishedRatio
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

        let correctTitle = title(for: country, aspect: aspect)

        var titles = Set<String>()
        titles.insert(correctTitle)

        let distractors = randomDistractorTitles(for: aspect, excluding: country, correctTitle: correctTitle, count: 3)

        titles.formUnion(distractors)

        let options = titles.map { TestOption(title: $0) }.shuffled()

        // ✅ НЕ ПАДАЕМ
        guard let correctIndex = options.firstIndex(where: { $0.title == correctTitle }) else {
            // на практике сюда не должно попасть, но лучше вернуть “безопасно”
            return TestQuestion(country: country, options: options, correctIndex: 0)
        }

        return TestQuestion(country: country, options: options, correctIndex: correctIndex)
    }
    
    private func title(for country: Country, aspect: TestingAspect) -> String {
        switch aspect {
        case .capital: return country.capital
        case .country: return country.name
        case .flag:    return country.flag
        }
    }
    
    private func randomDistractorTitles(for aspect: TestingAspect, excluding country: Country, correctTitle: String, count: Int) -> Set<String> {

        guard let world else { return [] }

        func regionFilter(_ continent: Continent) -> Bool {
            switch currentConfig.region {
            case .world: return true
            case .continent(let name): return continent.name == name
            }
        }

        let allInRegion = world.continents
            .filter(regionFilter)
            .flatMap { $0.countries }
            .filter { $0 != country }

        let allWorld = world.continents
            .flatMap { $0.countries }
            .filter { $0 != country }

        // ВАЖНО: убираем дубликаты “No capital” (и вообще всё, что == correctTitle)
        func makePool(from countries: [Country]) -> [String] {
            countries.map { title(for: $0, aspect: aspect) }.filter { !$0.isEmpty && $0 != correctTitle && !(aspect == .capital && $0 == "No capital")}
        }

        // 1) notTested в регионе
        let pool1Countries = allInRegion.filter { ($0.testResults[aspect] ?? .notTested) == .notTested }
        // 2) все статусы в регионе (notTested + failed + passed)
        let pool2Countries = allInRegion
        // 3) весь мир (на случай Antarctica)
        let pool3Countries = allWorld

        var result = Set<String>()

        for pool in [makePool(from: pool1Countries), makePool(from: pool2Countries), makePool(from: pool3Countries)] {
            for t in pool.shuffled() {
                result.insert(t)
                if result.count == count { return result }
            }
        }

        return result
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

extension AtlasModel {
    func setSearchQuery(_ query: String?) {
        searchQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    //MARK: - Search Filters
    private func searchFlags() -> (continent: Bool, country: Bool, capital: Bool) {
        let mode = currentConfig.mode
        let segment = filterMode
        let aspect = testingAspect
        
        switch mode {
        case .learning:
            if segment == 2 { return (true, false, false ) }
            return (true , true, true)
        case .testing:
            if segment == 1 || segment == 2 { return (true, true, true ) }
            if segment == 3 { return (true, false, false ) }
            
            switch aspect {
            case .capital:
                return (true, true, false)
            case .country:
                return (true, false, true)
            case .flag:
                return (true, true, true)
            }
        }
    }
    
    private func matchesSearch(continent: String, country: Country) -> Bool {
        guard let q = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty else { return true }
        
        let flags = searchFlags()
        
        if flags.continent, continent.localizedCaseInsensitiveContains(q) { return true }
        if flags.country,   country.name.localizedCaseInsensitiveContains(q) { return true }
        if flags.capital,   country.capital.localizedCaseInsensitiveContains(q) { return true }
        
        return false
    }
    
    private func matchesContinentStats(name: String) -> Bool {
        guard let q = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty
        else { return true }
        
        return name.localizedCaseInsensitiveContains(q)
    }
    
}
