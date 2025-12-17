//
//  TestData.swift
//  AtlasMaster
//
//  Created by Dmitri  on 15.12.25.
//

import UIKit

enum TestingAspect: String, Codable, CaseIterable {
    case capital
    case country
    case flag
    
    var iconName: String {
        switch self {
        case .capital: return "building.2.fill"
        case .country: return "globe.fill"
        case .flag: return "flag.fill"
        }
    }
}

enum TestResult: Codable {
    case notTested
    case passed
    case failed
}


//???
struct TestQuestion {
    let country: Country
    let options: [TestOption]
    let correctIndex: Int
}

struct TestOption: Equatable, Hashable {
    let title: String?
    //let image: UIImage?
    
    static func == (lhs: TestOption, rhs: TestOption) -> Bool {
        lhs.title == rhs.title
    }
}


/*
 France.testResults = [
     .capital: .passed,
     .flag: .failed,
     .country: .passed
 ]
 */
