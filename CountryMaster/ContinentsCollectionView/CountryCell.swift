//
//  CountryCell.swift
//
//  Created by Dmitri on 09.12.25.
//

import UIKit

// MARK: - Country Cell
/// UICollectionViewCell that displays country information:
/// flag, country name, capital, and supports masking in testing mode.
final class CountryCell: UICollectionViewCell {

    // MARK: - Reuse Identifier
    static let reusedId = "CountryCell"

    // MARK: - UI Elements

    /// Index label (currently unused, reserved for future extensions)
    private let indexLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 14, weight: .light)
        lbl.textAlignment = .natural
        return lbl
    }()

    /// Emoji flag label
    private let flagLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 66)
        lbl.textAlignment = .left
        return lbl
    }()

    /// Country name label
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 18, weight: .semibold)
        lbl.numberOfLines = 0
        lbl.textAlignment = .right
        return lbl
    }()

    /// Capital city label
    private let capitalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 16, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .right
        return lbl
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Right side stack: country name + capital
        let rightStack = UIStackView(arrangedSubviews: [nameLabel, capitalLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 4

        // Left side stack: flag only
        let leftStack = UIStackView(arrangedSubviews: [flagLabel])
        leftStack.axis = .horizontal
        leftStack.alignment = .leading
        leftStack.spacing = 4

        // Main horizontal container
        let container = UIStackView(arrangedSubviews: [leftStack, rightStack])
        container.axis = .horizontal
        container.spacing = 8
        container.alignment = .center

        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        let c: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: c),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -c),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // Cell appearance
        contentView.layer.cornerRadius = 10 * scaleFactor
        contentView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.2)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Configuration

    /// Configures cell with country data.
    /// - Parameters:
    ///   - country: Country model
    ///   - testingAspect: Current testing aspect (country / capital / flag)
    ///   - isTestingMode: Indicates whether testing mode is active
    ///   - currentSegment: Selected testing segment (0 = masked)
    func configure(
        country: Country,
        testingAspect: TestingAspect,
        isTestingMode: Bool,
        currentSegment: Int
    ) {

        let countryName = country.name
        let capital = country.capital
        let flag = country.flag

        // Default (learning mode) values
        nameLabel.text = countryName
        capitalLabel.text = capital
        flagLabel.text = flag

        // Masked values for testing mode
        let displayedCountry =
            currentSegment == 0 ? maskString(originalString: countryName) : countryName

        let displayedCapital =
            currentSegment == 0 ? maskString(originalString: capital) : capital

        let displayedFlag =
            currentSegment == 0 ? "🏳️" : flag

        guard isTestingMode else { return }

        // Apply masking based on testing aspect
        switch testingAspect {
        case .country:
            nameLabel.text = displayedCountry
        case .capital:
            capitalLabel.text = displayedCapital
        case .flag:
            flagLabel.text = displayedFlag
        }
    }
}

// MARK: - Masking Helpers
extension CountryCell {

    /// Replaces each word in a string with asterisks, preserving word lengths.
    /// Example: "New York" → "*** ****"
    func maskString(originalString: String) -> String {
        var newString = ""
        let components = originalString.split(separator: " ")

        for (index, component) in components.enumerated() {
            let maskedComponent = String(repeating: "*", count: component.count)
            newString += maskedComponent

            if index != components.count - 1 {
                newString += " "
            }
        }

        return newString
    }
}
