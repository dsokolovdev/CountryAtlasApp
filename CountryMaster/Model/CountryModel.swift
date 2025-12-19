//
//
//  Created by Dmitri on 08.12.25.
//
//  Description:
//  Core application data model.
//  Responsible for:
//  - Managing world / continent / country data
//  - Handling learning & testing modes
//  - Applying filters and search logic
//  - Calculating statistics
//  - Persisting and restoring user progress
//

import UIKit

// MARK: - AtlasModel

final class CountryModel {

// MARK: - Configuration & State

/// Current testing aspect (capital / country / flag)
var testingAspect: TestingAspect = .capital

/// Current study configuration (mode + selected region)
var currentConfig = StudyConfiguration(mode: .learning, region: .world)

/// Full world data model
var world: World?

/// Selected filter segment index
var filterMode: Int = 0

/// Indicates whether learning progress exists
var startedLearning: Bool = false

/// Indicates whether testing progress exists
var startedTesting: Bool = false

/// Callback fired when world data changes
var onWorldUpdated: (() -> Void)?

// MARK: - Dependencies

private let service = CountryService()
private let dataStore = DataStore()

/// Current search query
private var searchQuery: String?

// MARK: - World Filtering

/// Returns a filtered copy of the world according to
/// region, study mode, filter segment and search query
func filteredWorld() -> World {
    guard let world = world else { return World() }

    let selectedRegion = currentConfig.region
    let currentStudyMode = currentConfig.mode

    let sortedContinents = world.continents.sorted {
        $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
    }

    let filteredContinents = sortedContinents.compactMap { continent -> Continent? in

        // MARK: Region filter
        switch selectedRegion {
        case .world: break
        case .continent(let name):
            if continent.name != name { return nil }
        }

        // MARK: Country filter
        let filteredCountries = continent.countries.filter { country in

            // Search filter
            guard matchesSearch(continent: continent.name, country: country) else { return false }

            if currentStudyMode == .learning {
                switch filterMode {
                case 0: return !country.isLearned // To learn
                case 1: return country.isLearned  // Learned
                case 2: return true               // Statistics
                default: return true
                }
            } else {
                // Exclude countries without capital for "country" testing
                if testingAspect == .country && country.capital == "No capital" {
                    return false
                }
                switch filterMode {
                case 0: return (country.testResults[testingAspect] ?? .notTested) == .notTested // Test
                case 1: return (country.testResults[testingAspect] ?? .notTested) == .failed    // Review
                case 2: return (country.testResults[testingAspect] ?? .notTested) == .passed    // Passed
                case 3: return true                                                           // Statistics
                default: return true
                }
            }
        }
        .sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }

        // MARK: Shuffle logic (testing only)
        let finalCountries: [Country]
        if currentStudyMode == .testing && filterMode == 0 {
            finalCountries = filteredCountries.shuffled()
        } else {
            finalCountries = filteredCountries
        }

        // Hide empty continents
        if (filterMode == 1 || filterMode == 2) && filteredCountries.isEmpty {
            return nil
        }

        return Continent(name: continent.name, countries: finalCountries)
    }

    return World(continents: filteredContinents)
}

// MARK: - Learning Statistics

/// Returns learning statistics for World and all continents
func getStatistics() -> [ContinentStats] {
    guard let world = world else { return [] }

    // MARK: World statistics
    let worldTotals = world.continents
        .flatMap { $0.countries }
        .reduce((total: 0, learned: 0)) { acc, country in
            (total: acc.total + 1, learned: acc.learned + (country.isLearned ? 1 : 0))
        }

    let learnedRatio = worldTotals.total == 0
        ? 0
        : Double(worldTotals.learned) / Double(worldTotals.total)

    let worldStats = ContinentStats(
        name: "World",
        total: worldTotals.total,
        learned: worldTotals.learned,
        toLearn: worldTotals.total - worldTotals.learned,
        learnedProgress: learnedRatio,
        toLearnProgress: 1 - learnedRatio
    )

    // MARK: Continent statistics
    let continentsForStats = world.continents.filter {
        matchesContinentStats(name: $0.name)
    }

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

// MARK: - Testing Statistics

/// Returns testing statistics for World and continents
func getTestStatistics() -> [ContinentTestStats] {
    guard let world else { return [] }

    let aspect = testingAspect

    // Continents filtered by search
    let continentsForStats = world.continents.filter {
        matchesContinentStats(name: $0.name)
    }

    // MARK: World statistics (not affected by search)
    let allWorldCountries = world.continents.flatMap { $0.countries }

    let worldPassed = allWorldCountries.filter { $0.testResults[aspect] == .passed }.count
    let worldFailed = allWorldCountries.filter { $0.testResults[aspect] == .failed }.count
    let worldUntested = allWorldCountries.filter {
        ($0.testResults[aspect] ?? .notTested) == .notTested
    }.count

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

    // MARK: Continent statistics
    let continentStats = continentsForStats.map { continent in
        let countries = continent.countries

        let passed = countries.filter { $0.testResults[aspect] == .passed }.count
        let failed = countries.filter { $0.testResults[aspect] == .failed }.count
        let untested = countries.filter {
            ($0.testResults[aspect] ?? .notTested) == .notTested
        }.count

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

    // Sort by completion, then by name
    let sortedContinents = continentStats.sorted {
        if $0.finishedRatio != $1.finishedRatio {
            return $0.finishedRatio > $1.finishedRatio
        } else {
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    return [worldStats] + sortedContinents
}

// MARK: - Progress State Updates

/// Updates flag indicating whether learning has started
private func updateStartedLearningFlag() {
    guard let world else {
        startedLearning = false
        return
    }

    startedLearning = world.continents
        .flatMap { $0.countries }
        .contains { $0.isLearned }
}

/// Updates flag indicating whether testing has started
private func updateStartedTestingFlags() {
    guard let world else {
        startedTesting = false
        return
    }

    startedTesting = world.continents
        .flatMap { $0.countries }
        .contains { ($0.testResults[testingAspect] ?? .notTested) != .notTested }
}

// MARK: - Reset Actions

/// Resets all testing results for the current testing aspect
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

/// Resets all learning progress
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

// MARK: - Configuration Updates

/// Sets active testing aspect
func setTestingAspect(_ aspect: TestingAspect) {
    testingAspect = aspect
    updateStartedTestingFlags()
}

/// Updates selected filter segment
func updateFilterMode(_ mode: Int) {
    self.filterMode = mode
}

/// Updates world continents after external modification
func updateWorldContinents(_ continents: [Continent]) {
    world?.continents = continents
}

// MARK: - Swipe Actions

/// Toggles learned state for a country at indexPath
func markCountryAsLearned(at indexPath: IndexPath) {
    let currentContinent = filteredWorld().continents[indexPath.section]
    let tappedCountry = currentContinent.countries[indexPath.item]

    guard
        let continentIndex = world?.continents.firstIndex(where: { $0 == currentContinent }),
        let countryIndex = world?.continents[continentIndex].countries.firstIndex(where: { $0 == tappedCountry })
    else { return }

    world?.continents[continentIndex].countries[countryIndex].isLearned.toggle()
    updateStartedLearningFlag()

    if let world {
        dataStore.saveWorldData(world)
    }
}

// MARK: - Helpers

/// Returns total number of countries for a section
func getTotal(for indexPath: IndexPath) -> Int {
    let currentContinent = filteredWorld().continents[indexPath.section]
    guard
        let world = world,
        let continentIndex = world.continents.firstIndex(where: { $0 == currentContinent })
    else { return 0 }

    return world.continents[continentIndex].countries.count
}

/// Returns current number of visible countries for a section
func getCurrentCount(for indexPath: IndexPath) -> Int {
    filteredWorld().continents[indexPath.section].countries.count
}

// MARK: - Persistence

/// Loads saved user configuration
func loadUserConfiguration() {
    if let savedConfig = dataStore.loadUserConfig() {
        currentConfig = savedConfig
    }
}

/// Loads world data from storage or API
func loadEntireWorlddData() {
    if let savedWorld = dataStore.loadWorldData() {
        world = savedWorld
        updateStartedLearningFlag()
        updateStartedTestingFlags()
    } else {
        loadCountriesFromAPI()
    }
}

/// Saves user configuration
func saveUserConfiguratin(_ config: StudyConfiguration) {
    dataStore.saveUserConfig(config)
}

/// Loads countries from API and builds world model
func loadCountriesFromAPI() {
    service.fetchAllCountries { apiCountries in
        let world = self.service.buildAtlas(from: apiCountries)

        DispatchQueue.main.async {
            self.world = world
            self.dataStore.saveWorldData(world)
            self.onWorldUpdated?()
        }
    }
}

}

// MARK: - Test Question Generation

extension CountryModel {

/// Builds a test question for a given country
func makeTestQuestion(for country: Country) -> TestQuestion {
    let aspect = testingAspect
    let correctTitle = title(for: country, aspect: aspect)

    var titles = Set<String>()
    titles.insert(correctTitle)

    let distractors = randomDistractorTitles(
        for: aspect,
        excluding: country,
        correctTitle: correctTitle,
        count: 3
    )

    titles.formUnion(distractors)

    let options = titles.map { TestOption(title: $0) }.shuffled()

    guard let correctIndex = options.firstIndex(where: { $0.title == correctTitle }) else {
        return TestQuestion(country: country, options: options, correctIndex: 0)
    }

    return TestQuestion(country: country, options: options, correctIndex: correctIndex)
}

/// Returns correct answer title for a given aspect
private func title(for country: Country, aspect: TestingAspect) -> String {
    switch aspect {
    case .capital: return country.capital
    case .country: return country.name
    case .flag:    return country.flag
    }
}

/// Generates random distractor titles for testing
private func randomDistractorTitles(
    for aspect: TestingAspect,
    excluding country: Country,
    correctTitle: String,
    count: Int
) -> Set<String> {

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

    func makePool(from countries: [Country]) -> [String] {
        countries
            .map { title(for: $0, aspect: aspect) }
            .filter {
                !$0.isEmpty &&
                $0 != correctTitle &&
                !(aspect == .capital && $0 == "No capital")
            }
    }

    let pool1 = makePool(from: allInRegion.filter { ($0.testResults[aspect] ?? .notTested) == .notTested })
    let pool2 = makePool(from: allInRegion)
    let pool3 = makePool(from: allWorld)

    var result = Set<String>()

    for pool in [pool1, pool2, pool3] {
        for t in pool.shuffled() {
            result.insert(t)
            if result.count == count { return result }
        }
    }

    return result
}

/// Updates test result for a country
func updateTestResult(for country: Country, aspect: TestingAspect, result: Bool) {
    guard
        let continentIndex = world?.continents.firstIndex(where: { $0.countries.contains(country) }),
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

// MARK: - Search Handling

extension CountryModel {

/// Updates search query
func setSearchQuery(_ query: String?) {
    searchQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
}

/// Returns enabled search scopes based on mode and segment
private func searchFlags() -> (continent: Bool, country: Bool, capital: Bool) {
    let mode = currentConfig.mode
    let segment = filterMode
    let aspect = testingAspect

    switch mode {
    case .learning:
        if segment == 2 { return (true, false, false) }
        return (true, true, true)

    case .testing:
        if segment == 1 || segment == 2 { return (true, true, true) }
        if segment == 3 { return (true, false, false) }

        switch aspect {
        case .capital: return (true, true, false)
        case .country: return (true, false, true)
        case .flag:    return (true, true, true)
        }
    }
}

/// Applies search query to continent and country
private func matchesSearch(continent: String, country: Country) -> Bool {
    guard let q = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty else { return true }

    let flags = searchFlags()

    if flags.continent, continent.localizedCaseInsensitiveContains(q) { return true }
    if flags.country,   country.name.localizedCaseInsensitiveContains(q) { return true }
    if flags.capital,   country.capital.localizedCaseInsensitiveContains(q) { return true }

    return false
}

/// Applies search query to continent statistics
private func matchesContinentStats(name: String) -> Bool {
    guard let q = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty else { return true }
    return name.localizedCaseInsensitiveContains(q)
}

}
