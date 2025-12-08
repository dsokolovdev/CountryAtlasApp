//
//  ViewController.swift
//  AtlasMaster
//
//  Created by Dmitri  on 06.12.25.
//

import UIKit

final class AtlasViewController: UIViewController {
    
    private let atlasModel: AtlasModel
    
    private var settingsButton: UIBarButtonItem!
    private var modeButton: UIBarButtonItem!

    init(model: AtlasModel) {
        self.atlasModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load saved studyConfigs: region, mode
        if let savedConfig = atlasModel.dataStore.loadUserConfig() {
            atlasModel.currentConfig = savedConfig
        }
        if let savedWorld = atlasModel.dataStore.loadWorldData() {
            atlasModel.world = savedWorld
        } else {
            atlasModel.loadCountriesFromAPI()
        }
        
        setupnavigationBar()
        setupNavigationBarSegmentedControl()
        
        title = "AtlasMaster"
        view.backgroundColor = .systemBackground
        view.preservesSuperviewLayoutMargins = true
        
        let constant: CGFloat = 16 * scaleFactor
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: constant,
            bottom: 0,
            trailing: constant
        )
    }
}

//MARK: - Setup UI
extension AtlasViewController {
    
    func setupNavigationBarSegmentedControl() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 22 * scaleFactor
        
        let activeColor = UIColor.label
        let inactiveColor = UIColor.tertiaryLabel
        let size: CGFloat = 16 * scaleFactor
        let activeFont = UIFont.systemFont(ofSize: size, weight: .medium)
        let inactiveFont = UIFont.systemFont(ofSize: size, weight: .regular)
        
        let items = ["Info", "Map"]
        let segmentedControl = UISegmentedControl(items: items)
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.widthAnchor.constraint(equalToConstant: 140).isActive = true
        segmentedControl.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: inactiveFont], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: activeColor, .font: activeFont], for: .selected)
        segmentedControl.subviews.forEach { $0.backgroundColor = .systemBackground }
        
        // Add a target to handle segment changes
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        //view.addSubview(segmentedControl)
        //navigationItem.titleView = view
        
        //        NSLayoutConstraint.activate([
        //            view.widthAnchor.constraint(equalToConstant: 140),
        //            segmentedControl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        //            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        //            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        //
        //        ])
        
        // Set the segmented control as the titleView of the navigation item
        navigationItem.titleView = segmentedControl
    }
    
    func setupnavigationBar(){
        settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        modeButton = UIBarButtonItem(image: UIImage(systemName: "book"), style: .plain, target: self, action: #selector(modeButtonTapped))
        //        let continentLabel = UILabel()
        //        continentLabel.text = "Continent"
        //        continentLabel.textAlignment = .center
        //        let stackView = UIStackView(arrangedSubviews: [continentLabel])
        //        stackView.alignment = .center
        //        stackView.axis = .horizontal
        //        stackView.spacing = 8
        //        navigationItem.titleView = stackView
        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItem = modeButton
    }
    
}

//MARK: - Actions
extension AtlasViewController {
    
    @objc func settingsButtonTapped(){
        
    }
    
    //    @objc func modeButtonTapped(){
    //        let vc = ModeViewController()
    //        vc.modalPresentationStyle = .pageSheet
    //        present(vc, animated: true)
    //    }
    
    @objc func modeButtonTapped() {
        guard let world = atlasModel.world else { return }
        
        //Add "World" first menu item into picker
        var extended = world.continents
        extended.insert(Continent(name: "World", countries: []), at: 0)
        
        let vc = StudyModeViewController(world: world, initialConfig: atlasModel.currentConfig)
        let nav = UINavigationController(rootViewController: vc)
        
        vc.selectedModeindex = atlasModel.currentConfig.mode.rawValue
        vc.initialRegion = atlasModel.currentConfig.region
        
        vc.onSelectionConfirmed = { [weak self] region, mode in
            self?.atlasModel.currentConfig.region = region
            self?.atlasModel.currentConfig.mode = mode
            self?.updateUIForConfig()
            self?.atlasModel.dataStore.saveUserConfig(self?.atlasModel.currentConfig ?? StudyConfiguration(mode: .learning, region: .world))
        }
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [ .custom { _ in return 300 } ]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        print("Selected segment index: \(selectedIndex)")
        // Perform actions based on the selected segment
    }
    
    
    private func updateUIForConfig() {
        modeButton.image = atlasModel.currentConfig.mode == .learning ? UIImage(systemName: "book") : UIImage(systemName: "person.fill.questionmark")
        switch atlasModel.currentConfig.mode {
        case .learning:
            // включаем «подсказки», без счёта
            break
        case .testing:
            // включаем «вопрос/ответ», считаем ошибки
            break
        }
    }
}
