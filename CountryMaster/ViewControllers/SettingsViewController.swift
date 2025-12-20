//
//  SettingsViewController.swift
//  CountryMaster
//
//  Created by Dmitri on 19.12.25.
//

import UIKit

// MARK: - Settings View Controller
/// Displays application settings.
/// Currently supports selecting Mask Mode for testing.
final class SettingsViewController: UITableViewController {
    
    // MARK: - Dependencies
    /// Shared app model used to store and update settings.
    private let model: CountryModel
    
    /// Static settings structure describing table sections/rows.
    private let settings: Settings
    
    /// Callback triggered when any setting is changed.
    /// Used to notify parent controller to update UI.
    var onSettingsChange: (() -> Void)?
    
    // MARK: - Initializers
    /// Designated initializer.
    /// - Parameters:
    ///   - model: Shared CountryModel instance
    ///   - settings: Settings description model (default provided)
    init(model: CountryModel, settings: Settings = Settings()) {
        self.model = model
        self.settings = settings
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        tableView.bounces = false
        
        configureFooter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Can be used if you want to notify about changes on dismiss
        // onSettingsChange?()
    }
}

// MARK: - UITableView Data Source
extension SettingsViewController {
    
    /// Number of sections defined in Settings model.
    override func numberOfSections(in tableView: UITableView) -> Int {
        settings.sections.count
    }
    
    /// Number of rows per section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings.sections[section].rows.count
    }
    
    /// Configures settings cell.
    /// Currently supports Mask Mode selection via UIButton + UIMenu.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = settings.sections[indexPath.section]
        let row = section.rows[indexPath.row]
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.textLabel?.text = row.text
        
        // MARK: - Accessory Button (Mask Mode Selector)
        let button = UIButton(type: .system)
        button.setTitle(model.maskMode.title, for: .normal)
        button.titleLabel?.font = .rounded(ofSize: 16.scaled, weight: .medium)
        
        // Build menu from all MaskMode cases
        button.menu = UIMenu(
            children: MaskMode.allCases.map { mode in
                let isSelected = mode == model.maskMode
                
                let action = UIAction(title: mode.title, state: isSelected ? .on : .off) { [weak self] _ in
                    guard let self else { return }
                    
                    // Update model
                    self.model.maskMode = mode
                    
                    //Save Data
                    model.saveMaskModeConfig(maskMode: mode)
                    
                    // Notify parent controller
                    self.onSettingsChange?()
                    
                    // Update UI
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
                
                // Customize title color (selected / unselected)
                action.setValue(
                    NSAttributedString(
                        string: mode.title,
                        attributes: [.foregroundColor: isSelected ? UIColor.label : UIColor.secondaryLabel]),
                    forKey: "attributedTitle"
                )
                
                return action
            }
        )
        
        button.showsMenuAsPrimaryAction = true
        button.sizeToFit()
        cell.accessoryView = button
        
        return cell
    }
    
    /// Section header titles.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        settings.sections[section].title
    }
}

// MARK: - Footer Configuration
extension SettingsViewController {
    
    /// Attaches footer displaying app version/build info.
    private func configureFooter() {
        let size: CGFloat = max(12.scaled, 13.scaled)
        
        let footerLabel = UILabel()
        footerLabel.text = Settings.settingsFooterText
        footerLabel.font = .systemFont(ofSize: size.scaled)
        footerLabel.textColor = .secondaryLabel
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let footerView = UIView()
        footerView.addSubview(footerLabel)
        
        let w: CGFloat = 16.scaled
        let h: CGFloat = 8.scaled
        
        NSLayoutConstraint.activate([
            footerLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: w),
            footerLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -w),
            footerLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: h),
            footerLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -h)
        ])
        
        footerView.frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.width,
            height: 120.scaled
        )
        
        tableView.tableFooterView = footerView
    }
}
