//
//  HeaderView.swift
//
//  Created by Dmitri on 10.12.25.
//
//  Description:
//  Reusable collection view header used to display
//  a continent title in learning and testing lists.
//

import UIKit

// MARK: - Continent Header View

final class ContinentHeader: UICollectionReusableView {
    
    // MARK: - Reuse Identifier
    
    static let reuseId = "ContinentHeader"
    
    // MARK: - UI Elements
    
    /// Displays the continent name
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20.scaled, weight: .bold)
        lbl.textAlignment = .left
        return lbl
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let c: CGFloat = 16.scaled
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Configuration
    
    /// Configures header with continent data
    func configure(continent: Continent) {
        titleLabel.text = continent.name
    }
}
