//
//  StatsTestHeader.swift
//  AtlasMaster
//
//  Created by Dmitri on 18.12.25.
//
//  Description:
//  Collection reusable header view for Testing statistics section.
//  Displays continent name and applies special styling for "World".
//

import UIKit

// MARK: - Test Statistics Header

final class TestStatHeader: UICollectionReusableView {

    // MARK: - Reuse Identifier

    static let reusedId = "StatsTestHeader"

    // MARK: - UI Elements

    /// Label displaying continent or "World" name
    let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .label
        return lbl
    }()

    /// Optional star icon (used to visually emphasize "World")
    let starImage: UIImageView = {
        let img = UIImageView()
        let image = UIImage(systemName: "star.fill")!
        img.image = image.withRenderingMode(.alwaysTemplate)
        img.tintColor = .systemBlue
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        return img
    }()

    /// Horizontal container for title and icon
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(hStack)
        hStack.addArrangedSubview(nameLabel)
        hStack.addArrangedSubview(starImage)

        hStack.translatesAutoresizingMaskIntoConstraints = false

        let c: CGFloat = 16 * scaleFactor
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

    /// Configures header appearance based on testing statistics
    /// - Parameter continent: ContinentTestStats model
    func configure(continent: ContinentTestStats) {
        let learnedProgress = continent.passed
        let name = continent.name

        nameLabel.text = name

        if nameLabel.text == "World" {
            nameLabel.textColor = learnedProgress > 0
                ? .blue
                : .blue.withAlphaComponent(0.5)
        } else {
            nameLabel.textColor = learnedProgress > 0
                ? .label
                : .tertiaryLabel
        }

        starImage.tintColor = name == "World" ? .purple : .blue
    }
}
