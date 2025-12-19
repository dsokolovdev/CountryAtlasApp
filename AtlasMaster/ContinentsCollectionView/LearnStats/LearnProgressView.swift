//
//  RoundedProgressView.swift
//  AtlasMaster
//
//  Created by Dmitri on 13.12.25.
//
//  Description:
//  Reusable rounded progress view.
//  Displays progress as a filled bar inside a rounded container.
//  Used for learning and statistics progress visualization.
//

import UIKit

// MARK: - Learn Progress View

final class LearnProgressView: UIView {

    // MARK: - Subviews

    /// Background track view (empty progress)
    private let trackView = UIView()

    /// Filled progress view
    private let fillView = UIView()

    // MARK: - State

    /// Current progress value (0.0 ... 1.0)
    private var progress: CGFloat = 0

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Setup

    /// Configures view appearance and hierarchy
    private func setup() {
        layer.cornerRadius = 20
        layer.borderWidth = 3
        layer.borderColor = UIColor.systemGray6.cgColor
        clipsToBounds = true

        trackView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
        fillView.backgroundColor = AppColors.lightBlue

        addSubview(trackView)
        addSubview(fillView)
    }

    // MARK: - Layout

    /// Updates subviews frames based on current progress
    override func layoutSubviews() {
        super.layoutSubviews()

        trackView.frame = bounds

        let width = bounds.width * progress
        fillView.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: bounds.height
        )
    }

    // MARK: - Public API

    /// Updates progress value (clamped between 0 and 1)
    func setProgress(_ value: CGFloat) {
        progress = max(0, min(1, value))
        setNeedsLayout()
    }

    /// Updates fill color of progress bar
    func setFillColor(_ color: UIColor) {
        fillView.backgroundColor = color
    }
}
