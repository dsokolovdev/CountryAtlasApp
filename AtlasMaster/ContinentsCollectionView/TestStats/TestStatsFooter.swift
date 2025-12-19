//
//  TestStatsFooter.swift
//  AtlasMaster
//
//  Created by Dmitri on 18.12.25.
//
//  Description:
//  Footer view for Test Statistics section.
//  Displays numeric counters for Passed / Failed / Untested countries
//  within a continent or for the World.
//

import UIKit

// MARK: - Test Stats Footer View

final class TestStatsFooter: UICollectionReusableView {

    // MARK: - Reuse Identifier

    static let reusedId = "TestStatsFooter"

    // MARK: - Value Labels

    /// Displays number of passed tests
    private let passedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    /// Displays number of failed tests
    private let failedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    /// Displays number of untested items
    private let notTestedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    // MARK: - Static Text Labels

    /// Static "Passed:" label
    private let passedLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Passed:"
        lbl.font = .rounded(ofSize: 14)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    /// Static "Failed:" label
    private let failedLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Failed:"
        lbl.font = .rounded(ofSize: 14)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    /// Static "Untested:" label
    private let notTestedLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Untested:"
        lbl.font = .rounded(ofSize: 14)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    // MARK: - Stack Views (Groups)

    /// Stack for Passed counter
    private let hStackPassed: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Stack for Failed counter
    private let hStackFailed: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Stack for Untested counter
    private let hStackUntested: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Stack containing Passed + Failed groups
    private let hStackProgress: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillProportionally
        stack.alignment = .center
        return stack
    }()

    /// Root horizontal stack
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Build Passed group
        hStackFailed.addArrangedSubview(failedLabelText)
        hStackFailed.addArrangedSubview(failedLabel)

        // Build Failed group
        hStackPassed.addArrangedSubview(passedLabelText)
        hStackPassed.addArrangedSubview(passedLabel)

        // Build Untested group
        hStackUntested.addArrangedSubview(notTestedLabelText)
        hStackUntested.addArrangedSubview(notTestedLabel)

        // Combine Passed + Failed
        hStackProgress.addArrangedSubview(hStackFailed)
        hStackProgress.addArrangedSubview(hStackPassed)

        // Root layout
        hStack.addArrangedSubview(hStackProgress)
        hStack.addArrangedSubview(hStackUntested)

        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false

        let c: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -c),
            hStack.topAnchor.constraint(equalTo: topAnchor)
        ])

        // Prevent compression of numeric labels
        passedLabelText.setContentHuggingPriority(.required, for: .horizontal)
        failedLabel.setContentHuggingPriority(.required, for: .horizontal)
        failedLabelText.setContentHuggingPriority(.required, for: .horizontal)
        notTestedLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Updates footer values based on test statistics
    func configure(continent: ContinentTestStats) {
        let passed = continent.passed
        let failed = continent.failed
        let untested = continent.untested
        let progress = passed + failed

        passedLabel.text = "\(passed)"
        failedLabel.text = "\(failed)"
        notTestedLabel.text = "\(untested)"

        passedLabel.textColor = progress > 0 ? .secondaryLabel : .tertiaryLabel
        failedLabel.textColor = progress > 0 ? .secondaryLabel : .tertiaryLabel
        notTestedLabel.textColor = progress > 0 ? .secondaryLabel : .tertiaryLabel
        passedLabelText.textColor = progress > 0 ? .secondaryLabel : .tertiaryLabel
        failedLabelText.textColor = progress > 0 ? .secondaryLabel : .tertiaryLabel
        notTestedLabelText.textColor = progress > 0 ? .secondaryLabel : .tertiaryLabel
    }
}
