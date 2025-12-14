//
//  RoundedProgressView.swift
//  AtlasMaster
//
//  Created by Dmitri  on 13.12.25.
//
import UIKit

final class RoundedProgressView: UIView {

    private let trackView = UIView()
    private let fillView = UIView()

    private var progress: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

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

    func setProgress(_ value: CGFloat) {
        progress = max(0, min(1, value))
        setNeedsLayout()
    }

    func setFillColor(_ color: UIColor) {
        fillView.backgroundColor = color
    }
}
