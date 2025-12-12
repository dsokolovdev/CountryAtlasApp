
//
//  ViewController.swift
//  AtlasMaster
//
//  Created by Dmitri  on 06.12.25.
//

import UIKit

final class AtlasViewController: UIViewController, UICollectionViewDelegate {
    
    enum  DisplayMode {
        case list   //segments 0, 1
        case stats  //segments 2
    }
    private var displayMode: DisplayMode = .list
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
        
        applyLayoutForCurrentMode()
        
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
    func makeListLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)

        config.showsSeparators = false
        config.headerMode = .supplementary
        //config.footerMode = .supplementary
        
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            guard self.atlasModel.filterMode == 0 else { return nil }
            
            // зелёная кнопка "Learned"
            let learnedAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                
                self.atlasModel.markCountryAsLearned(at: indexPath)
                self.collectionView.reloadData()
                
                completion(true)
            }

            learnedAction.backgroundColor = .systemGreen
            learnedAction.image = UIImage(systemName: "checkmark")
            
            let swipeConfiguration = UISwipeActionsConfiguration(actions: [learnedAction])
            //swipeConfiguration.performsFirstActionWithFullSwipe = false
            
            return swipeConfiguration
            
        }
        
        config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            guard self.atlasModel.filterMode == 1 else { return nil }
            // зелёная кнопка "Learned"
            let unlearnedAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                
                self.atlasModel.markCountryAsLearned(at: indexPath)
                self.collectionView.reloadData()

                completion(true)
            }
            
            
            unlearnedAction.backgroundColor = .systemYellow
            unlearnedAction.image = UIImage(systemName: "lightbulb")
            
            let swipeConfiguration = UISwipeActionsConfiguration(actions: [unlearnedAction])
            //swipeConfiguration.performsFirstActionWithFullSwipe = false
            
            return swipeConfiguration
            
        }
        
        let layout  = UICollectionViewCompositionalLayout.list(using: config)

        return layout
    }
    
    func makeStatsLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        header.pinToVisibleBounds = false
        
        //header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(32))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        
        section.boundarySupplementaryItems = [header, footer]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        //layout.configuration.interSectionSpacing = 40
        
        return layout
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeListLayout())
        //collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeStatsViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        
        collectionView.register(CountryCell.self, forCellWithReuseIdentifier: CountryCell.reusedId)
        collectionView.register(StatsCell.self, forCellWithReuseIdentifier: StatsCell.reusedId)
        collectionView.register(ContinentHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ContinentHeader.reuseId)
        collectionView.register(ContinentFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ContinentFooter.reuseId)
        collectionView.register(StatsHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: StatsHeader.reusedId)
        collectionView.register(StatsFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: StatsFooter.reusedId)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func applyLayoutForCurrentMode() {
        let layout: UICollectionViewLayout

        switch displayMode {
        case .list:
            layout = makeListLayout()
        case .stats:
            layout = makeStatsLayout()
        }

        collectionView.setCollectionViewLayout(layout, animated: false)
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
        updateSegmentsColors()
        
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
        switch sender.selectedSegmentIndex {
        case 0, 1:
            displayMode = .list
            atlasModel.updateFilterMode(sender.selectedSegmentIndex)
        case 2:
            displayMode = .stats
            //atlasModel.updateFilterMode(sender.selectedSegmentIndex)
        default:
            break
        }
        
        applyLayoutForCurrentMode()
        collectionView.reloadData()
        updateSegmentsColors()
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
    
    func updateSegmentsColors() {
        let index = studyProgressSegmentedControl.selectedSegmentIndex
        let activeToLearnColor = UIColor.systemYellow
        let activeLearnedColor = UIColor.systemGreen
        let activeProgressColor = UIColor.systemBlue
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
        if displayMode == .list {
            return atlasModel.filteredWorld().continents.count
        } else {
            return atlasModel.getStatistics().count
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if displayMode == .list {
            return atlasModel.filteredWorld().continents[section].countries.count
        } else {
            return 1 //only stats cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if displayMode == .list {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CountryCell.reusedId, for: indexPath) as! CountryCell
            let continents = atlasModel.filteredWorld().continents[indexPath.section]
            let country = continents.countries[indexPath.item]
            cell.configure(index: indexPath.item + 1, flag: country.flag, name: country.name, capital: country.capital)
            return cell
        } else {
            let stats = atlasModel.getStatistics()[indexPath.section]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatsCell.reusedId, for: indexPath) as! StatsCell
            cell.configure(with: stats)
            return cell
        }
    }
    
    //Header, Footer
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if displayMode == .list {
            let sectionName = atlasModel.filteredWorld().continents[indexPath.section].name
            let totalCount = atlasModel.getTotal(for: indexPath)
            let currentCount = atlasModel.getCurrentCount(for: indexPath)
            
            
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ContinentHeader.reuseId, for: indexPath) as! ContinentHeader
                header.titleLabel.text = sectionName
                //header.countLabel.text = "(\(currentCount)"
                //header.totalLabel.text = "\(totalCount))"
                return header
            }
            
            
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ContinentFooter.reuseId, for: indexPath) as! ContinentFooter
                footer.configure(count: totalCount - currentCount)
                return footer
            }
        } else {
            let continent = atlasModel.getStatistics()[indexPath.section]
            let sectionName = continent.name
            let totalCount = continent.total
            let learnedCount = continent.learned
            let leftCount = continent.toLearn
            let learnedProgress = continent.learnedProgress
            
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: StatsHeader.reusedId, for: indexPath) as! StatsHeader
                header.configure(name: sectionName, progress: learnedProgress)
                return header
            }
            
            
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: StatsFooter.reusedId, for: indexPath) as! StatsFooter
                footer.configure(total: totalCount, learned: learnedCount, toLearn: leftCount)
                return footer
            }
        }
        
        fatalError("Unexpected supplementary kind: \(kind)")
    }
}

//MARK: - CollectionView Swipes
extension AtlasViewController {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint ) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let learned = UIAction(
                title: "Learned",
                image: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal),
                identifier: nil,
                discoverabilityTitle: nil,
                handler: { _ in
                    print("Learned tapped at \(indexPath)")
                }
            )

            let unlearned = UIAction(
                title: "Unlearned",
                image: UIImage(systemName: "lightbulb.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal),
                identifier: nil,
                discoverabilityTitle: nil,
                handler: { _ in
                    print("Unlearned tapped at \(indexPath)")
                }
            )

            return UIMenu(title: "", children: [learned, unlearned])
        }
    }
}

// MARK: - Swipe Actions
//extension AtlasViewController {
//
//    // свайп СЛЕВА → (обычно "Mark as learned")
//    func collectionView(_ collectionView: UICollectionView, leadingSwipeActionsConfigurationForItemAt indexPath: IndexPath ) -> UISwipeActionsConfiguration? {
//
//        // зелёная кнопка "Learned"
//        let learnedAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
//            print("Swipe LEFT → Learned on section \(indexPath.section), item \(indexPath.item)")
//            completion(true)
//        }
//
//        learnedAction.backgroundColor = .systemGreen
//        learnedAction.image = UIImage(systemName: "checkmark") // зелёная галочка автоматически будет белой внутри
//
//        return UISwipeActionsConfiguration(actions: [learnedAction])
//    }
//
//    // свайп СПРАВА ← (обычно "Unlearn")
//    func collectionView(_ collectionView: UICollectionView, trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath ) -> UISwipeActionsConfiguration? {
//
//        let unlearnAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
//            print("Swipe RIGHT → Unlearn on section \(indexPath.section), item \(indexPath.item)")
//            completion(true)
//        }
//
//        unlearnAction.backgroundColor = .systemYellow
//        unlearnAction.image = UIImage(systemName: "lightbulb")
//
//        return UISwipeActionsConfiguration(actions: [unlearnAction])
//    }
//}


//extension AtlasViewController {
//    func collectionView(_ collectionView: UICollectionView, trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let learned = UIContextualAction(style: .normal, title: nil) { _, _, done in
//            print("Learned tapped")
//            done(true)
//        }
//        learned.image = UIImage(systemName: "checkmark")
//        learned.backgroundColor = .systemGreen
//
//        return UISwipeActionsConfiguration(actions: [learned])
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, leadingSwipeActionsConfigurationForItemAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let unlearn = UIContextualAction(style: .normal, title: nil) { _, _, done in
//            print("Unlearn tapped")
//            done(true)
//        }
//        unlearn.image = UIImage(systemName: "lightbulb")
//        unlearn.backgroundColor = .systemYellow
//
//        return UISwipeActionsConfiguration(actions: [unlearn])
//    }
//}


//extension AtlasViewController {
//    func setupCollectionView_() {
//           // 1. Create a list configuration
//           var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
//           
//           // 2. Define the trailing swipe actions provider
//           layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
//               guard let self = self else { return nil }
//               
//               // Create a delete action
//               let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
//                   self?.handleDelete(at: indexPath)
//                   completionHandler(true) // Indicate that the action was performed
//               }
//               deleteAction.image = UIImage(systemName: "trash") // Optional: Add a system icon
//               
//               // Create a configuration with the actions
//               let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
//               // Optional: Prevent full swipe from automatically performing the first action
//               swipeConfiguration.performsFirstActionWithFullSwipe = false
//               
//               return swipeConfiguration
//           }
//           
//           // 3. Define the leading swipe actions provider (optional)
//           layoutConfig.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
//               guard let self = self else { return nil }
//
//               let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { [weak self] (action, sourceView, completionHandler) in
//                   self?.handleFavorite(at: indexPath)
//                   completionHandler(true)
//               }
//               favoriteAction.backgroundColor = .systemYellow
//               favoriteAction.image = UIImage(systemName: "star")
//
//               return UISwipeActionsConfiguration(actions: [favoriteAction])
//           }
//
//           // 4. Create the compositional layout
//        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)  //layoutWithListConfiguration(layoutConfig)
//           
//           // 5. Initialize the collection view with the layout
//           collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
//           collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//           collectionView.delegate = self
//           view.addSubview(collectionView)
//           
//           // ... set up data source and register your custom cell
//       }
//       
//       // ... data source methods (cellForItemAt, etc.)
//       
//       func handleDelete(at indexPath: IndexPath) {
//           // Implement your data deletion logic here
//           print("Deleting item at index path: \(indexPath)")
//           // Update your data source, then apply changes to the collection view
//       }
//       
//       func handleFavorite(at indexPath: IndexPath) {
//           // Implement your favorite logic here
//           print("Favoriting item at index path: \(indexPath)")
//           // Update your data source
//       }
//   
//
//}
