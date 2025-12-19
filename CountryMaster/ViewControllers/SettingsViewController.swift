//
//  SettingsViewController.swift
//  CountryMaster
//
//  Created by Dmitri  on 19.12.25.
//

import UIKit

final class SettingsViewController: UITableViewController {
    //var settings: Settings
    
//    init(settings: Settings) {
//        self.settings = settings
//        super.init(style: .insetGrouped)
//    }
    override init(style: UITableView.Style = .insetGrouped) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        tableView.bounces = false
        
        configureFooter()
    }
}

extension SettingsViewController {
    
    /// Attaches footer text displaying version/build information.
    private func configureFooter() {
        let size: CGFloat = max(12, 13 * scaleFactor)
        
        let footerLabel = UILabel()
        footerLabel.text = Settings.settingsFooterText
        footerLabel.font = .systemFont(ofSize: size)
        footerLabel.textColor = .secondaryLabel
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let footerView = UIView()
        footerView.addSubview(footerLabel)
        
        let w: CGFloat = 16 * scaleFactor
        let h: CGFloat = 8 * scaleFactor
        
        NSLayoutConstraint.activate([
            footerLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: w),
            footerLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -w),
            footerLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: h),
            footerLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -h)
        ])
        
        footerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 120 * scaleFactor)
        tableView.tableFooterView = footerView
    }
}
