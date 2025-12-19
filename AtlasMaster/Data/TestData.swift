//
//  TestData.swift
//  AtlasMaster
//
//  Created by Dmitri on 15.12.25.
//

import UIKit

// MARK: - Testing Aspect

/// Defines what exactly is being tested for a country
/// (capital name, country name, or flag).
enum TestingAspect: String, Codable, CaseIterable {
    
    case capital
    case country
    case flag
    
    /// SF Symbol name used to visually represent the testing aspect.
    var iconName: String {
        switch self {
        case .capital: return "building.2.fill"
        case .country: return "globe.fill"
        case .flag:    return "flag.fill"
        }
    }
}

// MARK: - Test Result

/// Represents the result of a test attempt for a specific testing aspect.
enum TestResult: Codable {
    case notTested
    case passed
    case failed
}

// MARK: - Test Question Model

/// A single test question containing a country,
/// possible answer options, and the correct answer index.
struct TestQuestion {
    
    /// Country being tested.
    let country: Country
    
    /// Available answer options for the question.
    let options: [TestOption]
    
    /// Index of the correct option in the `options` array.
    let correctIndex: Int
}

// MARK: - Test Option

/// Represents a single selectable option in a test question.
struct TestOption: Equatable, Hashable {
    
    /// Display title for the option (text-based answer).
    let title: String?
    
    static func == (lhs: TestOption, rhs: TestOption) -> Bool {
        lhs.title == rhs.title
    }
}
