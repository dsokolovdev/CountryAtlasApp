
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
    private let atlasModel: AtlasModel
    private var lightHaptic: UIImpactFeedbackGenerator!
    private var displayMode: DisplayMode = .list
   // private let makeQuestion: TestQuestionViewController
    
    //UI
    private var collectionView: UICollectionView!
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
    private var snapshotTestStats: [ContinentTestStats] = []
    
    private var bottomControlWidthConstraint: NSLayoutConstraint!
    
    private var searchText: String = ""
    //private var searchBar: UISearchBar?
    private var searchController: UISearchController!
    private var isKeyboardVisible = false
    
    
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
        setupCollectionView()
        setupBottomControlBar()
        bindBottomControlBar()
        
        applyLayoutForCurrentMode()
        
        atlasModel.onWorldUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.reloadSnapshot()
            }
        }
        reloadSnapshot()
        
        updateUIForConfig()
        setResetButtonState()
        
        setupSearch()
        
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

//MARK: - Setup UI
extension AtlasViewController {
    //MARK: - Setup Navigation Bar
    func setupnavigationBar(){
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        resetButton = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise", withConfiguration: config), style: .plain, target: self, action: #selector(resetButtonTapped))
        modeButton = UIBarButtonItem(image: UIImage(systemName: "book.fill"), style: .plain, target: self, action: #selector(modeButtonTapped))
        testAspectButton = UIBarButtonItem(image: UIImage(systemName: atlasModel.testingAspect.iconName), menu: makeMenu())
        
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
            //self.atlasModel.testingAspect = .capital
            self.atlasModel.setTestingAspect(.capital)
            self.testAspectButton.image = UIImage(systemName: atlasModel.testingAspect.iconName)
            self.testAspectButton.menu = self.makeMenu()
            self.reloadSnapshot()
            self.setResetButtonState()
        }
        
        let countryAction = UIAction(title: "Countries", image: countryImage, state: atlasModel.testingAspect == .country ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            //self.atlasModel.testingAspect = .country
            self.atlasModel.setTestingAspect(.country)
            self.testAspectButton.image = UIImage(systemName: atlasModel.testingAspect.iconName)
            self.testAspectButton.menu = self.makeMenu()
            self.reloadSnapshot()
            self.setResetButtonState()
        }
        let flagAction = UIAction(title: "Flags", image: flagImage, state: atlasModel.testingAspect == .flag ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            //self.atlasModel.testingAspect = .flag
            self.atlasModel.setTestingAspect(.flag)
            self.testAspectButton.image = UIImage(systemName: atlasModel.testingAspect.iconName)
            self.testAspectButton.menu = self.makeMenu()
            self.reloadSnapshot()
            self.setResetButtonState()
        }
        
        func attributedTitle(_ text: String, isActive: Bool) -> NSAttributedString {
            NSAttributedString(string: text, attributes: [.foregroundColor: isActive ? activeColor : inactiveColor])
        }
        
        capitalAction.setValue(attributedTitle("Capitals", isActive: atlasModel.testingAspect == .capital), forKey: "attributedTitle")
        countryAction.setValue(attributedTitle("Countries", isActive: atlasModel.testingAspect == .country), forKey: "attributedTitle")
        flagAction.setValue(attributedTitle("Flags", isActive: atlasModel.testingAspect == .flag), forKey: "attributedTitle")
        
        return UIMenu(title: "Testing Items", children: [capitalAction, countryAction, flagAction])
    }
    
    //MARK: - Make List Layout
    func makeListLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        
        config.showsSeparators = false
        config.headerMode = .supplementary
        //config.footerMode = .supplementary
        
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
//            guard self.atlasModel.currentConfig.mode == .learning else { return nil }
            guard self.atlasModel.filterMode == 0 && self.atlasModel.currentConfig.mode == .learning else { return nil }
            
            // Right Green Swap Button (Learned)
            let learnedAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                
                self.atlasModel.markCountryAsLearned(at: indexPath)
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
            
            guard self.atlasModel.filterMode == 1 && self.atlasModel.currentConfig.mode == .learning else { return nil }
            
            // Left Yellow Swap Button (Unlearned)
            let unlearnedAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                
                self.atlasModel.markCountryAsLearned(at: indexPath)
                self.reloadSnapshot()
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
    
    //MARK: - Make Stats Layout
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
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(32))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        
        section.boundarySupplementaryItems = [header, footer]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    //MARK: - Setup Collection View
    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeListLayout())
        //collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeStatsViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        
        collectionView.register(CountryCell.self, forCellWithReuseIdentifier: CountryCell.reusedId)
        collectionView.register(ContinentHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ContinentHeader.reuseId)
        collectionView.register(ContinentFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ContinentFooter.reuseId)
        
        collectionView.register(LearnStatsCell.self, forCellWithReuseIdentifier: LearnStatsCell.reusedId)
        collectionView.register(LearnStatsHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LearnStatsHeader.reusedId)
        collectionView.register(LearnStatsFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LearnStatsFooter.reusedId)
        
        collectionView.register(TestStatsCell.self, forCellWithReuseIdentifier: TestStatsCell.reusedId)
        collectionView.register(TestStatHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TestStatHeader.reusedId)
        collectionView.register(TestStatsFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: TestStatsFooter.reusedId)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //MARK: - Apply Layout for current mode
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
    
    //MARK: - Setup Bottom Control Bar
    func setupBottomControlBar() {
        bottomControl = BottomControlBar()
        
        let searchButton = UIButton(type: .system)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        searchButton.setImage(image, for: .normal)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        
        if #available(iOS 26.0, *) {
            let configuration = UIButton.Configuration.glass()
           searchButton.configuration = configuration
        } else {
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
        }
        
        NSLayoutConstraint.activate([
            searchButton.widthAnchor.constraint(equalToConstant: 56),
            searchButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        bottomControlStack = UIStackView(arrangedSubviews: [bottomControl, searchButton])
        bottomControlStack.axis = .horizontal
        bottomControlStack.alignment = .center
        bottomControlStack.spacing = 10
        bottomControlStack.distribution = .equalSpacing
        bottomControlStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomControlStack)
        
        bottomControlWidthConstraint = bottomControl.widthAnchor.constraint(equalToConstant: bottomControl.preferredWidth)
        
        NSLayoutConstraint.activate([
            bottomControlStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 12),
            bottomControlStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -12),
            bottomControlStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            
            bottomControlWidthConstraint,
            bottomControl.heightAnchor.constraint(equalToConstant: 58) //
        ])
    }
}

//MARK: - Actions
extension AtlasViewController {
    
    //MARK: - Setting button tapped
    @objc func settingsButtonTapped(){
        
    }
    
    //MARK: - Reset button tapped
    @objc func resetButtonTapped(){
        var message = ""
        switch atlasModel.currentConfig.mode {
        case .learning:
            message = "Are you sure you want to reset your learning progress?"
        case .testing:
            if atlasModel.testingAspect == .capital {
                message = "Do you want to reset your capital test progress?"
            } else if atlasModel.testingAspect == .country {
                message = "Do you want to reset your country test progress?"
            } else if atlasModel.testingAspect == .flag {
                message = "Do you want to reset your flag test progress?"
            }
        }
        
        let alert = UIAlertController(
            title: "Reset Progress",
            message: message,
            preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self]_ in
            guard let self = self else { return }
            lightHaptic?.impactOccurred()
            
            if atlasModel.currentConfig.mode == .learning {
                atlasModel.resetLearningProgress()
            } else {
                atlasModel.resetTestingProgress()
            }
            
            reloadSnapshot()
            setResetButtonState()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Mode button tapped
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
            self.setResetButtonState()
            
            self.bottomControl.mode = mode == .learning ? .learning : .testing
            self.bottomControlWidthConstraint.constant = self.bottomControl.preferredWidth
            self.setupRightButtonItems()
            
        }
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [ .custom { _ in return 300 } ]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
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
            case .untested:
                self.title = segment.title
                self.displayMode = .list
                self.atlasModel.updateFilterMode(segment.segment)
                //print("Testing: Capital \(segment.segment)")
            case .failed:
                self.title = segment.title
                self.displayMode = .list
                self.atlasModel.updateFilterMode(segment.segment)
                //print("Testing: Country \(segment.segment)")
            case .passed:
                self.title = segment.title
                self.displayMode = .list
                self.atlasModel.updateFilterMode(segment.segment)
                //print("Testing: Country \(segment.segment)")
            case .result:
                self.title = segment.title
                self.displayMode = .stats
                //print("Testing: Flag \(segment.segment)")
            }
            applyLayoutForCurrentMode()
            reloadSnapshot()
        }
    }
    
    
    //MARK: - Seach Button Tapped
//    @objc func searchTapped() {
//        navigationItem.searchController?.isActive = true
//    }
    
    //MARK: - Update UI
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
    
    //MARK: - Reload Snapshots
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
        switch atlasModel.currentConfig.mode {
        case .learning:
            snapshotStats =  atlasModel.getStatistics()
        case .testing:
            snapshotTestStats = atlasModel.getTestStatistics()
        }
    }
    
    func reloadStatsTestSnapshot() {
        //snapshotStatsTest = atlasModel.getStatistics(for: .testing)
        snapshotTestStats = atlasModel.getTestStatistics()
    }
    
}
//MARK: - CollectionView Delegate
extension AtlasViewController: UICollectionViewDataSource {
    
    //Number of Sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if displayMode == .list {
            return snapshotWorld.continents.count
        } else {
            switch atlasModel.currentConfig.mode {
            case .learning:
                return snapshotStats.count
            case .testing:
                return snapshotTestStats.count
            }
        }
    }
    
    //Number of Items in Sections
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if displayMode == .list {
            return snapshotWorld.continents[section].countries.count
        } else {
            return 1 //only stats cell
        }
    }
    
    //MARK: - Cell Configure
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if displayMode == .list {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CountryCell.reusedId, for: indexPath) as! CountryCell
            let continents = snapshotWorld.continents[indexPath.section]
            let country = continents.countries[indexPath.item]
            
            let testingAspect = atlasModel.testingAspect
            let isTestingMode = atlasModel.currentConfig.mode == .testing ? true : false
            let currentSegment = bottomControl.currentTestingSegment.segment
            
            cell.configure(country: country, testingAspect: testingAspect, isTestingMode: isTestingMode, currentSegment: currentSegment)
            return cell
        } else {
            switch atlasModel.currentConfig.mode {
            case .learning:
                let stats = snapshotStats[indexPath.section]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LearnStatsCell.reusedId, for: indexPath) as! LearnStatsCell
                cell.configure(with: stats)
                return cell
            case .testing:
                let stats = snapshotTestStats[indexPath.section]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestStatsCell.reusedId, for: indexPath) as! TestStatsCell
                cell.configure(with: stats)
                return cell
            }
        }
    }
    
    //MARK: - Header, Footer Configure
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //Display list mode (segments 0, 1)
        if displayMode == .list {
            let continent = snapshotWorld.continents[indexPath.section]
            let totalCount = atlasModel.getTotal(for: indexPath)
            let currentCount = atlasModel.getCurrentCount(for: indexPath)
            
            //Header
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ContinentHeader.reuseId, for: indexPath) as! ContinentHeader
                header.configure(continent: continent)
                return header
            }
            
            //Footer
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ContinentFooter.reuseId, for: indexPath) as! ContinentFooter
                footer.configure(count: totalCount - currentCount)
                return footer
            }
        } else {
            switch atlasModel.currentConfig.mode {
            case .learning:
                //Display Statistics mode (segment 2)
                let continent = snapshotStats[indexPath.section]
                
                //Header
                if kind == UICollectionView.elementKindSectionHeader {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LearnStatsHeader.reusedId, for: indexPath) as! LearnStatsHeader
                    header.configure(continent: continent)
                    return header
                }
                
                //Footer
                if kind == UICollectionView.elementKindSectionFooter {
                    let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LearnStatsFooter.reusedId, for: indexPath) as! LearnStatsFooter
                    footer.configure(continent: continent)
                    return footer
                }
            case .testing:
                //Display Statistics mode (segment 2)
                let continent = snapshotTestStats[indexPath.section]
                
                //Header
                if kind == UICollectionView.elementKindSectionHeader {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TestStatHeader.reusedId, for: indexPath) as! TestStatHeader
                    header.configure(continent: continent)
                    return header
                }
                
                //Footer
                if kind == UICollectionView.elementKindSectionFooter {
                    let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TestStatsFooter.reusedId, for: indexPath) as! TestStatsFooter
                    footer.configure(continent: continent)
                    return footer
                }
            }
        }
        
        fatalError("Unexpected supplementary kind: \(kind)")
    }
}
//MARK: - Test Question View Controller

extension AtlasViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard atlasModel.currentConfig.mode == .testing else { return }
        guard bottomControl.currentTestingSegment == .untested else { return }
        guard !isKeyboardVisible else { return }
        
        let country = snapshotWorld.continents[indexPath.section].countries[indexPath.item]
        let style: TestQuestionViewController.OptionSytle = atlasModel.testingAspect == .flag ? .flag : .text
        let aspect: TestQuestionViewController.TestingAspect =  atlasModel.testingAspect == .capital ? .capital : (atlasModel.testingAspect == .country ? .country : .flag)
        
        let question = atlasModel.makeTestQuestion(for: country)
        
        let vc = TestQuestionViewController(question: question, style: style, aspect: aspect)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        vc.onAnswerSelected = { [weak self] isCorrect in
            guard let self else { return }
            
            //let isCorrect = selectedIndex == question.correctIndex
            
            self.atlasModel.updateTestResult(for: country, aspect: self.atlasModel.testingAspect, result: isCorrect)
            
            self.reloadSnapshot()
            self.setResetButtonState()
        }
      
    
        present(vc, animated: true)
    }
    
}
//MARK: - CollectionView Long Hold Context Menu (Experimental)
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
        switch atlasModel.currentConfig.mode {
        case .learning:
            resetButton.isEnabled =  atlasModel.startedLearning ? true : false
        case .testing:
            resetButton.isEnabled =  atlasModel.startedTesting ? true : false
        }
    }
}

//MARK: - Search
extension AtlasViewController {
    private func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        searchController.delegate = self

        // кнопка Done на клавиатуре
        searchController.searchBar.returnKeyType = .done

        // важно
        definesPresentationContext = true
    }
    
    @objc private func searchTapped() {
        present(searchController, animated: true)
    }
}

extension AtlasViewController: UISearchBarDelegate, UISearchControllerDelegate {

//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        atlasModel.setSearchQuery(searchText)
//        reloadSnapshot()
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            atlasModel.setSearchQuery(nil)   // 🔥 СБРОС
        } else {
            atlasModel.setSearchQuery(searchText)
        }
        reloadSnapshot()
    }


    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        atlasModel.setSearchQuery(nil)
        reloadSnapshot()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // скрыть клавиатуру (Done)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
            atlasModel.setSearchQuery(nil)
            reloadSnapshot()
        }
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//            atlasModel.setSearchQuery(nil)   // 🔥 сброс поиска
//            reloadSnapshot()                 // 🔥 вернуть полный список
//        }
}

//MARK: - Keyboard Show/Hide methods
extension AtlasViewController {
    @objc private func keyboardWillShow() {
        isKeyboardVisible = true
    }

    @objc private func keyboardWillHide() {
        isKeyboardVisible = false
    }
}
