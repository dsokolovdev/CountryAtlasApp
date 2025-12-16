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
    var initialRegion: Region = .world
    
    private let world: World
    
    init(world: World, initialConfig: StudyConfiguration) {
        self.world = world
        self.selectedModeindex = initialConfig.mode.rawValue
        self.initialRegion = initialConfig.region
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationTitle()
        
        
        setupNavigationBar()
        setupContinentPicker()
        setupStudyMode()
        
        studyModeSegmentedControl.selectedSegmentIndex = selectedModeindex
        selectRegion(initialRegion)
        view.backgroundColor = .systemBackground
        setColors()
    }
}
//MARK: -  Setup UI
extension StudyModeViewController {
    
    private func setupNavigationBar() {
        title = "Study Mode Selection"
        
        // Кнопка "Done" (галочка)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }
    
    func setupStudyMode() {
        studyModeSegmentedControl = UISegmentedControl(items: ["Learning", "Testing"])
        studyModeSegmentedControl.selectedSegmentIndex = 0
        studyModeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        studyModeSegmentedControl.addTarget(self, action: #selector(studyModeChanged), for: .valueChanged)
        
        view.addSubview(studyModeSegmentedControl)
        
        NSLayoutConstraint.activate([
            studyModeSegmentedControl.bottomAnchor.constraint(equalTo: glassView.topAnchor, constant: -20),
            studyModeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            studyModeSegmentedControl.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        setColors()
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
        
        var sortedContinents = world.continents.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        sortedContinents.insert(Continent(name: "World", countries: []), at: 0)

        continentPicker = ContinentPickerView(continents: sortedContinents)
        
        continentPicker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(glassView)
        glassView.addSubview(continentPicker)
        
        
        NSLayoutConstraint.activate([
            glassView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            glassView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
    //Confirm selection on segmented control and picker
    @objc private func doneTapped() {
        //let continent = continentPicker.selectedContinent
        let continent = continentPicker.selectedName
        let index = studyModeSegmentedControl.selectedSegmentIndex
        let region: Region = (continent == "World") ? .world : .continent(continent)
        let mode: StudyMode = (index == 0) ? .learning : .testing
        
        selectedModeindex = index
        initialRegion = region
        
        print(selectedModeindex, initialRegion)
        
        onSelectionConfirmed?(region, mode)
        
        dismiss(animated: true)
    }
    
    @objc func studyModeChanged() {
        setColors()
    }
    
    //Change color of segmented control base on selection
    func setColors() {
        let currentIndex = studyModeSegmentedControl.selectedSegmentIndex
        let size: CGFloat = 16
        let inactiveColor = UIColor.secondaryLabel
        let activeColor = currentIndex == 0 ? AppColors.marine : AppColors.coolred
        let inactiveFont = UIFont.systemFont(ofSize: size, weight: .medium)
        let activeFont = UIFont.systemFont(ofSize: size, weight: .medium)
        
        studyModeSegmentedControl.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: inactiveFont], for: .normal)
        studyModeSegmentedControl.setTitleTextAttributes([.foregroundColor: activeColor, .font: activeFont], for: .selected)
    }
    
    //When open studymodeview set picker selected region to continues from already selected one
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

extension StudyModeViewController {
   
    private func configureNavigationTitle() {
        let appearance = UINavigationBarAppearance()
        //appearance.configureWithOpaqueBackground()
       // appearance.backgroundColor = .systemBackground

        appearance.titleTextAttributes = [
            .font: UIFont.rounded(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.label
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
}
