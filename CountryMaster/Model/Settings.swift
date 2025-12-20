//
//  Settings.swift
//  CountryMaster
//
//  Created by Dmitri on 19.12.25.
//

import UIKit

// MARK: - App Settings Model
/// Static and structured settings used by SettingsViewController.
/// Contains UI sections and footer information.
struct Settings {

    // MARK: - Footer Text
    /// Footer text displayed at the bottom of Settings screen.
    /// Shows app name, version, build number and author info.
    static var settingsFooterText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"

        return """
        CountryMaster
        Version: \(version) (\(build))
        Made with ❤️  by D.S.
        © 2025
        """
    }

    // MARK: - Table Sections
    /// Sections displayed in Settings table view.
    /// Currently contains testing-related settings only.
    let sections: [Section] = [
        Section(title: "Testing mode", rows: [
            Row(text: "Mask mode")
        ])
    ]
}

// MARK: - Settings Section
/// Represents a table section in Settings screen.
struct Section {
    var title: String
    var rows: [Row]
}

// MARK: - Settings Row
/// Represents a single row inside a section.
struct Row {
    var text: String
}

// MARK: - Mask Mode (Shared)
/// Defines how answers are masked during testing mode.
/// Used by both Settings and CountryCell.
enum MaskMode: String, CaseIterable {

    /// Shuffled letters (light difficulty)
    case lite

    /// Asterisks per letter (normal difficulty)
    case normal

    /// Fully hidden value (hard difficulty)
    case hard

    /// Human-readable title shown in UI.
    var title: String {
        switch self {
        case .lite:
            return "Lite"
        case .normal:
            return "Normal"
        case .hard:
            return "Hard"
        }
    }
}
