//
//  Settings.swift
//  CountryMaster
//
//  Created by Dmitri  on 19.12.25.
//
import UIKit

struct Settings {
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
}
