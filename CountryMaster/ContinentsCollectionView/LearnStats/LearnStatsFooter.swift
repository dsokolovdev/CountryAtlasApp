//
//  StatsFooter.swift
//
//  Created by Dmitri on 12.12.25.
//
//  Description:
//  Footer view for learning statistics section.
//  Displays total countries count, learned count,
//  and remaining countries to learn.
//

import UIKit

// MARK: - Learn Stats Footer

final class LearnStatsFooter: UICollectionReusableView {

    // MARK: - Reuse Identifier

    static let reusedId = "LearnStatsFooter"

    // MARK: - Value Labels

    /// Displays total number of countries
    private let totalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    /// Displays number of learned countries
    private let learnedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    /// Displays number of countries left to learn
    private let toLearnLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    // MARK: - Static Text Labels

    private let totalLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Total:"
        lbl.font = .rounded(ofSize: 14)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    private let learnedLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Learned:"
        lbl.font = .rounded(ofSize: 14)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    private let toLearnLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "To learn:"
        lbl.font = .rounded(ofSize: 14)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    // MARK: - Stack Views

    /// Stack for total count
    private let hStackTotal: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Stack for learned count
    private let hStackLearned: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Stack for remaining count
    private let hStackToLearn: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Stack containing learned / to-learn blocks
    private let hStackProgress: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillProportionally
        stack.alignment = .center
        return stack
    }()

    /// Main horizontal container
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Build total stack
        hStackTotal.addArrangedSubview(totalLabelText)
        hStackTotal.addArrangedSubview(totalLabel)

        // Build learned stack
        hStackLearned.addArrangedSubview(learnedLabelText)
        hStackLearned.addArrangedSubview(learnedLabel)

        // Build to-learn stack
        hStackToLearn.addArrangedSubview(toLearnLabelText)
        hStackToLearn.addArrangedSubview(toLearnLabel)

        // Combine learned and to-learn stacks
        hStackProgress.addArrangedSubview(hStackLearned)
        hStackProgress.addArrangedSubview(hStackToLearn)

        // Main layout stack
        hStack.addArrangedSubview(hStackTotal)
        hStack.addArrangedSubview(hStackProgress)

        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false

        let c: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -c),
            hStack.topAnchor.constraint(equalTo: topAnchor)
        ])

        // Layout priorities
        totalLabelText.setContentHuggingPriority(.required, for: .horizontal)
        learnedLabel.setContentHuggingPriority(.required, for: .horizontal)
        learnedLabelText.setContentHuggingPriority(.required, for: .horizontal)
        toLearnLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Updates footer with statistics for selected continent
    func configure(continent: ContinentStats) {
        let learned = continent.learned
        let total = continent.total
        let toLearn = continent.toLearn

        totalLabel.text = "\(total)"
        learnedLabel.text = "\(learned)"
        toLearnLabel.text = "\(toLearn)"

        let activeColor: UIColor = learned > 0 ? .secondaryLabel : .tertiaryLabel

        totalLabel.textColor = activeColor
        learnedLabel.textColor = activeColor
        toLearnLabel.textColor = activeColor
        totalLabelText.textColor = activeColor
        learnedLabelText.textColor = activeColor
        toLearnLabelText.textColor = activeColor
    }
}
