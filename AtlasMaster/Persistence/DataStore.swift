//
//  DataStore.swift
//  AtlasMaster
//
//  Created by Dmitri  on 08.12.25.
//

import Foundation

class DataStore {
    
    // MARK: - File URL for World.json
    private let worldURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("world.json")
    }()
    
    private let configKey = "studyConfig"
    
    // MARK: - Save / Load StudyConfiguration (UserDefaults)
    
    func saveUserConfig(_ config: StudyConfiguration) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(config) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }
    
    func loadUserConfig() -> StudyConfiguration? {
        if let data = UserDefaults.standard.data(forKey: configKey),
           let config = try? JSONDecoder().decode(StudyConfiguration.self, from: data) {
            return config
        }
        return nil
    }
    
    // MARK: - Save / Load World model as JSON (FileManager)
    
    func saveWorldData(_ world: World) {
        do {
            let data = try JSONEncoder().encode(world)
            try data.write(to: worldURL)
        } catch {
            print("Failed to save world:", error)
        }
    }
    
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




