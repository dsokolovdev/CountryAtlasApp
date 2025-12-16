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
    
    func configure(continent: Continent) {
        titleLabel.text = continent.name
    }
}
