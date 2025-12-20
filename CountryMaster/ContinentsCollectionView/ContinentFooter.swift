//
//  FooterView.swift
//
//  Created by Dmitri on 10.12.25.
//
//  Description:
//  Footer view for continent sections.
//  Displays a simple summary label with completed items count.
//

import UIKit

// MARK: - Continent Footer View

final class ContinentFooter: UICollectionReusableView {
    
    // MARK: - Reuse Identifier
    
    static let reuseId = "ContinentFooter"
    
    // MARK: - UI
    
    /// Label displaying completed items count
    private let label = UILabel()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.font = .rounded(ofSize: 14.scaled)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        let c: CGFloat = 16.scaled
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -c),
            label.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Configuration
    
    /// Configures footer with completed items count
    func configure(count: Int) {
        label.text = "Done: \(count)"
    }
}
