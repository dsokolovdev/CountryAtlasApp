//
//  DataStore.swift
//  AtlasMaster
//
//  Created by Dmitri on 08.12.25.
//

import Foundation

/// Responsible for persisting user data:
/// - Study configuration (UserDefaults)
/// - World model (JSON file in Documents directory)
final class DataStore {

    // MARK: - File URLs

    /// File URL for storing the serialized World model (world.json)
    private let worldURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("world.json")
    }()

    // MARK: - UserDefaults Keys

    /// Key for saving StudyConfiguration in UserDefaults
    private let configKey = "studyConfig"

    // MARK: - StudyConfiguration Persistence (UserDefaults)

    /// Saves the current study configuration (mode + region)
    /// - Parameter config: User-selected study configuration
    func saveUserConfig(_ config: StudyConfiguration) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(config) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }

    /// Loads the previously saved study configuration
    /// - Returns: Stored StudyConfiguration or nil if not found
    func loadUserConfig() -> StudyConfiguration? {
        if let data = UserDefaults.standard.data(forKey: configKey),
           let config = try? JSONDecoder().decode(StudyConfiguration.self, from: data) {
            return config
        }
        return nil
    }

    // MARK: - World Model Persistence (FileManager)

    /// Saves the World model as a JSON file to the Documents directory
    /// - Parameter world: Fully built World model
    func saveWorldData(_ world: World) {
        do {
            let data = try JSONEncoder().encode(world)
            try data.write(to: worldURL)
        } catch {
            print("Failed to save world:", error)
        }
    }

    /// Loads the World model from the local JSON file
    /// - Returns: Decoded World model or nil if loading fails
    func loadWorldData() -> World? {
        do {
            let data = try Data(contentsOf: worldURL)
            let world = try JSONDecoder().decode(World.self, from: data)
            return world
        } catch {
            print("Failed to load world:", error)
            return nil
        }
    }
}
