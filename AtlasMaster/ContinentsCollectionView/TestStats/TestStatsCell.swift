//
//  StatsCell.swift
//  AtlasMaster
//
//  Created by Dmitri on 12.12.25.
//
//  Description:
//  UICollectionView cell that displays testing statistics for a continent or world.
//  Shows a multi-layer progress bar (finished / passed / failed / untested)
//  along with percentage labels and status icons.
//

import UIKit

// MARK: - Test Statistics Cell

final class TestStatsCell: UICollectionViewCell {

    // MARK: - Reuse Identifier

    static let reusedId = "TestStatsCell"

    // MARK: - Progress View

    /// Custom progress view displaying finished, passed and failed progress
    let progressView = TestProgressView()

    // MARK: - Percentage Labels

    /// Passed percentage value
    private let passedProgressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .systemYellow
        return lbl
    }()

    /// Failed percentage value
    private let failedProgressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .systemYellow
        return lbl
    }()

    /// Untested percentage value
    private let untestedProgressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .systemGreen
        return lbl
    }()

    // MARK: - Percent Sign Labels

    private let passedPercentLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "%"
        lbl.font = .rounded(ofSize: 15, weight: .semibold)
        lbl.textAlignment = .left
        return lbl
    }()

    private let failedPercentLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "%"
        lbl.font = .rounded(ofSize: 15, weight: .semibold)
        lbl.textAlignment = .left
        return lbl
    }()

    private let untestedPercentLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "%"
        lbl.font = .rounded(ofSize: 15, weight: .semibold)
        lbl.textAlignment = .left
        return lbl
    }()

    // MARK: - Status Icons

    /// Passed icon
    private var passedIcon: UIImageView = {
        let img = UIImage(systemName: "checkmark.circle.fill")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColors.wildgreen
        return imgView
    }()

    /// Failed icon
    private var failedIcon: UIImageView = {
        let img = UIImage(systemName: "xmark.circle.fill")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColors.carolinareaper
        return imgView
    }()

    /// Untested icon
    private var untestedIcon: UIImageView = {
        let img = UIImage(systemName: "circle")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColors.greyblue
        return imgView
    }()

    // MARK: - Stack Views

    /// Stack for failed section
    private let hStackfailed: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Stack for passed section
    private let hStackPassed: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Stack for untested section
    private let hStackUntested: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    /// Stack containing failed + passed blocks (equal width)
    private let hStackProgress: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()

    /// Root horizontal stack
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        // MARK: Progress View Layout

        addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false

        let h: CGFloat = 0 * scaleFactor
        let w: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: w),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -w),
            progressView.topAnchor.constraint(equalTo: topAnchor, constant: h),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -h)
        ])

        // MARK: Stack Assembly

        hStackfailed.addArrangedSubview(failedIcon)
        hStackfailed.addArrangedSubview(failedProgressLabel)
        hStackfailed.addArrangedSubview(failedPercentLabel)

        hStackPassed.addArrangedSubview(passedIcon)
        hStackPassed.addArrangedSubview(passedProgressLabel)
        hStackPassed.addArrangedSubview(passedPercentLabel)

        hStackUntested.addArrangedSubview(untestedIcon)
        hStackUntested.addArrangedSubview(untestedProgressLabel)
        hStackUntested.addArrangedSubview(untestedPercentLabel)

        NSLayoutConstraint.activate([
            passedIcon.widthAnchor.constraint(equalToConstant: 16),
            passedIcon.heightAnchor.constraint(equalToConstant: 16),
            failedIcon.widthAnchor.constraint(equalToConstant: 16),
            failedIcon.heightAnchor.constraint(equalToConstant: 16),
            untestedIcon.widthAnchor.constraint(equalToConstant: 16),
            untestedIcon.heightAnchor.constraint(equalToConstant: 16)
        ])

        // Prevent label compression
        failedProgressLabel.setContentHuggingPriority(.required, for: .horizontal)
        failedProgressLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        passedProgressLabel.setContentHuggingPriority(.required, for: .horizontal)
        passedProgressLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        untestedProgressLabel.setContentHuggingPriority(.required, for: .horizontal)
        untestedProgressLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        hStackProgress.addArrangedSubview(hStackfailed)
        hStackProgress.addArrangedSubview(hStackPassed)

        hStack.addArrangedSubview(hStackProgress)
        hStack.addArrangedSubview(hStackUntested)

        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false

        let heightConst: CGFloat = 10 * scaleFactor
        let widthConst: CGFloat = 20 * scaleFactor
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: widthConst),
            hStack.trailingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: -widthConst),
            hStack.topAnchor.constraint(equalTo: progressView.topAnchor, constant: heightConst),
            hStack.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -heightConst)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configures cell with test statistics
    func configure(with stats: ContinentTestStats) {

        let passedRatio = stats.passedRatio
        let failedRatio = stats.failedRatio
        let passed = stats.passed
        let failed = stats.failed
        let total = stats.total
        let untested = stats.untested
        let untestedRatio = total > 0 ? Double(untested) / Double(total) : 0

        progressView.setProgress(total: total, passed: passed, failed: failed)

        passedProgressLabel.text = String(format: "%.1f", passedRatio * 100)
        failedProgressLabel.text = String(format: "%.1f", failedRatio * 100)
        untestedProgressLabel.text = String(format: "%.1f", untestedRatio * 100)

        progressView.layoutIfNeeded()

        passedProgressLabel.textColor = passedRatio > 0 ? .deepGreen : .deepGreen.withAlphaComponent(0.5)
        passedPercentLabel.textColor = passedRatio > 0 ? .deepGreen.withAlphaComponent(0.8) : .deepGreen.withAlphaComponent(0.5)
        passedIcon.tintColor = passedRatio > 0 ? .deepGreen : .deepGreen.withAlphaComponent(0.5)

        failedProgressLabel.textColor = passedRatio > 0 ? .coolRed : .coolRed.withAlphaComponent(0.5)
        failedPercentLabel.textColor = passedRatio > 0 ? .coolRed.withAlphaComponent(0.8) : .coolRed.withAlphaComponent(0.5)
        failedIcon.tintColor = passedRatio > 0 ? .coolRed : .coolRed.withAlphaComponent(0.5)

        untestedProgressLabel.textColor = passedRatio > 0 ? .greyBlue : .greyBlue.withAlphaComponent(0.5)
        untestedPercentLabel.textColor = passedRatio > 0 ? .greyBlue : .greyBlue.withAlphaComponent(0.5)
        untestedIcon.tintColor = passedRatio > 0 ? .greyBlue : .greyBlue.withAlphaComponent(0.5)
    }
}
