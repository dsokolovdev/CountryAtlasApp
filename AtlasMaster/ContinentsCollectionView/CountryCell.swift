//
//  CountryCell.swift
//  AtlasMaster
//
//  Created by Dmitri  on 09.12.25.
//
import UIKit
//final class CountryCell: UICollectionViewCell {
//    
//    private let indexLabel = UILabel()
//    private let flagLabel = UILabel()
//    private let nameLabel = UILabel()
//    private let capitalLabel = UILabel()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(index: Int, flag: String, name: String, capital: String) {
//        indexLabel.text = "\(index)"
//        flagLabel.text = flag
//        nameLabel.text = name
//        capitalLabel.text = capital
//    }
//    
//    private func setupUI() {
//        indexLabel.font = .systemFont(ofSize: 14, weight: .light)
//        flagLabel.font = .systemFont(ofSize: 50)
//        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
//        capitalLabel.font = .systemFont(ofSize: 16, weight: .regular)
//        capitalLabel.textColor = .secondaryLabel
//        
//        let textStack = UIStackView(arrangedSubviews: [nameLabel, capitalLabel])
//        textStack.axis = .vertical
//        textStack.alignment = .fill
//        textStack.spacing = 2
//        
//        let mainStack = UIStackView(arrangedSubviews: [indexLabel, flagLabel, textStack])
//        mainStack.axis = .horizontal
//        mainStack.spacing = 8
//        mainStack.alignment = .fill
//        
//        contentView.addSubview(mainStack)
//        mainStack.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
//        ])
//    }
//}


final class CountryCell: UICollectionViewCell {
    static let reusedId = "CountryCell"
    
    private let indexLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .light)
        lbl.textAlignment = .natural
        return lbl
    }()
    
    private let flagLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 60)
        lbl.textAlignment = .left
        return lbl
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.textAlignment = .right
        return lbl
    }()

    private let capitalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .right
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let rightStack = UIStackView(arrangedSubviews: [nameLabel, capitalLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 4
        
        let leftStack = UIStackView(arrangedSubviews: [flagLabel ])
        leftStack.axis = .horizontal
        leftStack.alignment = .leading
        leftStack.spacing = 4

        let container = UIStackView(arrangedSubviews: [leftStack, rightStack])
        container.axis = .horizontal
        container.spacing = 8
        container.alignment = .center
       //container.distribution = .fill

        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.2)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(index: Int, flag: String, name: String, capital: String) {
        indexLabel.text = "\(index + 1)"
        flagLabel.text = flag
        nameLabel.text = name
        capitalLabel.text = capital
    }
}
