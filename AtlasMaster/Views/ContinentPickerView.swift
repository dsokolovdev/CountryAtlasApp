//
//  ContinentPickerView.swift
//  AtlasMaster
//
//  Created by Dmitri  on 07.12.25.
//

import UIKit

class ContinentPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let picker = UIPickerView()
    var continents: [Continent]
    //var selectedContinent: String!
    var currentIndex: Int = 0
    var selectedName: String {
        let row = picker.selectedRow(inComponent: 0)
        return continents[row].name
    }
    
    // главный init — сюда передаём континенты
        init(continents: [Continent]) {
            self.continents = continents
            super.init(frame: .zero)
            setup()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            picker.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    // MARK: - Picker Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1   // Количество колонок
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  continents.count
    }
    
    // MARK: - Picker Delegate
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
       // label.textColor = .label
        label.text = continents[row].name
        //let isSelected = row == selectedRow
        
        label.font = label.text == "World" ? UIFont.rounded(ofSize: 22, weight: .medium) : UIFont.rounded(ofSize: 22, weight: .regular)
        label.textColor = label.text == "World" ? AppColors.darkblue : .label
        
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex =  row
    }
    
    //MARK: - Helpers
    /// Выбрать континент по индексу
    func selectContinent(at index: Int) {
        guard index >= 0 && index < continents.count else { return }
        currentIndex = index
        picker.selectRow(index, inComponent: 0, animated: false)
    }
    
    /// Выбрать континент по имени
    func selectContinent(named name: String) {
        if let index = continents.firstIndex(where: { $0.name == name }) {
            selectContinent(at: index)
        }
    }
}
