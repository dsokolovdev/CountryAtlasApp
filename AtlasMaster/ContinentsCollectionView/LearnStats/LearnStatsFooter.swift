//
//  StatsFooter.swift
//  AtlasMaster
//
//  Created by Dmitri  on 12.12.25.
//

import UIKit

final class LearnStatsFooter: UICollectionReusableView {
    static let reusedId = "LearnStatsFooter"
    
    private let totalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font =  .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let learnedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font =  .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let toLearnLabel: UILabel = {
        let lbl = UILabel()
        lbl.font =  .rounded(ofSize: 14, weight: .semibold)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let totalLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Total:"
        lbl.font =  .rounded(ofSize: 14)
        lbl.textAlignment = .left
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let learnedLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Learned:"
        lbl.font =  .rounded(ofSize: 14)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let toLearnLabelText: UILabel = {
        let lbl = UILabel()
        lbl.text = "To learn:"
        lbl.font =  .rounded(ofSize: 14)
        lbl.textAlignment = .right
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let hStackTotal: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private let hStackLearned: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private let hStackToLearn: UIStackView = {
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
        
        hStackTotal.addArrangedSubview(totalLabelText)
        hStackTotal.addArrangedSubview(totalLabel)
        
        hStackLearned.addArrangedSubview(learnedLabelText)
        hStackLearned.addArrangedSubview(learnedLabel)
        
        hStackToLearn.addArrangedSubview(toLearnLabelText)
        hStackToLearn.addArrangedSubview(toLearnLabel)
        
        hStackProgress.addArrangedSubview(hStackLearned)
        hStackProgress.addArrangedSubview(hStackToLearn)
        
        //Horizontal Stack
        hStack.addArrangedSubview(hStackTotal)
        hStack.addArrangedSubview(hStackProgress)
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
        
        totalLabelText.setContentHuggingPriority(.required, for: .horizontal)
        learnedLabel.setContentHuggingPriority(.required, for: .horizontal)
        learnedLabelText.setContentHuggingPriority(.required, for:  .horizontal)
        toLearnLabel.setContentHuggingPriority(.required, for: .horizontal)
        //toLearnLabelText.setContentHuggingPriority(.required, for: .horizontal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(continent: ContinentStats) {
        let learned = continent.learned
        let total = continent.total
        let toLearn = continent.toLearn
        
        totalLabel.text = "\(total)"
        learnedLabel.text = "\(learned)"
        toLearnLabel.text = "\(toLearn)"
        
        totalLabel.textColor = learned > 0 ? .secondaryLabel : .tertiaryLabel
        learnedLabel.textColor = learned > 0 ? .secondaryLabel : .tertiaryLabel
        toLearnLabel.textColor = learned > 0 ? .secondaryLabel : .tertiaryLabel
        totalLabelText.textColor = learned > 0 ? .secondaryLabel : .tertiaryLabel
        learnedLabelText.textColor = learned > 0 ? .secondaryLabel : .tertiaryLabel
        toLearnLabelText.textColor = learned > 0 ? .secondaryLabel : .tertiaryLabel
    }
    
}
