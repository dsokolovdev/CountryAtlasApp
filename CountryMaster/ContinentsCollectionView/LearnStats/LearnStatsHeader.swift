//
//  StatsHeader.swift
//
//  Created by Dmitri on 12.12.25.
//
//  Description:
//  Collection view reusable header used in Learning Statistics screen.
//  Displays continent name and optional star indicator for special sections
//  (e.g. World).
//

import UIKit

// MARK: - Learning Statistics Header View

final class LearnStatsHeader: UICollectionReusableView {
    
    // MARK: - Reuse Identifier
    
    static let reusedId = "LearnStatsHeader"
    
    // MARK: - UI Elements
    
    /// Displays continent or "World" name
    let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20.scaled, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .label
        return lbl
    }()
    
    /// Optional star icon used to highlight special sections (e.g. World)
    let starImage: UIImageView = {
        let img = UIImageView()
        let image = UIImage(systemName: "star.fill")!
        img.image = image.withRenderingMode(.alwaysTemplate)
        img.tintColor = .systemBlue
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        return img
    }()
    
    /// Horizontal container for title and star icon
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6.scaled
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add and configure stack view
        addSubview(hStack)
        hStack.addArrangedSubview(nameLabel)
        hStack.addArrangedSubview(starImage)
        
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints
        let c: CGFloat = 16.scaled
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -c),
            // hStack.topAnchor.constraint(equalTo: topAnchor)
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    /// Configures header appearance based on continent statistics
    func configure(continent: ContinentStats) {
        let learnedProgress = continent.learnedProgress
        let name = continent.name
        
        nameLabel.text = name
        
        // Special color handling for World section
        if nameLabel.text == "World" {
            nameLabel.textColor = learnedProgress > 0
            ? .blue
            : .blue.withAlphaComponent(0.5)
        } else {
            nameLabel.textColor = learnedProgress > 0
            ? .label
            : .tertiaryLabel
        }
        
        // Star tint reflects section type
        starImage.tintColor = name == "World" ? .purple : .blue
    }
}
