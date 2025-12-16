//
//  CountryCell.swift
//  AtlasMaster
//
//  Created by Dmitri  on 09.12.25.
//
import UIKit

final class CountryCell: UICollectionViewCell {
    static let reusedId = "CountryCell"

    private let indexLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 14, weight: .light)
        lbl.textAlignment = .natural
        return lbl
    }()
    
    private let flagLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 66)
        lbl.textAlignment = .left
        return lbl
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 18, weight: .semibold)
        lbl.numberOfLines = 0
        lbl.textAlignment = .right
        return lbl
    }()

    private let capitalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 16, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .right
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let rightStack = UIStackView(arrangedSubviews: [nameLabel, capitalLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 4
        
        let leftStack = UIStackView(arrangedSubviews: [flagLabel ])
        leftStack.axis = .horizontal
        leftStack.alignment = .leading
        leftStack.spacing = 4

        let container = UIStackView(arrangedSubviews: [leftStack, rightStack])
        container.axis = .horizontal
        container.spacing = 8
        container.alignment = .center
       //container.distribution = .fill

        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let c: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: c),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -c),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        contentView.layer.cornerRadius = 10 * scaleFactor
        contentView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.2)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(country: Country, testingAspect: TestingAspect, isTestingMode: Bool, currentSegment: Int) {
        
        let countryName = country.name
        let capital = country.capital
        let flag = country.flag
        
        nameLabel.text = countryName
        capitalLabel.text = capital
        flagLabel.text = flag

        
        let displayedCountry = currentSegment == 0 ? maskString(originalString: countryName) : countryName
        let displayedCapital = currentSegment == 0 ? maskString(originalString: capital) : capital
        let displayedFlag = currentSegment == 0 ? "🏳️" : flag
        
        guard isTestingMode else { return }
        
        switch testingAspect {
        case .country:
            nameLabel.text = displayedCountry
        case .capital:
            capitalLabel.text = displayedCapital
        case .flag:
            flagLabel.text =  displayedFlag
        }
    }
}

extension CountryCell {
    func maskString(originalString: String) -> String {
        var newString = ""
        let components = originalString.split(separator: " ")
        for (index,component) in components.enumerated() {
            let maskedComponent = String(repeating: "*", count: component.count)
            newString += maskedComponent
            if index != components.count - 1 {
                newString += " "
            }
        }
        return newString
    }
}
