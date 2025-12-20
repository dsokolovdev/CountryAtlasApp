//
//  TestProgressView.swift
//
//  Created by Dmitri on 18.12.25.
//
//  Description:
//  Custom progress view for Testing statistics.
//  Displays a three-state progress:
//  - Finished (passed + failed)
//  - Passed (inside finished)
//  - Failed (inside finished)
//  Remaining empty area represents Untested items.
//

import UIKit

// MARK: - Test Progress View

final class TestProgressView: UIView {
    
    // MARK: - UI Elements
    
    /// Outer track representing total scope (untested + finished)
    private let outerTrack = UIView()
    
    /// Filled part representing finished (passed + failed)
    private let outerFill  = UIView()
    
    /// Track inside finished representing failed + passed
    private let innerTrack = UIView()
    
    /// Filled part inside finished representing passed
    private let innerFill  = UIView()
    
    // MARK: - Constraints
    
    /// Width constraint for finished progress
    private var outerFillWidth: NSLayoutConstraint!
    
    /// Width constraint for passed / failed progress inside finished
    private var innerFillWidth: NSLayoutConstraint!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - View Setup
    
    /// Configures view hierarchy, layout and default appearance
    private func setup() {
        layer.cornerRadius = 20.scaled
        layer.borderWidth = 3.scaled
        layer.borderColor = UIColor.systemGray6.cgColor
        clipsToBounds = true
        
        outerTrack.translatesAutoresizingMaskIntoConstraints = false
        outerFill.translatesAutoresizingMaskIntoConstraints = false
        innerTrack.translatesAutoresizingMaskIntoConstraints = false
        innerFill.translatesAutoresizingMaskIntoConstraints = false
        
        // Visual styles
        outerTrack.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.2) // Untested area
        innerTrack.backgroundColor = .wildGreen.withAlphaComponent(0.85)          // Failed area
        innerFill.backgroundColor  = .fuchsiaBlush.withAlphaComponent(0.95)       // Passed area
        
        outerTrack.layer.cornerRadius = 10.scaled
        outerFill.layer.cornerRadius = 10.scaled
        innerTrack.layer.cornerRadius = 10.scaled
        innerFill.layer.cornerRadius = 10.scaled
        
        outerTrack.clipsToBounds = true
        outerFill.clipsToBounds = true   // Ensures inner progress is clipped to finished width
        
        // View hierarchy
        addSubview(outerTrack)
        outerTrack.addSubview(outerFill)
        outerFill.addSubview(innerTrack)
        innerTrack.addSubview(innerFill)
        
        // MARK: Layout Constraints
        
        // Outer track fills entire view
        NSLayoutConstraint.activate([
            outerTrack.topAnchor.constraint(equalTo: topAnchor),
            outerTrack.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerTrack.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerTrack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Finished progress (outerFill)
        outerFillWidth = outerFill.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            outerFill.topAnchor.constraint(equalTo: outerTrack.topAnchor),
            outerFill.leadingAnchor.constraint(equalTo: outerTrack.leadingAnchor),
            outerFill.bottomAnchor.constraint(equalTo: outerTrack.bottomAnchor),
            outerFillWidth
        ])
        
        // Failed + passed track inside finished
        NSLayoutConstraint.activate([
            innerTrack.topAnchor.constraint(equalTo: outerFill.topAnchor),
            innerTrack.leadingAnchor.constraint(equalTo: outerFill.leadingAnchor),
            innerTrack.trailingAnchor.constraint(equalTo: outerFill.trailingAnchor),
            innerTrack.bottomAnchor.constraint(equalTo: outerFill.bottomAnchor)
        ])
        
        // Passed progress inside finished
        innerFillWidth = innerFill.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            innerFill.topAnchor.constraint(equalTo: innerTrack.topAnchor),
            innerFill.leadingAnchor.constraint(equalTo: innerTrack.leadingAnchor),
            innerFill.bottomAnchor.constraint(equalTo: innerTrack.bottomAnchor),
            innerFillWidth
        ])
    }
    
    // MARK: - Progress Update
    
    /// Updates progress values
    /// - Parameters:
    ///   - total: Total number of items
    ///   - passed: Number of passed items
    ///   - failed: Number of failed items
    ///   - animated: Whether to animate progress change
    func setProgress(total: Int, passed: Int, failed: Int, animated: Bool = true) {
        let finished = passed + failed
        
        let finishedRatio = total > 0 ? CGFloat(finished) / CGFloat(total) : 0
        let passedRatioWithinFinished = finished > 0 ? CGFloat(passed) / CGFloat(finished) : 0
        
        layoutIfNeeded()
        
        let fullWidth = outerTrack.bounds.width
        let finishedWidth = fullWidth * finishedRatio
        let failedWidth = finishedWidth * (1 - passedRatioWithinFinished)
        
        outerFillWidth.constant = max(0, finishedWidth)   // Finished
        innerFillWidth.constant = max(0, failedWidth)     // Passed inside finished
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut, .allowUserInteraction]) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
    
    // MARK: - Appearance
    
    /// Sets custom colors for progress segments
    /// - Parameters:
    ///   - passedColor: Color for passed segment
    ///   - failedColor: Color for failed segment
    ///   - left: Color for untested segment
    func setFillColor(_ passedColor: UIColor, failedColor: UIColor, left: UIColor) {
        outerTrack.backgroundColor = left
        innerTrack.backgroundColor = passedColor
        innerFill.backgroundColor  = failedColor
    }
    
}
