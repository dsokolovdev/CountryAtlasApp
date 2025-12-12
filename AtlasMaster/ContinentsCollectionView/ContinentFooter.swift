//
//  FooterView.swift
//  AtlasMaster
//
//  Created by Dmitri  on 10.12.25.
//

import UIKit

final class ContinentFooter: UICollectionReusableView {
    static let reuseId = "ContinentFooter"

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .rounded(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        let c: CGFloat = 16 * scaleFactor
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -c),
            label.topAnchor.constraint(equalTo: topAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(count: Int) {
        label.text = "Done: \(count)"
    }
}
