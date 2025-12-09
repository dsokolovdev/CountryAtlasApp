//
//  HeaderView.swift
//  AtlasMaster
//
//  Created by Dmitri  on 10.12.25.
//
import UIKit

//final class HeaderView: UICollectionReusableView {
//    static let reuseId = "HeaderView"
//
//    let label = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        label.font = .boldSystemFont(ofSize: 20)
//        addSubview(label)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            label.leadingAnchor.constraint(equalTo: leadingAnchor),
//            label.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//
//    required init?(coder: NSCoder) { fatalError() }
//}

class HeaderView: UICollectionReusableView {
    static let reuseId = "HeaderView"

    let titleLabel = UILabel()
    let countLabel = UILabel()
    let hStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .boldSystemFont(ofSize: 20)
        countLabel.font = .systemFont(ofSize: 14)
        countLabel.textColor = .secondaryLabel

        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.distribution = .equalSpacing   // ← Важный момент!
        hStack.addArrangedSubview(titleLabel)
        hStack.addArrangedSubview(countLabel)

        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStack.topAnchor.constraint(equalTo: topAnchor),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
