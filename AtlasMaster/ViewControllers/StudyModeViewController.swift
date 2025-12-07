//
//  ModelViewController.swift
//  AtlasMaster
//
//  Created by Dmitri  on 07.12.25.
//

import UIKit

final class StudyModeViewController: UIViewController {
    
    var continentPicker: ContinentPickerView!
    var glassView: UIView!
    var studyModeSegmentedControl: UISegmentedControl!
    var onSelectionConfirmed: ((Region, StudyMode) -> Void)?
    var selectedModeindex = 0
    let continents = AtlasModel().continents
    var initialRegion: Region = .world
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupContinentPicker()
        setupStudyMode()
        //setupNavigationBarSegmentedControl()
        
        studyModeSegmentedControl.selectedSegmentIndex = selectedModeindex
        selectRegion(initialRegion)
        view.backgroundColor = .white
    }
}
//MARK: -  Setup UI
extension StudyModeViewController {
    
    private func setupNavigationBar() {
        title = "Select Study Mode"
        
        // Кнопка "Done" (галочка)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(doneTapped)
        )
    }
    
    func setupStudyMode() {
        studyModeSegmentedControl = UISegmentedControl(items: ["Learning", "Testing"])
        studyModeSegmentedControl.selectedSegmentIndex = 0
        studyModeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
//        let currentIndex = studyModeSegmentedControl.selectedSegmentIndex
//        let size: CGFloat = 15
//        let inactiveColor = UIColor.secondaryLabel
//        let activeColor = currentIndex == 0 ? UIColor.systemBlue : UIColor.systemRed
//        let inactiveFont = UIFont.systemFont(ofSize: size, weight: .regular)
//        let activeFont = UIFont.systemFont(ofSize: size, weight: .medium)
//        
//        studyModeSegmentedControl.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: inactiveFont], for: .normal)
//        studyModeSegmentedControl.setTitleTextAttributes([.foregroundColor: activeColor, .font: activeFont], for: .selected)
        
        studyModeSegmentedControl.addTarget(self, action: #selector(studyModeChanged), for: .valueChanged)
        
        view.addSubview(studyModeSegmentedControl)
        
        NSLayoutConstraint.activate([
            studyModeSegmentedControl.bottomAnchor.constraint(equalTo: glassView.topAnchor, constant: -20),
            studyModeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            studyModeSegmentedControl.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        setColors()
    }
    
    func setupNavigationBarSegmentedControl() {
        let barView = UIView()
        barView.translatesAutoresizingMaskIntoConstraints = false
        barView.backgroundColor = .clear
        barView.layer.cornerRadius = 22 * scaleFactor
        view.addSubview(barView)
        
        barView.layer.shadowColor = UIColor.label.cgColor
        barView.layer.shadowOpacity = 0.05
        barView.layer.shadowOffset = CGSize(width: 0, height: 2.5)
        barView.layer.shadowRadius = 4
        barView.layer.masksToBounds = false
        
        let activeColor = UIColor.label
        let inactiveColor = UIColor.tertiaryLabel
        let size: CGFloat = 16 * scaleFactor
        let activeFont = UIFont.systemFont(ofSize: size, weight: .medium)
        let inactiveFont = UIFont.systemFont(ofSize: size, weight: .regular)
        
        let items = ["Learning", "Testing"]
        let segmentedControl = UISegmentedControl(items: items)
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.widthAnchor.constraint(equalToConstant: 140).isActive = true
        segmentedControl.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: inactiveFont], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: activeColor, .font: activeFont], for: .selected)
        segmentedControl.subviews.forEach { $0.backgroundColor = .systemBackground }
        
        // Add a target to handle segment changes
        //segmentedControl.addTarget(self, action: #selector(studyModeChanged), for: .valueChanged)
        
        barView.addSubview(segmentedControl)
        
        //        NSLayoutConstraint.activate([
        //            view.widthAnchor.constraint(equalToConstant: 140),
        //            segmentedControl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        //            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        //            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        //
        //        ])
        let scHeight: CGFloat = 32 * scaleFactor
        let constant: CGFloat = 3 * scaleFactor
        let barHeigh: CGFloat = 48 * scaleFactor
        
        NSLayoutConstraint.activate([
            barView.heightAnchor.constraint(equalToConstant: barHeigh),
            barView.widthAnchor.constraint(equalToConstant: 300),
            barView.bottomAnchor.constraint(equalTo: glassView.topAnchor, constant: -20),
            barView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            segmentedControl.centerYAnchor.constraint(equalTo: barView.centerYAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: barView.leadingAnchor, constant: constant),
            segmentedControl.trailingAnchor.constraint(equalTo: barView.trailingAnchor, constant: -constant),
            segmentedControl.heightAnchor.constraint(equalToConstant: scHeight)
        ])
        
    }
    
    func setupContinentPicker() {
        glassView = UIView()
        glassView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        glassView.layer.cornerRadius = 20
        glassView.layer.borderWidth = 1
        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        glassView.layer.shadowColor = UIColor.black.cgColor
        glassView.layer.shadowOpacity = 0.2
        glassView.layer.shadowRadius = 20
        glassView.layer.shadowOffset = .zero
        glassView.translatesAutoresizingMaskIntoConstraints = false
        
        continentPicker = ContinentPickerView()
        continentPicker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(glassView)
        glassView.addSubview(continentPicker)
        
        
        NSLayoutConstraint.activate([
            glassView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            glassView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            glassView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            glassView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            glassView.heightAnchor.constraint(equalToConstant: 160 * scaleFactor),
            glassView.widthAnchor.constraint(equalToConstant: 300 * scaleFactor),
            
            // Picker inside the glass
            continentPicker.topAnchor.constraint(equalTo: glassView.topAnchor, constant: 8),
            continentPicker.bottomAnchor.constraint(equalTo: glassView.bottomAnchor, constant: -8),
            continentPicker.leadingAnchor.constraint(equalTo: glassView.leadingAnchor),
            continentPicker.trailingAnchor.constraint(equalTo: glassView.trailingAnchor)
        ])
    }
}

//MARK: - Actions
extension StudyModeViewController {

    @objc private func doneTapped() {
        let continent = continentPicker.selectedContinent
        let index = studyModeSegmentedControl.selectedSegmentIndex
        let region: Region = (continent == "World") ? .world : .continent(continent ?? "Europe")
        let mode: StudyMode = (index == 0) ? .learning : .testing
        
        selectedModeindex = index
        initialRegion = region
        
        onSelectionConfirmed?(region, mode)
        
        dismiss(animated: true)
    }
    
    @objc func studyModeChanged() {
        setColors()
    }
    
    func setColors() {
        let currentIndex = studyModeSegmentedControl.selectedSegmentIndex
        let size: CGFloat = 15
        let inactiveColor = UIColor.secondaryLabel
        let activeColor = currentIndex == 0 ? UIColor.systemBlue : UIColor.systemRed
        let inactiveFont = UIFont.systemFont(ofSize: size, weight: .regular)
        let activeFont = UIFont.systemFont(ofSize: size, weight: .medium)
        
        studyModeSegmentedControl.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: inactiveFont], for: .normal)
        studyModeSegmentedControl.setTitleTextAttributes([.foregroundColor: activeColor, .font: activeFont], for: .selected)
    }
    
    func selectRegion(_ region: Region) {
        let name: String
        switch region {
        case .world:
            name = "World"
        case .continent(let continentName):
            name = continentName
        }

        continentPicker.selectContinent(named: name)
    }
    
}
