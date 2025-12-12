//
//  StatsCell.swift
//  AtlasMaster
//
//  Created by Dmitri  on 12.12.25.
//
import UIKit

final class StatsCell: UICollectionViewCell {
    static let reusedId = "StatsCell"
    
    let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.systemGray6.cgColor
        view .clipsToBounds = true
        //view.progressTintColor = .blue.withAlphaComponent(0.8)
        view.trackTintColor = .systemGray6.withAlphaComponent(0.3)
        return view
    }()
    
    private let learnedProgressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 22, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .systemGreen
        return lbl
    }()
    
    private let toLearnProgressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 22, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .systemYellow
        return lbl
    }()
    
    private let dashLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .regular)
        lbl.textAlignment = .center
        //lbl.textColor = .tertiaryLabel
        lbl.text = "/"
        return lbl
    }()
    
    private let percentLearnedLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "%"
        lbl.font = .rounded(ofSize: 16, weight: .semibold)
        lbl.textAlignment = .left
        //lbl.textColor = .systemGreen.withAlphaComponent(0.6)
        return lbl
    }()
    
    private let percentToLearnLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "%"
        lbl.font = .rounded(ofSize: 16, weight: .semibold)
        lbl.textAlignment = .left
        //lbl.textColor = .systemYellow.withAlphaComponent(0.6)
        return lbl
    }()
    
    private let hStackLearned: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private let hStackToLearn: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private let hStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()

        progressView.progressTintColor = nil
        progressView.setProgress(0, animated: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //ProgressView
        addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        //progressView.layer.cornerRadius = CGRectGetHeight(frame) / 2.4
        
        let h: CGFloat = 1 * scaleFactor
        let w: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: w),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -w),
            progressView.topAnchor.constraint(equalTo: topAnchor, constant: h),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -h)
        ])
        
        //Horizontal Stack
        hStackLearned.addArrangedSubview(learnedProgressLabel)
        hStackLearned.addArrangedSubview(percentLearnedLabel)
        hStackToLearn.addArrangedSubview(toLearnProgressLabel)
        hStackToLearn.addArrangedSubview(percentToLearnLabel)
        
        hStack.addArrangedSubview(hStackLearned)
        hStack.addArrangedSubview(dashLabel)
        hStack.addArrangedSubview(hStackToLearn)
        
        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        let width: CGFloat = 200 * scaleFactor
        let height: CGFloat = 10 * scaleFactor
        NSLayoutConstraint.activate([
            hStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            hStack.topAnchor.constraint(equalTo: progressView.topAnchor, constant: height),
            hStack.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -height),
            hStack.widthAnchor.constraint(equalToConstant: width)
        ])
        
        //learnedProgressLabel.setContentHuggingPriority(.required, for: .horizontal)
        dashLabel.setContentHuggingPriority(.required, for: .horizontal)
        //toLearnProgressLabel.setContentHuggingPriority(.required, for: .horizontal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with stats: ContinentStats) {
        learnedProgressLabel.text = String(format: "%.1f", stats.learnedProgress * 100)
        toLearnProgressLabel.text = String(format: "%.1f", stats.toLearnProgress * 100)
        
        //        if stats.name == "World" {
        //            progressView.progressTintColor = .purple.withAlphaComponent(0.8)
        //        } else {
        //            progressView.progressTintColor = .blue.withAlphaComponent(0.8)
        //        }
        
          //  progressView.progressTintColor = stats.name == "World" ? .purple.withAlphaComponent(0.8) : .blue.withAlphaComponent(0.8)
        
        progressView.progress = Float(stats.learnedProgress)
//        progressView.setProgress(0, animated: false)
//        progressView.setProgress(Float(stats.learnedProgress), animated: false)
        
        print(stats.name, stats.learned, stats.toLearn, stats.learnedProgress, stats.toLearnProgress       )
        
        learnedProgressLabel.textColor = stats.learnedProgress > 0 ? .systemGreen : .systemGreen.withAlphaComponent(0.5)
        toLearnProgressLabel.textColor = stats.toLearnProgress < 100 ? .systemYellow : .systemYellow.withAlphaComponent(0.5)
        percentLearnedLabel.textColor = stats.learnedProgress > 0 ? .systemGreen.withAlphaComponent(0.8) : .systemGreen.withAlphaComponent(0.5)
        percentToLearnLabel.textColor = stats.toLearnProgress < 100 ? .systemYellow.withAlphaComponent(0.8) : .systemYellow.withAlphaComponent(0.5)
        dashLabel.textColor = stats.learnedProgress > 0 ? .tertiaryLabel : .systemGray5
    }
    
}


extension UIFont {
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight = .medium ) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        let descriptor = base.fontDescriptor.withDesign(.rounded)
        return UIFont(descriptor: descriptor ?? base.fontDescriptor, size: size)
    }
    
    static func monospaced(ofSize size: CGFloat, weight: UIFont.Weight = .medium) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        let descriptor = base.fontDescriptor.withDesign(.monospaced)
        return UIFont(descriptor: descriptor ?? base.fontDescriptor, size: size)
    }
}
