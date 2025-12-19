//
//  TestProgressView.swift
//  AtlasMaster
//
//  Created by Dmitri  on 18.12.25.
//

import UIKit

final class TestProgressView: UIView {

    // MARK: - UI

    private let outerTrack = UIView()
    private let outerFill  = UIView()

    private let innerTrack = UIView()
    private let innerFill  = UIView()

    private var outerFillWidth: NSLayoutConstraint!
    private var innerFillWidth: NSLayoutConstraint!

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        layer.cornerRadius = 20
        layer.borderWidth = 3
        layer.borderColor = UIColor.systemGray6.cgColor
        clipsToBounds = true
        
        //translatesAutoresizingMaskIntoConstraints = false

        outerTrack.translatesAutoresizingMaskIntoConstraints = false
        outerFill.translatesAutoresizingMaskIntoConstraints = false
        innerTrack.translatesAutoresizingMaskIntoConstraints = false
        innerFill.translatesAutoresizingMaskIntoConstraints = false

        // Визуальные стили (поставь свои AppColors)
        outerTrack.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.2) // Left track
        //backgroundColor  = AppColors.greyblue.withAlphaComponent(0.35) // Finished fill (контейнер)

        innerTrack.backgroundColor = .wildGreen.withAlphaComponent(0.85)  // passed track
        innerFill.backgroundColor  = .fuchsiaBlush.withAlphaComponent(0.95) // fa fill

        outerTrack.layer.cornerRadius = 10
        outerFill.layer.cornerRadius = 10
        innerTrack.layer.cornerRadius = 10
        innerFill.layer.cornerRadius = 10

        outerTrack.clipsToBounds = true
        outerFill.clipsToBounds = true // 🔥 важно: внутренний прогресс обрезается по Finished

        addSubview(outerTrack)
        outerTrack.addSubview(outerFill)

        outerFill.addSubview(innerTrack)
        innerTrack.addSubview(innerFill)

        // outerTrack
        NSLayoutConstraint.activate([
            outerTrack.topAnchor.constraint(equalTo: topAnchor),
            outerTrack.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerTrack.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerTrack.bottomAnchor.constraint(equalTo: bottomAnchor),
            //outerTrack.heightAnchor.constraint(equalToConstant: 20)
        ])

        // outerFill (Finished)
        outerFillWidth = outerFill.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            outerFill.topAnchor.constraint(equalTo: outerTrack.topAnchor),
            outerFill.leadingAnchor.constraint(equalTo: outerTrack.leadingAnchor),
            outerFill.bottomAnchor.constraint(equalTo: outerTrack.bottomAnchor),
            outerFillWidth
        ])

        // innerTrack (Failed) — внутри finished-части на всю ширину finished
        NSLayoutConstraint.activate([
            innerTrack.topAnchor.constraint(equalTo: outerFill.topAnchor),
            innerTrack.leadingAnchor.constraint(equalTo: outerFill.leadingAnchor),
            innerTrack.trailingAnchor.constraint(equalTo: outerFill.trailingAnchor),
            innerTrack.bottomAnchor.constraint(equalTo: outerFill.bottomAnchor),
        ])

        // innerFill (Passed)
        innerFillWidth = innerFill.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            innerFill.topAnchor.constraint(equalTo: innerTrack.topAnchor),
            innerFill.leadingAnchor.constraint(equalTo: innerTrack.leadingAnchor),
            innerFill.bottomAnchor.constraint(equalTo: innerTrack.bottomAnchor),
            innerFillWidth
        ])
    }

    // MARK: - Public API

    /// total = total countries shown in this continent (or total in region)
    func setProgress(total: Int, passed: Int, failed: Int, animated: Bool = true) {
        let finished = passed + failed

        let finishedRatio = total > 0 ? CGFloat(finished) / CGFloat(total) : 0
        let passedRatioWithinFinished = finished > 0 ? CGFloat(passed) / CGFloat(finished) : 0

        layoutIfNeeded()

        let fullWidth = outerTrack.bounds.width
        let finishedWidth = fullWidth * finishedRatio
        //let passedWidth = finishedWidth * passedRatioWithinFinished
        let failedWidth = finishedWidth * (1 - passedRatioWithinFinished)

        outerFillWidth.constant = max(0, finishedWidth)   // finished
        innerFillWidth.constant = max(0, failedWidth)     // passed внутри finished

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
    
    func setFillColor(_ passedColor: UIColor, failedColor: UIColor, left: UIColor) {
        outerTrack.backgroundColor = left
        innerTrack.backgroundColor = passedColor   // track = failed
        innerFill.backgroundColor  = failedColor   // fill  = passed
    }
}
