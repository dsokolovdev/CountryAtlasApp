//
//  ViewController.swift
//  AtlasMaster
//
//  Created by Dmitri  on 06.12.25.
//

import UIKit

class AtlasViewController: UIViewController {
    private var settingsButton: UIBarButtonItem!
    private var modeButton: UIBarButtonItem!
    private var currentConfig = StudyConfiguration(mode: .learning, region: .world)
    private var world: World?
    
    let service = CountryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCountries()
        
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

extension AtlasViewController {
    func loadCountries() {
        service.fetchAllCountries { apiCountries in
            let world = self.service.buildAtlas(from: apiCountries)
            self.world = world
            
            for (index,continent) in world.continents.enumerated() {
                print("******", index + 1, continent.name)
                for ((index),country) in continent.countries.enumerated() {
                    print("\(index + 1): \(country.name) - \(country.capital)")
                }
            }
        }
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
        guard let world = world else {
            // страны ещё не загрузились — можно показать alert или просто return
            return
        }
        
        let vc = StudyModeViewController(world: world, initialConfig: currentConfig)
        let nav = UINavigationController(rootViewController: vc)
        
        vc.selectedModeindex = currentConfig.mode.rawValue
        vc.initialRegion = currentConfig.region
        
        vc.onSelectionConfirmed = { [weak self] region, mode in
            self?.currentConfig.region = region
            self?.currentConfig.mode = mode
            self?.updateUIForConfig()
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
        modeButton.image = currentConfig.mode == .learning ? UIImage(systemName: "book") : UIImage(systemName: "person.fill.questionmark")
        switch currentConfig.mode {
        case .learning:
            // включаем «подсказки», без счёта
            break
        case .testing:
            // включаем «вопрос/ответ», считаем ошибки
            break
        }
    }
    
//    //Get selected continent name
//    func currentContinentName() -> String? {
//        switch currentConfig.region {
//        case .world: return nil
//        case .continent(let name): return name
//        }
//    }

}

