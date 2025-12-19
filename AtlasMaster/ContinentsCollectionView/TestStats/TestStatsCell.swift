//
//  StatsCell.swift
//  AtlasMaster
//
//  Created by Dmitri  on 12.12.25.
//
import UIKit

final class TestStatsCell: UICollectionViewCell {
    static let reusedId = "TestStatsCell"
    
    let progressView = TestProgressView()
    
    private let passedProgressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .systemYellow
        return lbl
    }()
    
    private let failedProgressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .systemYellow
        return lbl
    }()
    
    private let untestedProgressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .systemGreen
        return lbl
    }()
    
//    private let dashLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.font = .rounded(ofSize: 28, weight: .regular)
//        lbl.textAlignment = .center
//        //lbl.textColor = .tertiaryLabel
//        lbl.text = "/"
//        return lbl
//    }()
    
    private let passedPercentLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "%"
        lbl.font = .rounded(ofSize: 15, weight: .semibold)
        lbl.textAlignment = .left
        //lbl.textColor = .systemGreen.withAlphaComponent(0.6)
        return lbl
    }()
    
    private let failedPercentLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "%"
        lbl.font = .rounded(ofSize: 15, weight: .semibold)
        lbl.textAlignment = .left
        //lbl.textColor = .systemYellow.withAlphaComponent(0.6)
        return lbl
    }()
    
    private let untestedPercentLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "%"
        lbl.font = .rounded(ofSize: 15, weight: .semibold)
        lbl.textAlignment = .left
        //lbl.textColor = .systemYellow.withAlphaComponent(0.6)
        return lbl
    }()
    
    private var passedIcon: UIImageView = {
        let img = UIImage(systemName: "checkmark.circle.fill")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColors.wildgreen
        return imgView
        
    }()
    
    private var failedIcon: UIImageView = {
        let img = UIImage(systemName: "xmark.circle.fill")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColors.carolinareaper
        return imgView
        
    }()
    
    private var untestedIcon: UIImageView = {
        let img = UIImage(systemName: "circle")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = AppColors.greyblue
        return imgView
        
    }()
    
    private let hStackfailed: UIStackView = {
        let stack = UIStackView()
         stack.axis = .horizontal
         stack.spacing = 6
         stack.distribution = .fill
         stack.alignment = .center
         return stack
     }()
     
     private let hStackPassed: UIStackView = {
         let stack = UIStackView()
          stack.axis = .horizontal
          stack.spacing = 6
          stack.distribution = .fill
          stack.alignment = .center
          return stack
      }()
    
    private let hStackUntested: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
      private let hStackProgress: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()
    
    private let hStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //ProgressView
        addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        //progressView.layer.cornerRadius = CGRectGetHeight(frame) / 2.4
        
        let h: CGFloat = 0 * scaleFactor
        let w: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: w),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -w),
            progressView.topAnchor.constraint(equalTo: topAnchor, constant: h),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -h)
        ])
        
        //Horizontal Stack
        hStackfailed.addArrangedSubview(failedIcon)
        hStackfailed.addArrangedSubview(failedProgressLabel)
        hStackfailed.addArrangedSubview(failedPercentLabel)
        
        hStackPassed.addArrangedSubview(passedIcon)
        hStackPassed.addArrangedSubview(passedProgressLabel)
        hStackPassed.addArrangedSubview(passedPercentLabel)
        
        hStackUntested.addArrangedSubview(untestedIcon)
        hStackUntested.addArrangedSubview(untestedProgressLabel)
        hStackUntested.addArrangedSubview(untestedPercentLabel)
        
        NSLayoutConstraint.activate([
            passedIcon.widthAnchor.constraint(equalToConstant: 16),
            passedIcon.heightAnchor.constraint(equalToConstant: 16),
            
            failedIcon.widthAnchor.constraint(equalToConstant: 16),
            failedIcon.heightAnchor.constraint(equalToConstant: 16),
            
            untestedIcon.widthAnchor.constraint(equalToConstant: 16),
            untestedIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        failedProgressLabel.setContentHuggingPriority(.required, for: .horizontal)
        failedProgressLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        passedProgressLabel.setContentHuggingPriority(.required, for: .horizontal)
        passedProgressLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        untestedProgressLabel.setContentHuggingPriority(.required, for: .horizontal)
        untestedProgressLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        
        hStackProgress.addArrangedSubview(hStackfailed)
        hStackProgress.addArrangedSubview(hStackPassed)
        
        hStack.addArrangedSubview(hStackProgress)
        hStack.addArrangedSubview(hStackUntested)
        
        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        let width: CGFloat = 200 * scaleFactor
        let heightConst: CGFloat = 10 * scaleFactor
        let widthConst: CGFloat = 20 * scaleFactor
        NSLayoutConstraint.activate([
            //hStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            hStack.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: widthConst),
            hStack.trailingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: -widthConst),
            hStack.topAnchor.constraint(equalTo: progressView.topAnchor, constant: heightConst),
            hStack.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -heightConst),
            //hStack.widthAnchor.constraint(equalToConstant: width)
        ])
        
        //learnedProgressLabel.setContentHuggingPriority(.required, for: .horizontal)
        //dashLabel.setContentHuggingPriority(.required, for: .horizontal)
        //toLearnProgressLabel.setContentHuggingPriority(.required, for: .horizontal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with stats: ContinentTestStats) {
        //let name = stats.name
       // let finishedRation = stats.finishedRatio
        let passedRatio = stats.passedRatio
        let failedRatio = stats.failedRatio
        let passed = stats.passed
        let failed = stats.failed
        let total = stats.total
        let untested = stats.untested
        let untestedRatio = total > 0 ? Double(untested) / Double(total) : 0

        progressView.setProgress(total: total, passed: passed, failed: failed)
        
        passedProgressLabel.text = String(format: "%.1f", passedRatio * 100 )
        failedProgressLabel.text = String(format: "%.1f", failedRatio * 100)
        untestedProgressLabel.text = String(format: "%.1f", untestedRatio * 100)
        
       // progressView.setProgress(CGFloat(learnedProgress))
        progressView.layoutIfNeeded()
        
        passedProgressLabel.textColor = passedRatio > 0 ? .deepGreen : .deepGreen.withAlphaComponent(0.5)
        passedPercentLabel.textColor = passedRatio > 0 ? .deepGreen.withAlphaComponent(0.8) : .deepGreen.withAlphaComponent(0.5)
        passedIcon.tintColor = passedRatio > 0 ? .deepGreen : .deepGreen.withAlphaComponent(0.5)
        
        failedProgressLabel.textColor = passedRatio > 0 ? .coolRed : .coolRed.withAlphaComponent(0.5)
        failedPercentLabel.textColor = passedRatio > 0 ? .coolRed.withAlphaComponent(0.8) : .coolRed.withAlphaComponent(0.5)
        failedIcon.tintColor = passedRatio > 0 ? .coolRed : .coolRed.withAlphaComponent(0.5)
        
        untestedProgressLabel.textColor = passedRatio > 0 ? .greyBlue : .greyBlue.withAlphaComponent(0.5)
        untestedPercentLabel.textColor = passedRatio > 0 ? .greyBlue : .greyBlue.withAlphaComponent(0.5)
        untestedIcon.tintColor = passedRatio > 0 ? .greyBlue : .greyBlue.withAlphaComponent(0.5)
        
        
//        if name == "World" {
//            progressView.setFillColor(AppColors.nasauurple.withAlphaComponent(0.8))
//        } else {
//            progressView.setFillColor(AppColors.darkblue.withAlphaComponent(0.8))
//        }
    }
    
}
