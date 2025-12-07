//
//  ContinentPickerView.swift
//  AtlasMaster
//
//  Created by Dmitri  on 07.12.25.
//

import UIKit

class ContinentPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let picker = UIPickerView()
    let continents = AtlasModel().continents
    var selectedContinent: String!
    var currentIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
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
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //        return continents[row]
    //    }
    
    //    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    //        let title = continents[row]
    //        let anyAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 18, weight: .medium)]
    //        let worldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: UIColor.systemGreen]
    //        let attributes =  title == "World" ? worldAttributes : anyAttributes
    //        let myTitle = NSAttributedString(string: title, attributes: attributes)
    //        return myTitle
    //    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.text = continents[row]
        //let isSelected = row == selectedRow
        
        label.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        label.textColor = label.text == "World" ? .systemGreen : .label
        
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex =  row
        selectedContinent = continents[row]
        //pickerView.reloadComponent(component)
    }
    
    /// Выбрать континент по индексу
    func selectContinent(at index: Int) {
        guard index >= 0 && index < continents.count else { return }
        picker.selectRow(index, inComponent: 0, animated: false)
        selectedContinent = continents[index]
    }
    
    /// Выбрать континент по имени
    func selectContinent(named name: String) {
        if let index = continents.firstIndex(of: name) {
            selectContinent(at: index)
        }
    }
}
