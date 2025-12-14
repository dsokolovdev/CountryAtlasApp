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
        case capital = 0
        case country
        case flag
        case progress
        
        var segment: Int { rawValue }
        
        var title: String {
            switch self {
            case .capital:
                return "Capitals"
            case .country:
                return "Countries"
            case .flag:
                return "Flags"
            case .progress:
                return "Results"
            }
        }
    }
    
    var currentLearningSegment: LearningSegment {
        LearningSegment(rawValue: learningSegment.selectedSegmentIndex) ?? .toLearn
    }
    
    var currentTestingSegment: TestingSegment {
        TestingSegment(rawValue: testingSegment.selectedSegmentIndex) ?? .capital
    }

    var mode: Mode = .learning {
        didSet { updateMode() }
    }
    
    var preferredWidth: CGFloat {
        let count = (mode == .learning) ? 3 : 4
        return CGFloat(count) * 72
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
        sc.selectedSegmentTintColor = AppColors.greyblue.withAlphaComponent(0.1)
        sc.subviews.forEach { $0.backgroundColor = .systemBackground }
        return sc
    }()

    private let testingSegment: UISegmentedControl = {
        let capital = UIImage(systemName: "house.and.flag.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        let country = UIImage(systemName: "globe.europe.africa.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        let flag = UIImage(systemName: "flag.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        let progress = UIImage(systemName: "trophy.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))

        let sc = UISegmentedControl(items: [capital!, country!, flag!, progress!])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .systemGray6
        sc.subviews.forEach { $0.backgroundColor = .systemBackground }
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
        backgroundColor = .systemBackground
        layer.cornerRadius = 28 * scaleFactor

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
        let size: CGFloat = 16 * scaleFactor

        learningSegment.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: UIFont.systemFont(ofSize: size, weight: .semibold)], for: .normal)
        learningSegment.setTitleTextAttributes([.foregroundColor: activeColor, .font: UIFont.systemFont(ofSize: size, weight: .bold)], for: .selected)
    }
    
    private func updateTestingColors() {
        let index = testingSegment.selectedSegmentIndex
        
        let activeColor: UIColor
        switch index {
        case TestingSegment.capital.rawValue:
            activeColor = .systemOrange
        case TestingSegment.country.rawValue:
            activeColor = .systemPurple
        case TestingSegment.flag.rawValue:
            activeColor = .systemIndigo
        case TestingSegment.progress.rawValue:
            activeColor = .systemBlue
        default:
            activeColor = .label
        }
        
        let inactiveColor: UIColor = AppColors.greyblue.withAlphaComponent(0.5)
        let size: CGFloat = 16 * scaleFactor
        
        testingSegment.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: UIFont.systemFont(ofSize: size, weight: .semibold)], for: .normal)
        testingSegment.setTitleTextAttributes([.foregroundColor: activeColor, .font: UIFont.systemFont(ofSize: size, weight: .bold)], for: .selected)
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
