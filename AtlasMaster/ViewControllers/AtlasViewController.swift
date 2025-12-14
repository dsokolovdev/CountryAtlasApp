
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
    private var lightHaptic: UIImpactFeedbackGenerator!
    private var displayMode: DisplayMode = .list
    private let atlasModel: AtlasModel
    private var collectionView: UICollectionView!
    //var onSegmentChanged: ((Int) -> Int)
    
    private var settingsButton: UIBarButtonItem!
    private var resetButton: UIBarButtonItem!
    private var modeButton: UIBarButtonItem!
    private var testAspectButton: UIBarButtonItem!
    private var studyProgressSegmentedControl: UISegmentedControl!
    private var bottomControl: BottomControlBar!
    private var bottomControlStack: UIStackView!
    
    //Snapshots of Data
    private var snapshotWorld = World()
    private var snapshotStats: [ContinentStats] = []
    
    private var bottomControlWidthConstraint: NSLayoutConstraint!

    init(model: AtlasModel) {
        self.atlasModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = true
        configureNavigationTitle()
        
        
        //Load saved studyConfigs: region, mode
        atlasModel.loadUserConfiguration()
        atlasModel.loadEntireWorlddData()
        
        setupnavigationBar()
        setupRightButtonItems()
        //setupBottomBar()
        //setupNavigationBarSegmentedControl()
        setupCollectionView()
        setupBottomControlBar()
        bindBottomControlBar()
        
        applyLayoutForCurrentMode()
        
        atlasModel.onWorldUpdated = { [weak self] in
            DispatchQueue.main.async {
                //self?.collectionView.reloadData()
                //self?.applyLearningFilter()
                self?.reloadSnapshot()
            }
        }
        reloadSnapshot()
        
        updateUIForConfig()
        setResetButtonState()
        
        
        //title = "AtlasMaster"
        view.backgroundColor = .systemBackground
        view.preservesSuperviewLayoutMargins = true
        
        let constant: CGFloat = 16 * scaleFactor
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: constant,
            bottom: 0,
            trailing: constant
        )
        
        if #available(iOS 17.5, *) {
            lightHaptic = UIImpactFeedbackGenerator(style: .light, view: view)
        } else {
            // Fallback for earlier iOS versions (no view-based initializer available).
            lightHaptic = UIImpactFeedbackGenerator(style: .light)
        }
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
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        resetButton = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise", withConfiguration: config), style: .plain, target: self, action: #selector(resetButtonTapped))
        modeButton = UIBarButtonItem(image: UIImage(systemName: "book.fill"), style: .plain, target: self, action: #selector(modeButtonTapped))
        testAspectButton = UIBarButtonItem(image: UIImage(systemName: atlasModel.testingAspect.iconName), menu: makeMenu())
        
        
        
        //        let continentLabel = UILabel()
        //        continentLabel.text = "Continent"
        //        continentLabel.textAlignment = .center
        //        let stackView = UIStackView(arrangedSubviews: [continentLabel])
        //        stackView.alignment = .center
        //        stackView.axis = .horizontal
        //        stackView.spacing = 8
        //        navigationItem.titleView = stackView
        
        navigationItem.leftBarButtonItems = [settingsButton, space, resetButton]
        navigationItem.rightBarButtonItems = [ modeButton]
        settingsButton.tintColor = AppColors.greyblue
        resetButton.tintColor = AppColors.greyblue
        testAspectButton.tintColor = AppColors.nasauurple
    }
    
    func setupRightButtonItems() {
        let rightItems: [UIBarButtonItem] = atlasModel.currentConfig.mode ==  .learning ? [ modeButton] : [modeButton, testAspectButton]
        navigationItem.rightBarButtonItems = rightItems
    }
    
    func makeMenu() -> UIMenu {
        let activeColor = AppColors.nasauurple
        let inactiveColor = AppColors.greyblue.withAlphaComponent(0.7)
        
        let capitalImage = UIImage(systemName: "building.2.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [atlasModel.testingAspect == .capital ? activeColor : inactiveColor]))
        let countryImage = UIImage(systemName: "globe.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [atlasModel.testingAspect == .country ? activeColor : inactiveColor]))
        let flagImage = UIImage(systemName: "flag.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [atlasModel.testingAspect == .flag ? activeColor : inactiveColor]))
        
        
        let capitalAction = UIAction(title: "Capitals", image: capitalImage, state: atlasModel.testingAspect == .capital ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.atlasModel.testingAspect = .capital
            self.testAspectButton.image = UIImage(systemName: atlasModel.testingAspect.iconName)
            self.testAspectButton.menu = self.makeMenu()
        }
        
        let countryAction = UIAction(title: "Countries", image: countryImage, state: atlasModel.testingAspect == .country ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.atlasModel.testingAspect = .country
            self.testAspectButton.image = UIImage(systemName: atlasModel.testingAspect.iconName)
            self.testAspectButton.menu = self.makeMenu()
        }
        let flagAction = UIAction(title: "Flags", image: flagImage, state: atlasModel.testingAspect == .flag ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.atlasModel.testingAspect = .flag
            self.testAspectButton.image = UIImage(systemName: atlasModel.testingAspect.iconName)
            self.testAspectButton.menu = self.makeMenu()
        }
        
        func attributedTitle(_ text: String, isActive: Bool) -> NSAttributedString {
            NSAttributedString(string: text, attributes: [.foregroundColor: isActive ? activeColor : inactiveColor])
        }
        
        capitalAction.setValue(attributedTitle("Capitals", isActive: atlasModel.testingAspect == .capital), forKey: "attributedTitle")
        countryAction.setValue(attributedTitle("Countries", isActive: atlasModel.testingAspect == .country), forKey: "attributedTitle")
        flagAction.setValue(attributedTitle("Flags", isActive: atlasModel.testingAspect == .flag), forKey: "attributedTitle")
        
        return UIMenu(title: "Testing Items", children: [capitalAction, countryAction, flagAction])
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
                //self.collectionView.reloadData()
                self.reloadSnapshot()
                self.setResetButtonState()
                
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
            
            //желтая кнопка "UnLearned"
            let unlearnedAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                
                self.atlasModel.markCountryAsLearned(at: indexPath)
                self.reloadSnapshot()
                //self.collectionView.reloadData()
                self.setResetButtonState()

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
    
    
    
    
    func setupBottomControlBar() {
        bottomControl = BottomControlBar()

        let searchButton = UIButton(type: .system)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        searchButton.setImage(image, for: .normal)
        searchButton.tintColor = .label
        searchButton.backgroundColor = .systemBackground
        searchButton.layer.cornerRadius = 28
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.layer.shadowColor = UIColor.label.cgColor
        searchButton.layer.shadowOpacity = 0.15
        searchButton.layer.shadowRadius = 6
        searchButton.layer.shadowOffset = CGSize(width: 0, height: 2.5)
        searchButton.layer.masksToBounds = false
        searchButton.tintColor = AppColors.greyblue

        NSLayoutConstraint.activate([
            searchButton.widthAnchor.constraint(equalToConstant: 56),
            searchButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        bottomControlStack = UIStackView(arrangedSubviews: [bottomControl, searchButton])
        bottomControlStack.axis = .horizontal
        bottomControlStack.alignment = .center
        bottomControlStack.spacing = 16
        bottomControlStack.distribution = .equalSpacing   // ✅
        bottomControlStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(bottomControlStack)
        
        bottomControlWidthConstraint = bottomControl.widthAnchor.constraint(equalToConstant: bottomControl.preferredWidth)

        NSLayoutConstraint.activate([
            bottomControlStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 12),
            bottomControlStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -12),
            bottomControlStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            //bottomControlStack.heightAnchor.constraint(equalToConstant: 55),

            bottomControlWidthConstraint,
            bottomControl.heightAnchor.constraint(equalToConstant: 56) //
        ])
    }
    
    
//    func setupBottomBar() {
//        let toLearn = UIImage(systemName: "lightbulb", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
//        let learned = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
//        let progress = UIImage(systemName: "percent", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
//
//        studyProgressSegmentedControl = UISegmentedControl(items: [toLearn!, learned!, progress!])
////        studyProgressSegmentedControl.insertSegment(with: toLearn!, at: 0, animated: false)
////        studyProgressSegmentedControl.insertSegment(with: learned!, at: 1, animated: false)
//        studyProgressSegmentedControl.selectedSegmentIndex = 0
//        studyProgressSegmentedControl.addTarget(self, action: #selector(progressModeChanged), for: .valueChanged)
//        //studyProgressSegmentedControl.selectedSegmentTintColor = .systemGray5
//        studyProgressSegmentedControl.subviews.forEach {
//            $0.backgroundColor = .systemBackground
//        }
//        //studyProgressSegmentedControl.selectedSegmentTintColor = .clear
//
//        // --- ВАЖНО: контейнер с фиксированной шириной ---
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        container.addSubview(studyProgressSegmentedControl)
//        container.backgroundColor = .clear
//        container.layer.cornerRadius = 22 * scaleFactor
//
//        studyProgressSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            container.widthAnchor.constraint(equalToConstant: 210), // 👈 Увеличиваешь как хочешь
//            container.heightAnchor.constraint(equalToConstant: 44),
//            studyProgressSegmentedControl.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//            studyProgressSegmentedControl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//            studyProgressSegmentedControl.topAnchor.constraint(equalTo: container.topAnchor),
//            studyProgressSegmentedControl.bottomAnchor.constraint(equalTo: container.bottomAnchor)
//        ])
//
//        let segmentsItem = UIBarButtonItem(customView: container)
//        //segmentsItem.customView?.backgroundColor = .clear
//
//        let searchButton = UIBarButtonItem(
//            barButtonSystemItem: .search,
//            target: self,
//            action: #selector(searchTapped)
//        )
//
//        toolbarItems = [
//            segmentsItem,
//            UIBarButtonItem.flexibleSpace(),
//            searchButton
//        ]
//        updateSegmentsColors()
//        
//    }
    
}

//MARK: - Actions
extension AtlasViewController {
    
    @objc func settingsButtonTapped(){
        
    }
    
    @objc func resetButtonTapped(){
        let alert = UIAlertController(
            title: "Reset Progress",
            message: "Are you sure you want to reset all learning progress?",
            preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self]_ in
            guard let self = self else { return }
            lightHaptic?.impactOccurred()
            atlasModel.resetLearningProgress()
            reloadSnapshot()
            setResetButtonState()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @objc func modeButtonTapped() {
        guard let world = atlasModel.world else { return }
        
        let vc = StudyModeViewController(world: world, initialConfig: atlasModel.currentConfig)
        let nav = UINavigationController(rootViewController: vc)
        
        vc.selectedModeindex = atlasModel.currentConfig.mode.rawValue
        vc.initialRegion = atlasModel.currentConfig.region
        
        vc.onSelectionConfirmed = { [weak self] region, mode in
            guard let self else { return }
            
            self.atlasModel.currentConfig.region = region
            self.atlasModel.currentConfig.mode = mode
            self.updateUIForConfig()
            self.atlasModel.saveUserConfiguratin((self.atlasModel.currentConfig))
            self.reloadSnapshot()
            
            self.bottomControl.mode = mode == .learning ? .learning : .testing
            self.bottomControlWidthConstraint.constant = self.bottomControl.preferredWidth
            //self?.collectionView.reloadData()
            self.setupRightButtonItems()
            
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
    
    //MARK: - Learning Mode Changed (Segmented Control)
    private func bindBottomControlBar() {
        bottomControl.onLearningChanged = { [weak self] segment in
            guard let self else { return }
            switch segment {
            case .toLearn:
                self.title = segment.title
                self.displayMode = .list
                self.atlasModel.updateFilterMode(segment.segment)
            case .learned:
                self.title = segment.title
                self.displayMode = .list
                self.atlasModel.updateFilterMode(segment.segment)
            case .stats:
                self.title = segment.title
                self.displayMode = .stats
            }
            applyLayoutForCurrentMode()
            reloadSnapshot()
        }

        bottomControl.onTestingChanged = { [weak self] segment in
            guard let self else { return }

            switch segment {
            case .test:
                self.title = segment.title
                print("Testing: Capital")
            case .fail:
                self.title = segment.title
                print("Testing: Country")
            case .result:
                self.title = segment.title
                print("Testing: Flag")
            }
        }
    }
    
//    @objc func progressModeChanged(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0, 1:
//            displayMode = .list
//            atlasModel.updateFilterMode(sender.selectedSegmentIndex)
//        case 2:
//            displayMode = .stats
//            //atlasModel.updateFilterMode(sender.selectedSegmentIndex)
//        default:
//            break
//        }
//        
//        applyLayoutForCurrentMode()
//        //collectionView.reloadData()
//        reloadSnapshot()
//        //updateSegmentsColors()
//    }
    
    
    @objc func searchTapped() {
        print("Search tapped")
    }
    
    
    private func updateUIForConfig() {
        let mode = atlasModel.currentConfig.mode
        
        modeButton.image = atlasModel.currentConfig.mode == .learning ? UIImage(systemName: "book.fill") : UIImage(systemName: "person.fill.questionmark")
        modeButton.tintColor = atlasModel.currentConfig.mode == .learning ? AppColors.marine : AppColors.coolred
        
        bottomControl.mode = (mode == .learning) ? .learning : .testing
        bottomControlWidthConstraint.constant = bottomControl.preferredWidth
        
        switch mode {
        case .learning:
            title = bottomControl.currentLearningSegment.title
        case .testing:
            title = bottomControl.currentTestingSegment.title
        }
    }
    
//    func updateSegmentsColors() {
//        let index = studyProgressSegmentedControl.selectedSegmentIndex
//        let activeToLearnColor = UIColor.systemYellow
//        let activeLearnedColor = UIColor.systemGreen
//        let activeProgressColor = UIColor.systemBlue
//        let activeColor = (index == 0) ? activeToLearnColor : (index == 1 ? activeLearnedColor : activeProgressColor)
//        let inactiveColor = UIColor.tertiaryLabel
//        let size: CGFloat = 16 * scaleFactor
//        let activeFont = UIFont.systemFont(ofSize: size, weight: .bold)
//        let inactiveFont = UIFont.systemFont(ofSize: size, weight: .semibold)
//        
//        studyProgressSegmentedControl.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: inactiveFont], for: .normal)
//        studyProgressSegmentedControl.setTitleTextAttributes([.foregroundColor: activeColor, .font: activeFont], for: .selected)
//    }
    
    //MARK: - Data Snapshots
    func reloadSnapshot_() {
        snapshotWorld = atlasModel.filteredWorld()
        collectionView.reloadData()
    }
    
    func reloadSnapshot() {
        switch displayMode {
        case .list:
            reloadWorldSnapshot()
        case .stats:
            reloadStatsSnapshot()
        }
        collectionView.reloadData()
    }
    
    func reloadWorldSnapshot() {
        snapshotWorld = atlasModel.filteredWorld()
    }
    
    func reloadStatsSnapshot() {
        snapshotStats = atlasModel.getStatistics()
    }

}
//MARK: - CollectionView Delegate
extension AtlasViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if displayMode == .list {
            return snapshotWorld.continents.count
        } else {
            return snapshotStats.count
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if displayMode == .list {
            return snapshotWorld.continents[section].countries.count
        } else {
            return 1 //only stats cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if displayMode == .list {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CountryCell.reusedId, for: indexPath) as! CountryCell
            let continents = snapshotWorld.continents[indexPath.section]
            let country = continents.countries[indexPath.item]
            cell.configure(index: indexPath.item + 1, flag: country.flag, name: country.name, capital: country.capital)
            return cell
        } else {
            let stats = snapshotStats[indexPath.section]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatsCell.reusedId, for: indexPath) as! StatsCell
            cell.configure(with: stats)
            return cell
        }
    }
    
    //Header, Footer
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if displayMode == .list {
            let sectionName = snapshotWorld.continents[indexPath.section].name
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
            let continent = snapshotStats[indexPath.section]
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


extension AtlasViewController {
   
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

extension AtlasViewController {
    func setResetButtonState() {
        resetButton.isEnabled =  atlasModel.startedLearning ? true : false
    }
}
