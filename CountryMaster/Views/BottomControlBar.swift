//
//  BottomControlBar.swift
//
//  Created by Dmitri  on 13.12.25.
//
//  Description:
//  Reusable bottom control bar that switches between
//  Learning and Testing modes.
//  Provides segmented controls for filtering content
//  and navigating progress/statistics.
//

import UIKit

// MARK: - BottomControlBar
final class BottomControlBar: UIVisualEffectView {
    
    // MARK: - Mode
    /// Defines which segmented control is visible.
    enum Mode { case learning, testing }
    
    // MARK: - Learning Segments
    /// Segments available in learning mode.
    enum LearningSegment: Int {
        case toLearn = 0
        case learned
        case stats
        
        /// Raw segment index.
        var segment: Int { rawValue }
        
        /// Title used by parent controller.
        var title: String {
            switch self {
            case .toLearn:
                return "To learn"
            case .learned:
                return "Learned"
            case .stats:
                return "Progress"
            }
        }
    }
    
    // MARK: - Testing Segments
    /// Segments available in testing mode.
    enum TestingSegment: Int {
        case untested = 0
        case failed
        case passed
        case result
        
        /// Raw segment index.
        var segment: Int { rawValue }
        
        /// Title used by parent controller.
        var title: String {
            switch self {
            case .untested:
                return "Test"
            case .failed:
                return "Review"
            case .passed:
                return "Passed"
            case .result:
                return "Results"
            }
        }
    }
    
    // MARK: - Testing Icon Style
    /// Internal helper enum for testing segment icon coloring.
    private enum TestingIconStyle {
        case inactive
        case untested
        case failed
        case passed
        case result
    }
    
    // MARK: - Current Segments
    /// Currently selected learning segment.
    var currentLearningSegment: LearningSegment {
        LearningSegment(rawValue: learningSegment.selectedSegmentIndex) ?? .toLearn
    }
    
    /// Currently selected testing segment.
    var currentTestingSegment: TestingSegment {
        TestingSegment(rawValue: testingSegment.selectedSegmentIndex) ?? .untested
    }
    
    // MARK: - State
    /// Active mode of the control bar.
    var mode: Mode = .learning {
        didSet { updateMode() }
    }
    
    /// Preferred width depending on number of segments.
    var preferredWidth: CGFloat {
        let count = (mode == .learning) ? 3 : 4
        return CGFloat(count) * 73.scaled
    }
    
    // MARK: - Callbacks
    /// Fired when learning segment changes.
    var onLearningChanged: ((LearningSegment) -> Void)?
    
    /// Fired when testing segment changes.
    var onTestingChanged: ((TestingSegment) -> Void)?
    
    
    // MARK: - Segmented Controls
    /// Segmented control for learning mode.
    private let learningSegment: UISegmentedControl = {
        let toLearn = UIImage(systemName: "lightbulb.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        let learned = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        let progress = UIImage(systemName: "percent", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        
        let sc = UISegmentedControl(items: [toLearn!, learned!, progress!])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .greyBlue.withAlphaComponent(0.15)
        sc.subviews.forEach { $0.backgroundColor = .systemBackground.withAlphaComponent(0.1) }
        return sc
    }()
    
    /// Segmented control for testing mode.
    private let testingSegment: UISegmentedControl = {
        let testActiveConfig = UIImage.SymbolConfiguration(paletteColors: [.deepGreen, .greyBlue])
        let failActiveConfig = UIImage.SymbolConfiguration(paletteColors: [.coolRed, .greyBlue])
        let passActiveConfig = UIImage.SymbolConfiguration(paletteColors: [.wildGreen, .greyBlue])
        
        let test = UIImage(systemName: "checklist", withConfiguration: testActiveConfig)
        let fail = UIImage(systemName: "text.badge.xmark", withConfiguration: failActiveConfig)
        let pass = UIImage(systemName: "text.badge.checkmark", withConfiguration: passActiveConfig)
        let result = UIImage(systemName: "chart.bar.horizontal.page", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        
        let sc = UISegmentedControl(items: [test!, fail!, pass!, result!])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .greyBlue.withAlphaComponent(0.15)
        sc.subviews.forEach { $0.backgroundColor = .systemBackground.withAlphaComponent(0.1) }
        return sc
    }()
    
    // MARK: - Init
    init() {
        super.init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        setup()
        updateMode()
        
        learningSegment.addTarget(self, action: #selector(learningModeChanged), for: .valueChanged)
        testingSegment.addTarget(self, action: #selector(testingModeChanged), for: .valueChanged)
        
        updateSegmentAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        effect = UIBlurEffect(style: .systemUltraThinMaterial)
        setup()
        updateMode()
    }
    
    // MARK: - Setup
    /// Performs initial view setup and constraints.
    private func setup() {
        if #available(iOS 26.0, *) {
            let glassEffect = UIGlassEffect(style: .clear)
            let visualEffectView = UIVisualEffectView(effect: glassEffect)
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            contentView.insertSubview(visualEffectView, at: 0)
            
            NSLayoutConstraint.activate([
                visualEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                visualEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                visualEffectView.topAnchor.constraint(equalTo: contentView.topAnchor),
                visualEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        } else {
            // Fallback on earlier versions
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 29.scaled
        layer.masksToBounds = true
        
        contentView.layer.cornerRadius = 29.scaled
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(learningSegment)
        contentView.addSubview(testingSegment)
        
        let c: CGFloat = 2.scaled
        NSLayoutConstraint.activate([
            learningSegment.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            learningSegment.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -c),
            learningSegment.topAnchor.constraint(equalTo: topAnchor, constant: c),
            learningSegment.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -c),
            
            testingSegment.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            testingSegment.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -c),
            testingSegment.topAnchor.constraint(equalTo: topAnchor, constant: c),
            testingSegment.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -c)
        ])
        
        // Layout priorities
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        learningSegment.setContentHuggingPriority(.defaultLow, for: .horizontal)
        learningSegment.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        testingSegment.setContentHuggingPriority(.defaultLow, for: .horizontal)
        testingSegment.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    // MARK: - Mode Switching
    /// Shows correct segmented control based on active mode.
    private func updateMode() {
        learningSegment.isHidden = (mode != .learning)
        testingSegment.isHidden = (mode != .testing)
        
        updateSegmentAppearance()
    }
    
    // MARK: - Appearance Updates
    /// Updates segment appearance depending on current mode.
    private func updateSegmentAppearance() {
        switch mode {
        case .learning:
            updateLearningColors()
        case .testing:
            updateTestingColors()
        }
    }
    
    /// Updates colors for learning segments.
    private func updateLearningColors() {
        let index = learningSegment.selectedSegmentIndex
        
        let activeColor: UIColor
        switch index {
        case LearningSegment.toLearn.rawValue:
            activeColor = .brightYellow
        case LearningSegment.learned.rawValue:
            activeColor = .wildGreen
        case LearningSegment.stats.rawValue:
            activeColor = .frightNight
        default:
            activeColor = .label
        }
        
        let inactiveColor: UIColor = .greyBlue.withAlphaComponent(0.5)
        let size: CGFloat = 19.scaled
        
        learningSegment.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: UIFont.systemFont(ofSize: size, weight: .semibold)], for: .normal)
        learningSegment.setTitleTextAttributes([.foregroundColor: activeColor, .font: UIFont.systemFont(ofSize: size, weight: .bold)], for: .selected)
    }
    
    /// Builds an icon image for testing segments.
    private func testingIcon(for style: TestingIconStyle, systemName: String) -> UIImage {
        let size: CGFloat = 19.scaled
        let activeConfig = UIImage.SymbolConfiguration(pointSize: size, weight: .semibold)
        let inactiveConfig = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)
        let config: UIImage.SymbolConfiguration
        
        switch style {
        case .inactive:
            config = UIImage.SymbolConfiguration(paletteColors: [.systemGray, .lightGray]).applying(inactiveConfig)
        case .untested:
            config = UIImage.SymbolConfiguration(paletteColors: [.darkBlue, .greyBlue]).applying(activeConfig)
        case .failed:
            config = UIImage.SymbolConfiguration(paletteColors: [.coolRed, .greyBlue]).applying(activeConfig)
        case .passed:
            config = UIImage.SymbolConfiguration(paletteColors: [.wildGreen, .greyBlue]).applying(activeConfig)
        case .result:
            config = UIImage.SymbolConfiguration(paletteColors: [.merchantMarine, .greyBlue]).applying(activeConfig)
        }
        return UIImage(systemName: systemName, withConfiguration: config)!
    }
    
    /// Updates icons for testing segments.
    private func updateTestingColors() {
        let index = testingSegment.selectedSegmentIndex
        
        testingSegment.setImage(testingIcon(for: index == TestingSegment.untested.rawValue ? .untested : .inactive, systemName: "checklist"), forSegmentAt: TestingSegment.untested.rawValue)
        testingSegment.setImage(testingIcon(for: index == TestingSegment.failed.rawValue ? .failed : .inactive, systemName: "text.badge.xmark"), forSegmentAt: TestingSegment.failed.rawValue)
        testingSegment.setImage(testingIcon(for: index == TestingSegment.passed.rawValue ? .passed : .inactive, systemName: "text.badge.checkmark"), forSegmentAt: TestingSegment.passed.rawValue)
        testingSegment.setImage(testingIcon(for: index == TestingSegment.result.rawValue ? .result : .inactive, systemName: "chart.bar.horizontal.page"), forSegmentAt: TestingSegment.result.rawValue)
    }
    
    // MARK: - Actions
    /// Handles learning segment changes.
    @objc private func learningModeChanged(_ sender: UISegmentedControl) {
        guard let segment = LearningSegment(rawValue: sender.selectedSegmentIndex) else { return }
        updateSegmentAppearance()
        onLearningChanged?(segment)
    }
    
    /// Handles testing segment changes.
    @objc private func testingModeChanged(_ sender: UISegmentedControl) {
        guard let segment = TestingSegment(rawValue: sender.selectedSegmentIndex) else { return }
        updateSegmentAppearance()
        onTestingChanged?(segment)
    }
    
    //MARK: - Reset State
    func resetToFirstSegment() {
        switch mode {
        case .learning:
            learningSegment.selectedSegmentIndex = 0
        case .testing:
            testingSegment.selectedSegmentIndex = 0
        }
        updateSegmentAppearance()
    }
}

