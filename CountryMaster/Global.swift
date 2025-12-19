//
//  Global.swift
//
//  Created by Dmitri  on 07.12.25.
//


import UIKit

// MARK: - Screen Size Flags
/// Detects small screen devices (e.g., iPhone SE / Mini).
var isSmallScreen: Bool {
    UIScreen.main.bounds.height < 750
}

// MARK: - Screen Classes
/// Represents major device categories for responsive UI scaling.
enum ScreenClass {
    case se
    case mini
    case normal
    case proMax
    case iPad
}

/// Detects the current device class based on screen size and interface idiom.
var screenClass: ScreenClass {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return .iPad
    }
    
    let h = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    
    switch h {
    case ..<700:    return .se
    case 700..<830: return .mini
    case 830..<900: return .normal
    default:        return .proMax
    }
}

// MARK: - Scale Factor
/// Global UI scale factor applied across the app.
/// Ensures consistent sizing across different device classes.
var scaleFactor: CGFloat {
    switch screenClass {
    case .se:     return 0.86
    case .mini:   return 0.95
    case .normal: return 1.0
    case .proMax: return 1.08
    case .iPad:   return 1.18
    }
}

// MARK: - Player Names
/// Standardized player identifiers used in UI and model.
enum Players: String {
    case player1 = "P1"
    case player2 = "P2"
    case player3 = "P3"
    case player4 = "P4"
    
    var name: String { rawValue }
}

// MARK: - Layout Types
/// Defines the visual layout mode for ScoresView.
enum LayoutType: String {
    case row
    case grid
    
    /// SF Symbol representing each layout mode.
    var iconName: String {
        switch self {
        case .row:
            return "circle.grid.2x1.fill"
        case .grid:
            return "circle.grid.3x3.fill"
        }
    }
}
