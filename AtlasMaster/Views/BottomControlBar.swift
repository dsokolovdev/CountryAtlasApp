//
//  BottomControlBar.swift
//  AtlasMaster
//
//  Created by Dmitri  on 13.12.25.
//

import UIKit

final class BottomControlBar: UIView {

    enum Mode { case learning, testing }
    
    enum LearningSegment: Int {
        case toLearn = 0
        case learned
        case stats
        
        var segment: Int { rawValue }
        
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
    
    enum TestingSegment: Int {
        case untested = 0
        case failed
        case passed
        case result
        
        var segment: Int { rawValue }
        
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
    
    private enum TestingIconStyle {
        case inactive
        case untested
        case failed
        case passed
        case result
    }

    
    var currentLearningSegment: LearningSegment {
        LearningSegment(rawValue: learningSegment.selectedSegmentIndex) ?? .toLearn
    }
    
    var currentTestingSegment: TestingSegment {
        TestingSegment(rawValue: testingSegment.selectedSegmentIndex) ?? .untested
    }

    var mode: Mode = .learning {
        didSet { updateMode() }
    }
    
    var preferredWidth: CGFloat {
        let count = (mode == .learning) ? 3 : 4
        return CGFloat(count) * 73
    }
    
    var onLearningChanged: ((LearningSegment) -> Void)?
    var onTestingChanged: ((TestingSegment) -> Void)?
    

    // ✅ Должны быть инициализированы ДО super.init
    private let learningSegment: UISegmentedControl = {
        let toLearn = UIImage(systemName: "lightbulb.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        let learned = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        let progress = UIImage(systemName: "percent", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))

        let sc = UISegmentedControl(items: [toLearn!, learned!, progress!])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = AppColors.greyblue.withAlphaComponent(0.15)
        sc.subviews.forEach { $0.backgroundColor = .systemBackground.withAlphaComponent(0.7) }
        return sc
    }()

    private let testingSegment: UISegmentedControl = {
        let inactiveConfig = UIImage.SymbolConfiguration(paletteColors: [.systemGray, .lightGray])
        let testActiveConfig = UIImage.SymbolConfiguration(paletteColors: [AppColors.deepgreen, AppColors.greyblue])
        let failActiveConfig = UIImage.SymbolConfiguration(paletteColors: [AppColors.coolred, AppColors.greyblue])
        let passActiveConfig = UIImage.SymbolConfiguration(paletteColors: [AppColors.wildgreen, AppColors.greyblue])
        let resultActiveConfig = UIImage.SymbolConfiguration(paletteColors: [AppColors.marine, AppColors.greyblue])
        
        let test = UIImage(systemName: "checklist", withConfiguration: testActiveConfig)
        let fail = UIImage(systemName: "text.badge.xmark", withConfiguration: failActiveConfig)
        let pass = UIImage(systemName: "text.badge.checkmark", withConfiguration: passActiveConfig)
        let result = UIImage(systemName: "chart.bar.horizontal.page", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
       // let progress = UIImage(systemName: "trophy.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        
        let sc = UISegmentedControl(items: [test!, fail!, pass!, result!])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = AppColors.greyblue.withAlphaComponent(0.15)
        sc.subviews.forEach { $0.backgroundColor = .systemBackground.withAlphaComponent(0.7) }
        return sc
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()              // ✅ ты этого не делал
        updateMode()
        
        learningSegment.addTarget(self, action: #selector(learningModeChanged), for: .valueChanged)
        testingSegment.addTarget(self, action: #selector(testingModeChanged), for: .valueChanged)
        
        updateSegmentAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        updateMode()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground.withAlphaComponent(0.2)
        layer.cornerRadius = 29 * scaleFactor

        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
        layer.shadowRadius = 4
        layer.masksToBounds = false

        // ✅ СНАЧАЛА addSubview, ПОТОМ constraints
        addSubview(learningSegment)
        addSubview(testingSegment)
        
        let c: CGFloat = 2
        NSLayoutConstraint.activate([
            learningSegment.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            learningSegment.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -c),
            learningSegment.topAnchor.constraint(equalTo: topAnchor, constant: c),
            learningSegment.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -c),

            testingSegment.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            testingSegment.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -c),
            testingSegment.topAnchor.constraint(equalTo: topAnchor, constant: c),
            testingSegment.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -c),
        ])

        // ✅ вот теперь приоритеты реально начнут работать
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        learningSegment.setContentHuggingPriority(.defaultLow, for: .horizontal)
        learningSegment.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        testingSegment.setContentHuggingPriority(.defaultLow, for: .horizontal)
        testingSegment.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func updateMode() {
        learningSegment.isHidden = (mode != .learning)
        testingSegment.isHidden = (mode != .testing)
        
        updateSegmentAppearance()
    }
    
    //MARK: - Update Segments Colors
    private func updateSegmentAppearance() {
        switch mode {
        case .learning:
            updateLearningColors()
        case .testing:
            updateTestingColors()
        }
    }
    
    private func updateLearningColors() {
        let index = learningSegment.selectedSegmentIndex

        let activeColor: UIColor
        switch index {
        case LearningSegment.toLearn.rawValue:
            activeColor = AppColors.brightyellow
        case LearningSegment.learned.rawValue:
            activeColor = AppColors.wildgreen
        case LearningSegment.stats.rawValue:
            activeColor = AppColors.frightnight
        default:
            activeColor = .label
        }

        let inactiveColor = AppColors.greyblue.withAlphaComponent(0.5)
        let size: CGFloat = 19 * scaleFactor

        learningSegment.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: UIFont.systemFont(ofSize: size, weight: .semibold)], for: .normal)
        learningSegment.setTitleTextAttributes([.foregroundColor: activeColor, .font: UIFont.systemFont(ofSize: size, weight: .bold)], for: .selected)
    }
    
    private func testingIcon(for style: TestingIconStyle, systemName: String) -> UIImage {
        let size: CGFloat = 19 * scaleFactor
        let config: UIImage.SymbolConfiguration
        let activeConfig = UIImage.SymbolConfiguration(pointSize: size, weight: .semibold)
        let inactiveConfig = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)
        //let finalConfig = config.applying(largeConfig)

        switch style {
        case .inactive:
            config = UIImage.SymbolConfiguration(paletteColors: [.systemGray, .lightGray]).applying(inactiveConfig)
        case .untested:
            config = UIImage.SymbolConfiguration(paletteColors: [AppColors.darkblue, AppColors.greyblue]).applying(activeConfig)
        case .failed:
            config = UIImage.SymbolConfiguration(paletteColors: [AppColors.coolred, AppColors.greyblue]).applying(activeConfig)
        case .passed:
            config = UIImage.SymbolConfiguration(paletteColors: [AppColors.wildgreen, AppColors.greyblue]).applying(activeConfig)
        case .result:
            config = UIImage.SymbolConfiguration(paletteColors: [AppColors.marine, AppColors.greyblue]).applying(activeConfig)
        }
        return UIImage(systemName: systemName, withConfiguration: config)!
    }
    
    private func updateTestingColors() {
        let index = testingSegment.selectedSegmentIndex
        
        testingSegment.setImage(testingIcon(for: index == TestingSegment.untested.rawValue ? .untested : .inactive, systemName: "checklist"), forSegmentAt: TestingSegment.untested.rawValue)
        testingSegment.setImage(testingIcon(for: index == TestingSegment.failed.rawValue ? .failed : .inactive, systemName: "text.badge.xmark"), forSegmentAt: TestingSegment.failed.rawValue)
        testingSegment.setImage(testingIcon(for: index == TestingSegment.passed.rawValue ? .passed : .inactive, systemName: "text.badge.checkmark"), forSegmentAt: TestingSegment.passed.rawValue)
        testingSegment.setImage(testingIcon(for: index == TestingSegment.result.rawValue ? .result : .inactive, systemName: "chart.bar.horizontal.page"), forSegmentAt: TestingSegment.result.rawValue)
    }
    
    @objc private func learningModeChanged(_ sender: UISegmentedControl) {
        guard let segment = LearningSegment(rawValue: sender.selectedSegmentIndex) else { return }
        updateSegmentAppearance()
        onLearningChanged?(segment)
    }
    
    @objc private func testingModeChanged(_ sender: UISegmentedControl) {
        guard let segment = TestingSegment(rawValue: sender.selectedSegmentIndex) else { return }
        updateSegmentAppearance()
        onTestingChanged?(segment)
    }
}
