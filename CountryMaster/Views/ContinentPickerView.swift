//
//  ContinentPickerView.swift
//
//  Created by Dmitri  on 07.12.25.
//
//  Description:
//  Custom UIPickerView wrapper used for selecting a continent or "World".
//  Displays a single-column picker with continent names and provides
//  helpers for programmatic selection and retrieving the current value.
//

import UIKit

// MARK: - ContinentPickerView
final class ContinentPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - UI
    /// Underlying system picker view.
    private let picker = UIPickerView()

    // MARK: - Data
    /// List of available continents ("World" may be injected by caller).
    var continents: [Continent]

    /// Currently selected index in the picker.
    var currentIndex: Int = 0

    /// Convenience accessor for the currently selected continent name.
    var selectedName: String {
        let row = picker.selectedRow(inComponent: 0)
        return continents[row].name
    }
    
    // MARK: - Init
    /// Designated initializer.
    /// - Parameter continents: Array of continents to display in picker.
    init(continents: [Continent]) {
        self.continents = continents
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    /// Configures picker view, appearance, and constraints.
    private func setup() {
        backgroundColor = .clear
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        picker.dataSource = self
        picker.delegate = self
        
        addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: topAnchor),
            picker.bottomAnchor.constraint(equalTo: bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    // MARK: - UIPickerViewDataSource
    /// Number of components (columns) in picker.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1   // Single column
    }
    
    /// Number of rows in the single component.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return continents.count
    }
    
    // MARK: - UIPickerViewDelegate
    /// Provides a custom view for each row.
    /// Highlights "World" differently from other continents.
    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing view: UIView?
    ) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.text = continents[row].name
        
        // Style "World" differently
        label.font = label.text == "World"
            ? UIFont.rounded(ofSize: 22, weight: .medium)
            : UIFont.rounded(ofSize: 22, weight: .regular)
        
        label.textColor = label.text == "World" ? AppColors.darkblue : .label
        
        return label
    }
    
    /// Updates current index when user selects a row.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex = row
    }
    
    // MARK: - Helpers
    /// Selects a continent by index.
    /// - Parameter index: Index in the continents array.
    func selectContinent(at index: Int) {
        guard index >= 0 && index < continents.count else { return }
        currentIndex = index
        picker.selectRow(index, inComponent: 0, animated: false)
    }
    
    /// Selects a continent by its name.
    /// - Parameter name: Name of the continent to select.
    func selectContinent(named name: String) {
        if let index = continents.firstIndex(where: { $0.name == name }) {
            selectContinent(at: index)
        }
    }
}

