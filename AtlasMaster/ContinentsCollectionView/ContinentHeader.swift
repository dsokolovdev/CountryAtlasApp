//
//  HeaderView.swift
//  AtlasMaster
//
//  Created by Dmitri  on 10.12.25.
//
import UIKit

final class ContinentHeader: UICollectionReusableView {
    static let reuseId = "ContinentHeader"
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .bold)
        lbl.textAlignment = .left
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let c: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}


//class ContinentHeader_: UICollectionReusableView {
//    static let reuseId = "ContinentHeader"
//
//    let titleLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.font = .boldSystemFont(ofSize: 20)
//        lbl.textAlignment = .left
//        return lbl
//    }()
////    let countLabel = UILabel()
////    let totalLabel = UILabel()
////    let dashLablel = UILabel()
//    let hStack = UIStackView()
////    let hStackCount = UIStackView()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        addSubview(titleLabel)
//        
////        countLabel.font = .systemFont(ofSize: 14)
////        countLabel.textAlignment = .left
////        countLabel.textColor = .secondaryLabel
//        
////        totalLabel.font = .systemFont(ofSize: 14)
////        totalLabel.textAlignment = .left
////        totalLabel.textColor = .secondaryLabel
//        
////        dashLablel.font = .systemFont(ofSize: 14)
////        dashLablel.textAlignment = .center
////        dashLablel.textColor = .secondaryLabel
////        dashLablel.text = "/"
//        
////        hStackCount.axis = .horizontal
////        hStackCount.alignment = .center
////        hStackCount.distribution = .fill
////        hStackCount.spacing = 4
//        
////        hStackCount.addArrangedSubview(countLabel)
////        hStackCount.addArrangedSubview(dashLablel)
////        hStackCount.addArrangedSubview(totalLabel)
//        
////        hStack.axis = .horizontal
////        hStack.alignment = .center
////        hStack.distribution = .fill   // ← Важный момент!
////        hStack.spacing = 8
//        
//        //hStack.addArrangedSubview(titleLabel)
//        //hStack.addArrangedSubview(hStackCount)
//        //hStack.addArrangedSubview(totalLabel)
//
//        //addSubview(hStack)
//        //hStack.translatesAutoresizingMaskIntoConstraints = false
//        
//        let c: CGFloat = 16 * scaleFactor
//        NSLayoutConstraint.activate([
//            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
//            hStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -c),
//            hStack.topAnchor.constraint(equalTo: topAnchor),
//            hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//        
////        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
////        countLabel.setContentHuggingPriority(.required, for: .horizontal)
////        totalLabel.setContentHuggingPriority(.required, for: .horizontal)
//
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

