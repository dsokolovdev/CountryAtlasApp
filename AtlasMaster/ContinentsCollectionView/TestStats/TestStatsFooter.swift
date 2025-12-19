//
//  TestStatsFooter.swift
//  AtlasMaster
//
//  Created by Dmitri  on 18.12.25.
//


import UIKit

final class TestStatsFooter: UICollectionReusableView {
    static let reusedId = "TestStatsFooter"
    
    private let passedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font =  .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let failedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font =  .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let notTestedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font =  .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let passedLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Passed:"
        lbl.font =  .rounded(ofSize: 14)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let failedLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Failed:"
        lbl.font =  .rounded(ofSize: 14)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let notTestedLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Untested:"
        lbl.font =  .rounded(ofSize: 14)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let hStackPassed: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private let hStackFailed: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private let hStackUntested: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private let hStackProgress: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillProportionally
        stack.alignment = .center
        return stack
    }()
    
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        hStackFailed.addArrangedSubview(failedLabelText)
        hStackFailed.addArrangedSubview(failedLabel)
        
        hStackPassed.addArrangedSubview(passedLabelText)
        hStackPassed.addArrangedSubview(passedLabel)
        
        hStackUntested.addArrangedSubview(notTestedLabelText)
        hStackUntested.addArrangedSubview(notTestedLabel)
        
        hStackProgress.addArrangedSubview(hStackFailed)
        hStackProgress.addArrangedSubview(hStackPassed)
        
        //Horizontal Stack
        hStack.addArrangedSubview(hStackProgress)
        hStack.addArrangedSubview(hStackUntested)
        //hStack.addArrangedSubview(hStackLearned)
        //hStack.addArrangedSubview(hStackToLearn)
        
        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        let c: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -c),
            hStack.topAnchor.constraint(equalTo: topAnchor)
            //hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        passedLabelText.setContentHuggingPriority(.required, for: .horizontal)
        failedLabel.setContentHuggingPriority(.required, for: .horizontal)
        failedLabelText.setContentHuggingPriority(.required, for:  .horizontal)
        notTestedLabel.setContentHuggingPriority(.required, for: .horizontal)
        //toLearnLabelText.setContentHuggingPriority(.required, for: .horizontal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
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
