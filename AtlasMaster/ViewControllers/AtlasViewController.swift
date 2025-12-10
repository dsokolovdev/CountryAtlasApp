
//
//  ViewController.swift
//  AtlasMaster
//
//  Created by Dmitri  on 06.12.25.
//

import UIKit

final class AtlasViewController: UIViewController, UICollectionViewDelegate {
    
    private let atlasModel: AtlasModel
    private var collectionView: UICollectionView!
    //var onSegmentChanged: ((Int) -> Int)
    
    private var settingsButton: UIBarButtonItem!
    private var modeButton: UIBarButtonItem!
    private var studyProgressSegmentedControl: UISegmentedControl!

    init(model: AtlasModel) {
        self.atlasModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = false
        
        //Load saved studyConfigs: region, mode
        atlasModel.loadUserConfiguration()
        atlasModel.loadEntireWorlddData()
        
        setupnavigationBar()
        setupBottomBar()
        //setupNavigationBarSegmentedControl()
        setupCollectionView()
        
        atlasModel.onWorldUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                //self?.applyLearningFilter()
            }
        }
        
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
    //MARK: - Setup SegmentedControl
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
    
    //MARK: - Setup CollectionView
    func setupCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(140))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(140))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 6
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 40, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        
        //header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
       // let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
       // let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottomTrailing)
        
        section.boundarySupplementaryItems = [header]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        //layout.configuration.interSectionSpacing = 40
        
        return layout
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(CountryCell.self, forCellWithReuseIdentifier: CountryCell.reusedId)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseId)
        collectionView.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterView.reuseId)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
//    func setupBottomBar() {
//        studyProgressSegmentedControl = UISegmentedControl()
//        let toLearnSegment = UIImage(systemName: "lightbulb",  withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
//        let learnedSegment = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
//
//        studyProgressSegmentedControl = UISegmentedControl(items: [toLearnSegment!, learnedSegment!])
//        
//        studyProgressSegmentedControl.subviews.forEach {
//            $0.backgroundColor = .white
//        }
////        studyProgressSegmentedControl.setWidth(70, forSegmentAt: 0)
////        studyProgressSegmentedControl.setWidth(70, forSegmentAt: 1)
//        studyProgressSegmentedControl.selectedSegmentTintColor = .systemGroupedBackground
//        studyProgressSegmentedControl.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth]
//    
//        studyProgressSegmentedControl.addTarget(self, action: #selector(progressModeChanged), for: .valueChanged)
//        
//        studyProgressSegmentedControl.selectedSegmentIndex = 0
//        studyProgressSegmentedControl.widthAnchor.constraint(equalToConstant: 140).isActive = true
//        studyProgressSegmentedControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        
//        let segmentsItem = UIBarButtonItem(customView: studyProgressSegmentedControl)
//        //segmentsItem.customView?.backgroundColor = .clear
//        
//        let searchButtton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
//        let space = UIBarButtonItem.flexibleSpace()
//        
//        
//        toolbarItems = [segmentsItem, space, searchButtton]
//        
//        updateProgressSgControlColors()
//    }
    
    func setupBottomBar() {
        let toLearn = UIImage(systemName: "lightbulb", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        let learned = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        let progress = UIImage(systemName: "percent", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))

        studyProgressSegmentedControl = UISegmentedControl(items: [toLearn!, learned!, progress!])
//        studyProgressSegmentedControl.insertSegment(with: toLearn!, at: 0, animated: false)
//        studyProgressSegmentedControl.insertSegment(with: learned!, at: 1, animated: false)
        studyProgressSegmentedControl.selectedSegmentIndex = 0
        studyProgressSegmentedControl.addTarget(self, action: #selector(progressModeChanged), for: .valueChanged)
        //studyProgressSegmentedControl.selectedSegmentTintColor = .systemGray5
        studyProgressSegmentedControl.subviews.forEach {
            $0.backgroundColor = .systemBackground
        }
        //studyProgressSegmentedControl.selectedSegmentTintColor = .clear

        // --- ВАЖНО: контейнер с фиксированной шириной ---
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(studyProgressSegmentedControl)
        container.backgroundColor = .clear
        container.layer.cornerRadius = 22 * scaleFactor

        studyProgressSegmentedControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 210), // 👈 Увеличиваешь как хочешь
            container.heightAnchor.constraint(equalToConstant: 44),
            studyProgressSegmentedControl.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            studyProgressSegmentedControl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            studyProgressSegmentedControl.topAnchor.constraint(equalTo: container.topAnchor),
            studyProgressSegmentedControl.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let segmentsItem = UIBarButtonItem(customView: container)
        //segmentsItem.customView?.backgroundColor = .clear

        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchTapped)
        )

        toolbarItems = [
            segmentsItem,
            UIBarButtonItem.flexibleSpace(),
            searchButton
        ]
        updateProgressSgControlColors()
        
    }
    
//    func setupCollectionView() {
//              let layout = UICollectionViewFlowLayout()
//              layout.minimumLineSpacing = 8
//              layout.itemSize = CGSize(width: view.bounds.width, height: 100)
//
//              collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//              collectionView.translatesAutoresizingMaskIntoConstraints = false
//              collectionView.backgroundColor = .systemBackground
//
//              collectionView.dataSource = self
//              collectionView.delegate = self
//
//              collectionView.register(CountryCell.self, forCellWithReuseIdentifier: "CountryCell")
//
//              view.addSubview(collectionView)
//
//              NSLayoutConstraint.activate([
//                  collectionView.topAnchor.constraint(equalTo: view.topAnchor),
//                  collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                  collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                  collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//              ])
//          }
    
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
            self?.atlasModel.saveUserConfiguratin(self?.atlasModel.currentConfig ?? StudyConfiguration(mode: .learning, region: .world))
            self?.collectionView.reloadData()
        }
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [ .custom { _ in return 300 } ]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
    
//    func applyStudyModeFilter(_ region: Region) {
////        let continentName: String
////        
////        switch region {
////        case .continent(let name): continentName = name
////        case .world : continentName = "World"
////        }
////        
////        if continentName == "World" {
////            filteredContinents = filteredContinents.map {
////                var c = $0
////                c.isSelected = true
////                return c
////            }
////        } else {
////            filteredContinents = filteredContinents.map {
////                var c = $0
////                c.name == continentName ? (c.isSelected = true) : (c.isSelected = false)
////                return c
////            }
////        }
////        
////        applyLearningFilter()
//    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        print("Selected segment index: \(selectedIndex)")
        // Perform actions based on the selected segment
    }
    
    @objc func progressModeChanged(_ sender: UISegmentedControl) {
        atlasModel.updateFilterMode(sender.selectedSegmentIndex)
        collectionView.reloadData()
    }
    
    
    @objc func searchTapped() {
        print("Search tapped")
    }
    
    
    private func updateUIForConfig() {
        modeButton.image = atlasModel.currentConfig.mode == .learning ? UIImage(systemName: "book") : UIImage(systemName: "person.fill.questionmark")
        modeButton.tintColor = atlasModel.currentConfig.mode == .learning ? .systemBlue : .systemRed
        switch atlasModel.currentConfig.mode {
        case .learning:
            // включаем «подсказки», без счёта
            break
        case .testing:
            // включаем «вопрос/ответ», считаем ошибки
            break
        }
    }
    
    func updateProgressSgControlColors() {
        let index = studyProgressSegmentedControl.selectedSegmentIndex
        let activeToLearnColor = UIColor.systemYellow
        let activeLearnedColor = UIColor.systemGreen
        let activeProgressColor = UIColor.systemBrown
        let activeColor = (index == 0) ? activeToLearnColor : (index == 1 ? activeLearnedColor : activeProgressColor)
        let inactiveColor = UIColor.tertiaryLabel
        let size: CGFloat = 16 * scaleFactor
        let activeFont = UIFont.systemFont(ofSize: size, weight: .bold)
        let inactiveFont = UIFont.systemFont(ofSize: size, weight: .semibold)
        
        studyProgressSegmentedControl.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: inactiveFont], for: .normal)
        studyProgressSegmentedControl.setTitleTextAttributes([.foregroundColor: activeColor, .font: activeFont], for: .selected)
    }
    
//    func applyLearningFilter() {
//   //        guard let world = atlasModel.world else { return }
//   //
//   //        let showLearned = studyProgressSegmentedControl.selectedSegmentIndex == 1
//   //
//   //        filteredContinents = world.continents.filter{ $0.isSelected }.map { continent in
//   //            let filteredCountries = continent.countries.filter { $0.isLearned == showLearned }
//   //            return Continent(name: continent.name, countries: filteredCountries)
//   //        }
//   //        //atlasModel.updateWorldContinents(filteredContinents)
//           collectionView.reloadData()
//       }
}
//MARK: - CollectionView Delegate
extension AtlasViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return atlasModel.currentWorld?.continents.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // let countries = atlasModel.world?.continents.flatMap { $0.countries }.count ?? 0
        let countries = atlasModel.currentWorld?.continents[section].countries.count ?? 0
        return countries

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountryCell", for: indexPath) as! CountryCell
        
        //let allCountries = atlasModel.currentWorld?.continents.flatMap { $0.countries } ?? []
        let continents = atlasModel.currentWorld?.continents[indexPath.section]
        let country = continents?.countries[indexPath.item]
        
        
        cell.configure(index: indexPath.item + 1, flag: country?.flag ?? "" , name: country?.name ?? "" , capital: country?.capital ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionName = atlasModel.currentWorld?.continents[indexPath.section].name ?? "Unknown"
        let count = atlasModel.currentWorld?.continents[indexPath.section].countries.count ?? 0

        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseId, for: indexPath) as! HeaderView
            header.titleLabel.text = sectionName
            header.countLabel.text = "Countries: \(count)"
            return header
        }
        
        
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FooterView.reuseId, for: indexPath) as! FooterView
            footer.configure(count: count)
            return footer
        }
        
        
        fatalError("Unexpected supplementary kind: \(kind)")
    }
    
    
}
