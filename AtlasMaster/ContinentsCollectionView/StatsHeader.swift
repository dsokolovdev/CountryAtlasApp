//
//  StatsHeader.swift
//  AtlasMaster
//
//  Created by Dmitri  on 12.12.25.
//

import UIKit

final class StatsHeader: UICollectionReusableView {
    static let reusedId = "StatsHeader"
    
    let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 20, weight: .bold)
        lbl.textAlignment = .left
        lbl.textColor = .label
        return lbl
    }()
    
    let starImage: UIImageView = {
        let img = UIImageView()
        let image = UIImage(systemName: "star.fill")!
        img.image = image.withRenderingMode(.alwaysTemplate)
        img.tintColor = .systemBlue
        img.contentMode = .scaleAspectFit
        return img
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
        
        addSubview(hStack)
        hStack.addArrangedSubview(nameLabel)
        hStack.addArrangedSubview(starImage)
        
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        let c: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: c),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -c),
           // hStack.topAnchor.constraint(equalTo: topAnchor)
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, progress: Double) {
        nameLabel.text = name
        starImage.alpha = progress > 0.0 ? 1 : 0
        starImage.image = progress == 100.0 ? UIImage(systemName: "star.fill") : (progress >= 50 ? UIImage(systemName: "star.leadinghalf.filled") : UIImage(systemName: "star"))
        
        if nameLabel.text == "World" {
            nameLabel.textColor  = progress > 0 ? .blue : .blue.withAlphaComponent(0.5)
        } else {
            nameLabel.textColor  = progress > 0 ? .label : .tertiaryLabel
        }
        
        starImage.tintColor = name == "World" ? .purple : .blue
        
    }
    
}
