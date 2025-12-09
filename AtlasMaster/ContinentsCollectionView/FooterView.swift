//
//  FooterView.swift
//  AtlasMaster
//
//  Created by Dmitri  on 10.12.25.
//

import UIKit

final class FooterView: UICollectionReusableView {
    static let reuseId = "FooterView"

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(count: Int) {
        label.text = "Countries: \(count)"
    }
}
