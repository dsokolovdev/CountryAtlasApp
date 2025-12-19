//
//  StatsCell.swift
//  AtlasMaster
//
//  Created by Dmitri on 12.12.25.
//
//  Description:
//  UICollectionViewCell displaying learning statistics:
//  - Rounded progress bar
//  - Learned / To Learn percentage labels
//  - Used for World and Continent statistics
//

import UIKit

// MARK: - Learn Stats Cell

final class LearnStatsCell: UICollectionViewCell {

    // MARK: - Reuse Identifier

    static let reusedId = "LearnStatsCell"

    // MARK: - UI Components

    /// Rounded progress bar showing learned progress
    let progressView = LearnProgressView()

    /// Percentage label for learned countries
    private let learnedProgressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 22, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .systemGreen
        return lbl
    }()

    /// Percentage label for countries still to learn
    private let toLearnProgressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 22, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .systemYellow
        return lbl
    }()

    /// Separator label between learned / to-learn values
    private let dashLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .regular)
        lbl.textAlignment = .center
        lbl.text = "/"
        return lbl
    }()

    /// Percent symbol for learned value
    private let percentLearnedLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "%"
        lbl.font = .rounded(ofSize: 16, weight: .semibold)
        lbl.textAlignment = .left
        return lbl
    }()

    /// Percent symbol for to-learn value
    private let percentToLearnLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "%"
        lbl.font = .rounded(ofSize: 16, weight: .semibold)
        lbl.textAlignment = .left
        return lbl
    }()

    // MARK: - Stack Views

    /// Stack for learned percentage + percent symbol
    private let hStackLearned: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Stack for to-learn percentage + percent symbol
    private let hStackToLearn: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Main horizontal stack containing both values
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        // MARK: Progress View Layout

        addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false

        let h: CGFloat = 1 * scaleFactor
        let w: CGFloat = 16 * scaleFactor

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: w),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -w),
            progressView.topAnchor.constraint(equalTo: topAnchor, constant: h),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -h)
        ])

        // MARK: Percentage Labels Layout

        hStackLearned.addArrangedSubview(learnedProgressLabel)
        hStackLearned.addArrangedSubview(percentLearnedLabel)

        hStackToLearn.addArrangedSubview(toLearnProgressLabel)
        hStackToLearn.addArrangedSubview(percentToLearnLabel)

        hStack.addArrangedSubview(hStackLearned)
        hStack.addArrangedSubview(dashLabel)
        hStack.addArrangedSubview(hStackToLearn)

        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false

        let width: CGFloat = 200 * scaleFactor
        let height: CGFloat = 10 * scaleFactor

        NSLayoutConstraint.activate([
            hStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            hStack.topAnchor.constraint(equalTo: progressView.topAnchor, constant: height),
            hStack.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -height),
            hStack.widthAnchor.constraint(equalToConstant: width)
        ])

        // Ensure separator keeps its intrinsic width
        dashLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configures the cell with learning statistics
    func configure(with stats: ContinentStats) {

        let name = stats.name
        let learnedProgress = stats.learnedProgress
        let toLearnProgress = stats.toLearnProgress

        // Reset progress before updating
        progressView.setProgress(0)

        // Update percentage labels
        learnedProgressLabel.text = String(format: "%.1f", learnedProgress * 100)
        toLearnProgressLabel.text = String(format: "%.1f", toLearnProgress * 100)

        // Update progress bar
        progressView.setProgress(CGFloat(learnedProgress))
        progressView.layoutIfNeeded()

        // Update colors depending on progress state
        learnedProgressLabel.textColor =
            learnedProgress > 0
            ? AppColors.wildgreen
            : AppColors.wildgreen.withAlphaComponent(0.5)

        toLearnProgressLabel.textColor =
            toLearnProgress < 1
            ? AppColors.brightyellow
            : AppColors.brightyellow.withAlphaComponent(0.5)

        percentLearnedLabel.textColor =
            learnedProgress > 0
            ? AppColors.wildgreen.withAlphaComponent(0.8)
            : AppColors.wildgreen.withAlphaComponent(0.5)

        percentToLearnLabel.textColor =
            toLearnProgress < 1
            ? AppColors.brightyellow.withAlphaComponent(0.8)
            : AppColors.brightyellow.withAlphaComponent(0.5)

        dashLabel.textColor =
            learnedProgress > 0
            ? AppColors.lightGrey
            : AppColors.lightGrey.withAlphaComponent(0.5)

        // World row uses a distinct color
        if name == "World" {
            progressView.setFillColor(AppColors.nasauurple.withAlphaComponent(0.8))
        } else {
            progressView.setFillColor(AppColors.darkblue.withAlphaComponent(0.8))
        }
    }
}

// MARK: - Rounded Font Helper

extension UIFont {

    /// Returns a rounded system font
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight = .medium) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        let descriptor = base.fontDescriptor.withDesign(.rounded)
        return UIFont(descriptor: descriptor ?? base.fontDescriptor, size: size)
    }
}
