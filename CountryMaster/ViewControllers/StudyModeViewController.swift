//
//  ModelViewController.swift
//
//  Created by Dmitri  on 07.12.25.
//
//  Description:
//  Screen for selecting study mode (Learning / Testing)
//  and target region (World or specific continent).
//  Presented as a modal sheet from AtlasViewController.
//  Returns selected Region + StudyMode via callback.
//

import UIKit

// MARK: - StudyModeViewController
final class StudyModeViewController: UIViewController {
    
    // MARK: - UI
    /// Picker that displays available continents + World option.
    var continentPicker: ContinentPickerView!
    
    /// Glass-style container view for the picker.
    var glassView: UIView!
    
    /// Segmented control for selecting study mode (Learning / Testing).
    var studyModeSegmentedControl: UISegmentedControl!
    
    // MARK: - Callbacks
    /// Called when user confirms selection by tapping Done.
    /// Returns selected Region and StudyMode.
    var onSelectionConfirmed: ((Region, StudyMode) -> Void)?
    
    // MARK: - State
    /// Currently selected segment index (Learning / Testing).
    var selectedModeindex = 0
    
    /// Initially selected region (used to restore previous choice).
    var initialRegion: Region = .world
    
    // MARK: - Data
    /// World model used to populate continent picker.
    private let world: World
    
    // MARK: - Init
    init(world: World, initialConfig: StudyConfiguration) {
        self.world = world
        self.selectedModeindex = initialConfig.mode.rawValue
        self.initialRegion = initialConfig.region
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationTitle()
        
        setupNavigationBar()
        setupContinentPicker()
        setupStudyMode()
        
        // Restore previously selected values
        studyModeSegmentedControl.selectedSegmentIndex = selectedModeindex
        selectRegion(initialRegion)
        
        view.backgroundColor = .systemBackground
        setColors()
    }
}

//MARK: - Setup UI
extension StudyModeViewController {
    
    // MARK: - Navigation Bar
    /// Configures title and Done button.
    private func setupNavigationBar() {
        title = "Study Mode Selection"
        
        // Done button (confirm selection)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }
    
    // MARK: - Study Mode Segmented Control
    /// Creates and positions segmented control for Learning / Testing.
    func setupStudyMode() {
        studyModeSegmentedControl = UISegmentedControl(items: ["Learning", "Testing"])
        studyModeSegmentedControl.selectedSegmentIndex = 0
        studyModeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        studyModeSegmentedControl.addTarget(self, action: #selector(studyModeChanged), for: .valueChanged)
        
        view.addSubview(studyModeSegmentedControl)
        
        let b: CGFloat = 20.scaled
        let w: CGFloat = 200.scaled
        NSLayoutConstraint.activate([
            studyModeSegmentedControl.bottomAnchor.constraint(equalTo: glassView.topAnchor, constant: -b),
            studyModeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            studyModeSegmentedControl.widthAnchor.constraint(equalToConstant: w)
        ])
        
        setColors()
    }
    
    // MARK: - Continent Picker
    /// Creates glass-style container and embeds continent picker inside.
    func setupContinentPicker() {
        glassView = UIView()
        glassView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        glassView.layer.cornerRadius = 20.scaled
        glassView.layer.borderWidth = 1
        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        glassView.layer.shadowColor = UIColor.black.cgColor
        glassView.layer.shadowOpacity = 0.2
        glassView.layer.shadowRadius = 20.scaled
        glassView.layer.shadowOffset = .zero
        glassView.translatesAutoresizingMaskIntoConstraints = false
        
        // Sort continents alphabetically and prepend "World"
        var sortedContinents = world.continents.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        sortedContinents.insert(Continent(name: "World", countries: []), at: 0)
        
        continentPicker = ContinentPickerView(continents: sortedContinents)
        continentPicker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(glassView)
        glassView.addSubview(continentPicker)
        
        let b: CGFloat = 12.scaled
        let c: CGFloat = 8.scaled
        NSLayoutConstraint.activate([
            glassView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -b),
            glassView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glassView.heightAnchor.constraint(equalToConstant: 160.scaled),
            glassView.widthAnchor.constraint(equalToConstant: 300.scaled),
            
            // Picker inside the glass
            continentPicker.topAnchor.constraint(equalTo: glassView.topAnchor, constant: c),
            continentPicker.bottomAnchor.constraint(equalTo: glassView.bottomAnchor, constant: -c),
            continentPicker.leadingAnchor.constraint(equalTo: glassView.leadingAnchor),
            continentPicker.trailingAnchor.constraint(equalTo: glassView.trailingAnchor)
        ])
    }
}

//MARK: - Actions
extension StudyModeViewController {
    
    // MARK: - Done Button
    /// Confirms selection and sends chosen Region + StudyMode back.
    @objc private func doneTapped() {
        let continent = continentPicker.selectedName
        let index = studyModeSegmentedControl.selectedSegmentIndex
        
        let region: Region = (continent == "World") ? .world : .continent(continent)
        let mode: StudyMode = (index == 0) ? .learning : .testing
        
        selectedModeindex = index
        initialRegion = region
        
        onSelectionConfirmed?(region, mode)
        dismiss(animated: true)
    }
    
    // MARK: - Study Mode Changed
    /// Updates colors when segmented control value changes.
    @objc func studyModeChanged() {
        setColors()
    }
    
    // MARK: - Appearance
    /// Updates segmented control colors based on selected mode.
    func setColors() {
        let currentIndex = studyModeSegmentedControl.selectedSegmentIndex
        let size: CGFloat = 16.scaled
        let inactiveColor = UIColor.secondaryLabel
        let activeColor: UIColor = currentIndex == 0 ? .merchantMarine : .coolRed
        let inactiveFont = UIFont.systemFont(ofSize: size, weight: .medium)
        let activeFont = UIFont.systemFont(ofSize: size, weight: .medium)
        
        studyModeSegmentedControl.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: inactiveFont], for: .normal)
        studyModeSegmentedControl.setTitleTextAttributes([.foregroundColor: activeColor, .font: activeFont], for: .selected)
    }
    
    // MARK: - Restore Selection
    /// Selects picker row based on previously saved region.
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

// MARK: - Navigation Title Appearance
extension StudyModeViewController {
    
    /// Configures navigation bar title font and color.
    private func configureNavigationTitle() {
        let appearance = UINavigationBarAppearance()
        //appearance.configureWithOpaqueBackground()
        // appearance.backgroundColor = .systemBackground
        
        appearance.titleTextAttributes = [
            .font: UIFont.rounded(ofSize: 18.scaled, weight: .medium),
            .foregroundColor: UIColor.label
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
}

