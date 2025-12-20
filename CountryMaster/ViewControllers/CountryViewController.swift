//
//  ViewController.swift
//
//  Created by Dmitri  on 06.12.25.
//
//  Description:
//  Main screen of AtlasMaster.
//  Displays a list of countries grouped by continents (learning/testing flows)
//  and a statistics screen (learning/testing results).
//  Owns a UICollectionView with two layouts: list + stats.
//  Provides navigation actions (settings/reset/mode/testing-aspect) and bottom control bar.
//

import UIKit

// MARK: - AtlasViewController
final class CountryViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Display Mode
    /// Defines which layout/snapshot the collection view should display.
    /// - list: country list grouped by continent (segments 0, 1)
    /// - stats: statistics cards (segment 2 / result)
    enum  DisplayMode {
        case list   //segments 0, 1
        case stats  //segments 2
    }
    
    // MARK: - Dependencies
    /// Core model responsible for world data, user configuration, filtering and progress.
    private let countryModel: CountryModel
    
    // MARK: - Haptics
    /// Light impact feedback used on destructive actions (e.g. reset).
    private var lightHaptic: UIImpactFeedbackGenerator!
    
    // MARK: - State
    /// Current screen mode that affects layout and data source.
    private var displayMode: DisplayMode = .list
    // private let makeQuestion: TestQuestionViewController
    
    // MARK: - UI
    /// Main collection view showing either list or statistics layout.
    private var collectionView: UICollectionView!
    
    /// Navigation bar buttons.
    private var settingsButton: UIBarButtonItem!
    private var resetButton: UIBarButtonItem!
    private var modeButton: UIBarButtonItem!
    private var testAspectButton: UIBarButtonItem!
    
    /// (Not used currently) Placeholder for a segmented control if you decide to bring it back.
    private var studyProgressSegmentedControl: UISegmentedControl!
    
    /// Bottom control bar (learning/testing segments).
    private var bottomControl: BottomControlBar!
    
    /// Container stack: bottomControl + search button.
    private var bottomControlStack: UIStackView!
    
    // MARK: - Snapshots of Data
    /// Cached world snapshot used to drive list mode.
    private var snapshotWorld = World()
    
    /// Cached learning statistics snapshot used to drive stats mode.
    private var snapshotStats: [ContinentStats] = []
    
    /// Cached testing statistics snapshot used to drive stats mode.
    private var snapshotTestStats: [ContinentTestStats] = []
    
    // MARK: - Constraints
    /// Width constraint for the bottom control bar (changes depending on learning/testing mode).
    private var bottomControlWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Search
    /// Current search text (kept for potential future use; model currently owns the query).
    private var searchText: String = ""
    //private var searchBar: UISearchBar?
    
    /// Presented search controller.
    private var searchController: UISearchController!
    
    // MARK: - Keyboard
    /// Used to avoid starting a test question while the keyboard is up.
    private var isKeyboardVisible = false
    
    
    // MARK: - Init
    init(model: CountryModel) {
        self.countryModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = true
        configureNavigationTitle()
        
        setupnavigationBar()
        setupRightButtonItems()
        setupCollectionView()
        setupBottomControlBar()
        bindBottomControlBar()
        
        // Apply initial layout based on displayMode.
        applyLayoutForCurrentMode()
        
        // Model → UI binding: refresh snapshot whenever world changes.
        countryModel.onWorldUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.reloadSnapshot()
            }
        }
        
        // Initial data load.
        reloadSnapshot()
        
        // Sync UI colors/titles with current configuration.
        updateUIForConfig()
        setResetButtonState()
        
        // Search controller setup (presented from bottom search button).
        setupSearch()
        
        //title = "AtlasMaster"
        view.backgroundColor = .systemBackground
        view.preservesSuperviewLayoutMargins = true
        
        // Layout margins scaling.
        let constant: CGFloat = 16.scaled
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: constant,
            bottom: 0,
            trailing: constant
        )
        
        // Prepare haptics.
        if #available(iOS 17.5, *) {
            lightHaptic = UIImpactFeedbackGenerator(style: .light, view: view)
        } else {
            // Fallback for earlier iOS versions (no view-based initializer available).
            lightHaptic = UIImpactFeedbackGenerator(style: .light)
        }
        
        // Track keyboard visibility (used to block list selection in testing flow).
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
extension CountryViewController {
    
    // MARK: - Navigation Bar
    /// Creates left/right navigation items and applies tint colors.
    /// - Left: settings + flexible space + reset
    /// - Right: mode button (and test aspect button in testing mode)
    func setupnavigationBar(){
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let config = UIImage.SymbolConfiguration(pointSize: 18.scaled, weight: .semibold)
        settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        resetButton = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise", withConfiguration: config), style: .plain, target: self, action: #selector(resetButtonTapped))
        modeButton = UIBarButtonItem(image: UIImage(systemName: "book.fill"), style: .plain, target: self, action: #selector(modeButtonTapped))
        
        // Test aspect menu is attached to the bar button item.
        testAspectButton = UIBarButtonItem(image: UIImage(systemName: countryModel.testingAspect.iconName), menu: makeMenu())
        
        navigationItem.leftBarButtonItems = [settingsButton, space, resetButton]
        navigationItem.rightBarButtonItems = [ modeButton]
        settingsButton.tintColor = .greyBlue
        resetButton.tintColor = .greyBlue
        testAspectButton.tintColor = .nasuPurple
    }
    
    /// Updates right-side items depending on current study mode.
    /// - learning: only modeButton
    /// - testing: modeButton + testAspectButton
    func setupRightButtonItems() {
        let rightItems: [UIBarButtonItem] = countryModel.currentConfig.mode == .learning ? [modeButton] : [modeButton, testAspectButton]

        guard let navigationBar = navigationController?.navigationBar else {
            navigationItem.rightBarButtonItems = rightItems
            return
        }

        UIView.transition(with: navigationBar, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                self.navigationItem.rightBarButtonItems = rightItems
            }
        )
    }
    
    // MARK: - Test Aspect Menu
    /// Builds a UIMenu for switching testing aspect (Capitals/Countries/Flags).
    /// Also updates the button icon, reloads snapshots and refreshes reset state.
    func makeMenu() -> UIMenu {
        let activeColor: UIColor = .nasuPurple
        let inactiveColor: UIColor = .greyBlue.withAlphaComponent(0.7)
        
        // Use paletteColors to tint different menu icons depending on current selection.
        let capitalImage = UIImage(systemName: "building.2.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [countryModel.testingAspect == .capital ? activeColor : inactiveColor]))
        let countryImage = UIImage(systemName: "globe.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [countryModel.testingAspect == .country ? activeColor : inactiveColor]))
        let flagImage = UIImage(systemName: "flag.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [countryModel.testingAspect == .flag ? activeColor : inactiveColor]))
        
        
        let capitalAction = UIAction(title: "Capitals", image: capitalImage, state: countryModel.testingAspect == .capital ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            //self.atlasModel.testingAspect = .capital
            self.countryModel.setTestingAspect(.capital)
            self.testAspectButton.image = UIImage(systemName: countryModel.testingAspect.iconName)
            self.testAspectButton.menu = self.makeMenu()
            UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.reloadSnapshot()
            })
            self.setResetButtonState()
        }
        
        let countryAction = UIAction(title: "Countries", image: countryImage, state: countryModel.testingAspect == .country ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            //self.atlasModel.testingAspect = .country
            self.countryModel.setTestingAspect(.country)
            self.testAspectButton.image = UIImage(systemName: countryModel.testingAspect.iconName)
            self.testAspectButton.menu = self.makeMenu()
            UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.reloadSnapshot()
            })
            self.setResetButtonState()
        }
        let flagAction = UIAction(title: "Flags", image: flagImage, state: countryModel.testingAspect == .flag ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            //self.atlasModel.testingAspect = .flag
            self.countryModel.setTestingAspect(.flag)
            self.testAspectButton.image = UIImage(systemName: countryModel.testingAspect.iconName)
            self.testAspectButton.menu = self.makeMenu()
            UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.reloadSnapshot()
            })
            self.setResetButtonState()
        }
        
        /// Creates a colored title for each menu item.
        func attributedTitle(_ text: String, isActive: Bool) -> NSAttributedString {
            NSAttributedString(string: text, attributes: [.foregroundColor: isActive ? activeColor : inactiveColor])
        }
        
        capitalAction.setValue(attributedTitle("Capitals", isActive: countryModel.testingAspect == .capital), forKey: "attributedTitle")
        countryAction.setValue(attributedTitle("Countries", isActive: countryModel.testingAspect == .country), forKey: "attributedTitle")
        flagAction.setValue(attributedTitle("Flags", isActive: countryModel.testingAspect == .flag), forKey: "attributedTitle")
        
        return UIMenu(title: "Testing Items", children: [capitalAction, countryAction, flagAction])
    }
    
    // MARK: - Layouts
    
    //MARK: - Make List Layout
    /// Creates list-style layout with optional swipe actions.
    /// Swipe actions are enabled only in learning mode and depend on current filter segment.
    func makeListLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        
        config.showsSeparators = false
        config.headerMode = .supplementary
        //config.footerMode = .supplementary
        
        // Trailing swipe (right-to-left): mark as learned, available only for "to learn" segment.
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            //            guard self.atlasModel.currentConfig.mode == .learning else { return nil }
            guard self.countryModel.filterMode == 0 && self.countryModel.currentConfig.mode == .learning else { return nil }
            
            // Right Green Swap Button (Learned)
            let learnedAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                
                self.countryModel.markCountryAsLearned(at: indexPath)
                UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                    self.reloadSnapshot()
                })
                self.setResetButtonState()
                
                completion(true)
            }
            
            learnedAction.backgroundColor = .systemGreen
            learnedAction.image = UIImage(systemName: "checkmark")
            
            let swipeConfiguration = UISwipeActionsConfiguration(actions: [learnedAction])
            //swipeConfiguration.performsFirstActionWithFullSwipe = false
            
            return swipeConfiguration
        }
        
        // Leading swipe (left-to-right): mark as unlearned/learned toggle, available only for "learned" segment.
        config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            guard self.countryModel.filterMode == 1 && self.countryModel.currentConfig.mode == .learning else { return nil }
            
            // Left Yellow Swap Button (Unlearned)
            let unlearnedAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
                
                self.countryModel.markCountryAsLearned(at: indexPath)
                UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                    self.reloadSnapshot()
                })
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
    /// Creates vertical compositional layout for statistics cells.
    /// Uses pinned header/footer supplementary items per section.
    func makeStatsLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120.scaled))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120.scaled))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8.scaled
        section.contentInsets = NSDirectionalEdgeInsets(top: 8.scaled, leading: 0, bottom: 8.scaled, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44.scaled))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        header.pinToVisibleBounds = false
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(32.scaled))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        
        section.boundarySupplementaryItems = [header, footer]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    //MARK: - Setup Collection View
    /// Instantiates and configures collection view, registers all required cells and supplementary views.
    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeListLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        
        // List mode registrations
        collectionView.register(CountryCell.self, forCellWithReuseIdentifier: CountryCell.reusedId)
        collectionView.register(ContinentHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ContinentHeader.reuseId)
        collectionView.register(ContinentFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ContinentFooter.reuseId)
        
        // Learning stats registrations
        collectionView.register(LearnStatsCell.self, forCellWithReuseIdentifier: LearnStatsCell.reusedId)
        collectionView.register(LearnStatsHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LearnStatsHeader.reusedId)
        collectionView.register(LearnStatsFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LearnStatsFooter.reusedId)
        
        // Testing stats registrations
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
    /// Switches collection view layout depending on current displayMode.
    /// Use animated = false to avoid layout glitches during snapshot reloads.
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
    /// Creates bottom control bar + search button, embeds them in a horizontal stack,
    /// and pins to bottom with margins.
    func setupBottomControlBar() {
        bottomControl = BottomControlBar()
        
        let searchButton = UIButton(type: .system)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        searchButton.setImage(image, for: .normal)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        
        if #available(iOS 26.0, *) {
            let configuration = UIButton.Configuration.glass()
            searchButton.configuration = configuration
            searchButton.tintColor = .greyBlue
        } else {
            searchButton.tintColor = .label
            searchButton.backgroundColor = .systemBackground
            searchButton.layer.cornerRadius = 28.scaled
            searchButton.translatesAutoresizingMaskIntoConstraints = false
            searchButton.layer.shadowColor = UIColor.label.cgColor
            searchButton.layer.shadowOpacity = 0.15
            searchButton.layer.shadowRadius = 6.scaled
            searchButton.layer.shadowOffset = CGSize(width: 0, height: 2.5)
            searchButton.layer.masksToBounds = false
            searchButton.tintColor = .greyBlue
        }
        
        let d: CGFloat = 56.scaled
        NSLayoutConstraint.activate([
            searchButton.widthAnchor.constraint(equalToConstant: d),
            searchButton.heightAnchor.constraint(equalToConstant: d)
        ])
        
        bottomControlStack = UIStackView(arrangedSubviews: [bottomControl, searchButton])
        bottomControlStack.axis = .horizontal
        bottomControlStack.alignment = .center
        bottomControlStack.spacing = 10.scaled
        bottomControlStack.distribution = .equalSpacing
        bottomControlStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomControlStack)
        
        bottomControlWidthConstraint = bottomControl.widthAnchor.constraint(equalToConstant: bottomControl.preferredWidth)
        
        let w: CGFloat = 12.scaled
        let h: CGFloat = 30.scaled
        let height: CGFloat = 58.scaled
        NSLayoutConstraint.activate([
            bottomControlStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: w),
            bottomControlStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -w),
            bottomControlStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -h),
            
            bottomControlWidthConstraint,
            bottomControl.heightAnchor.constraint(equalToConstant: height) //
        ])
    }
}

//MARK: - Actions
extension CountryViewController {
    
    //MARK: - Setting button tapped
    /// Opens settings screen (placeholder).
    /// TODO: Present SettingsViewController.
    @objc func settingsButtonTapped(){
        let settingsVC = SettingsViewController(model: countryModel)
        
        settingsVC.onSettingsChange = { [weak self] in
            guard let self = self else { return }
            
            self.reloadSnapshot()
        }
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    //MARK: - Reset button tapped
    /// Shows confirmation alert and resets progress.
    /// - learning: resets learned/unlearned progress
    /// - testing: resets progress for the current testing aspect
    @objc func resetButtonTapped(){
        var message = ""
        switch countryModel.currentConfig.mode {
        case .learning:
            message = "Are you sure you want to reset your learning progress?"
        case .testing:
            if countryModel.testingAspect == .capital {
                message = "Do you want to reset your capital test progress?"
            } else if countryModel.testingAspect == .country {
                message = "Do you want to reset your country test progress?"
            } else if countryModel.testingAspect == .flag {
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
            
            if countryModel.currentConfig.mode == .learning {
                countryModel.resetLearningProgress()
            } else {
                countryModel.resetTestingProgress()
            }
            
            UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.reloadSnapshot()
            })
            setResetButtonState()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Mode button tapped
    /// Presents StudyModeViewController in a sheet.
    /// On confirmation: updates config, persists it, reloads data, and refreshes UI.
    @objc func modeButtonTapped() {
        guard let world = countryModel.world else { return }
        
        let vc = StudyModeViewController(world: world, initialConfig: countryModel.currentConfig)
        let nav = UINavigationController(rootViewController: vc)
        
        vc.selectedModeindex = countryModel.currentConfig.mode.rawValue
        vc.initialRegion = countryModel.currentConfig.region
        
        vc.onSelectionConfirmed = { [weak self] region, mode in
            guard let self else { return }
            
            self.countryModel.currentConfig.region = region
            self.countryModel.currentConfig.mode = mode
            self.countryModel.saveUserConfiguratin((self.countryModel.currentConfig))
            
            // Update bottom control bar mode and width.
            self.bottomControl.mode = mode == .learning ? .learning : .testing
            self.bottomControlWidthConstraint.constant = self.bottomControl.preferredWidth
            
            //Reset Segment
            self.displayMode = .list
            self.bottomControl.resetToFirstSegment()
            let segment = mode == .testing ? bottomControl.currentTestingSegment.segment : bottomControl.currentLearningSegment.segment
            countryModel.updateFilterMode(segment)
            
            //UI
            self.updateUIForConfig()
            self.setupRightButtonItems()
            self.setResetButtonState()
            
            UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.reloadSnapshot()
            })
            
        }
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [ .custom { _ in return 300.scaled } ]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
    
    //MARK: - Learning Mode Changed (Segmented Control)
    /// Binds bottom control bar callbacks.
    /// Updates title, display mode, filter mode, layout, and snapshot.
    private func bindBottomControlBar() {
        bottomControl.onLearningChanged = { [weak self] segment in
            guard let self else { return }
            switch segment {
            case .toLearn:
                self.setAnimatedTitle(segment.title)
                self.displayMode = .list
                self.countryModel.updateFilterMode(segment.segment)
            case .learned:
                self.setAnimatedTitle(segment.title)
                self.displayMode = .list
                self.countryModel.updateFilterMode(segment.segment)
            case .stats:
                self.setAnimatedTitle(segment.title)
                self.displayMode = .stats
            }
            applyLayoutForCurrentMode()
            UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.reloadSnapshot()
            })
        }
        
        bottomControl.onTestingChanged = { [weak self] segment in
            guard let self else { return }
            
            switch segment {
            case .untested:
                self.setAnimatedTitle(segment.title)
                self.displayMode = .list
                self.countryModel.updateFilterMode(segment.segment)
            case .failed:
                self.setAnimatedTitle(segment.title)
                self.displayMode = .list
                self.countryModel.updateFilterMode(segment.segment)
            case .passed:
                self.setAnimatedTitle(segment.title)
                self.displayMode = .list
                self.countryModel.updateFilterMode(segment.segment)
            case .result:
                self.setAnimatedTitle(segment.title)
                self.displayMode = .stats
            }
            applyLayoutForCurrentMode()
            UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.reloadSnapshot()
            })
        }
    }
    
    //MARK: - Update UI
    /// Updates UI elements based on current study mode.
    /// - Updates mode button icon + tint
    /// - Switches bottom control mode
    /// - Updates screen title based on the currently selected segment
    private func updateUIForConfig() {
        let mode = countryModel.currentConfig.mode
        
        modeButton.image = countryModel.currentConfig.mode == .learning ? UIImage(systemName: "book.fill") : UIImage(systemName: "person.fill.questionmark")
        modeButton.tintColor = countryModel.currentConfig.mode == .learning ? .merchantMarine : .coolRed
        
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
    /// Reloads snapshot data depending on displayMode and refreshes collection view.
    func reloadSnapshot() {
        switch displayMode {
        case .list:
            reloadWorldSnapshot()
        case .stats:
            reloadStatsSnapshot()
        }
        collectionView.reloadData()
    }
    
    /// Refreshes world snapshot using current filters (region/mode/search/etc.).
    func reloadWorldSnapshot() {
        snapshotWorld = countryModel.filteredWorld()
    }
    
    /// Refreshes statistics snapshot depending on current study mode.
    func reloadStatsSnapshot() {
        switch countryModel.currentConfig.mode {
        case .learning:
            snapshotStats =  countryModel.getStatistics()
        case .testing:
            snapshotTestStats = countryModel.getTestStatistics()
        }
    }
    
    /// (Not used currently) Explicit testing stats reload helper.
    func reloadStatsTestSnapshot() {
        //snapshotStatsTest = atlasModel.getStatistics(for: .testing)
        snapshotTestStats = countryModel.getTestStatistics()
    }
    
}

//MARK: - CollectionView Delegate
extension CountryViewController: UICollectionViewDataSource {
    
    //Number of Sections
    /// Returns section count depending on displayMode.
    /// - list: continents count
    /// - stats: stats per continent (learning/testing)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if displayMode == .list {
            return snapshotWorld.continents.count
        } else {
            switch countryModel.currentConfig.mode {
            case .learning:
                return snapshotStats.count
            case .testing:
                return snapshotTestStats.count
            }
        }
    }
    
    //Number of Items in Sections
    /// Returns item count for a given section.
    /// - list: number of countries in the continent
    /// - stats: always 1 (single stats card cell)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if displayMode == .list {
            return snapshotWorld.continents[section].countries.count
        } else {
            return 1 //only stats cell
        }
    }
    
    //MARK: - Cell Configure
    /// Dequeues and configures a cell depending on displayMode and current config.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if displayMode == .list {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CountryCell.reusedId, for: indexPath) as! CountryCell
            //cell.maskMode = Settings.maskMode
            let continents = snapshotWorld.continents[indexPath.section]
            let country = continents.countries[indexPath.item]
            
            let testingAspect = countryModel.testingAspect
            let isTestingMode = countryModel.currentConfig.mode == .testing ? true : false
            let currentSegment = bottomControl.currentTestingSegment.segment
            
            cell.configure(country: country, testingAspect: testingAspect, isTestingMode: isTestingMode, currentSegment: currentSegment, maskMode: countryModel.maskMode)
            return cell
        } else {
            switch countryModel.currentConfig.mode {
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
    /// Provides supplementary views for headers/footers depending on displayMode.
    /// - list: ContinentHeader + ContinentFooter
    /// - stats: mode-specific headers/footers
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //Display list mode (segments 0, 1)
        if displayMode == .list {
            let continent = snapshotWorld.continents[indexPath.section]
            let totalCount = countryModel.getTotal(for: indexPath)
            let currentCount = countryModel.getCurrentCount(for: indexPath)
            
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
            switch countryModel.currentConfig.mode {
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

extension CountryViewController {
    
    /// Starts a test question flow when a country is selected.
    /// Conditions:
    /// - only in testing mode
    /// - only when "untested" segment is selected
    /// - do not present while keyboard is visible
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard countryModel.currentConfig.mode == .testing else { return }
        guard bottomControl.currentTestingSegment == .untested else { return }
        guard !isKeyboardVisible else { return }
        
        let country = snapshotWorld.continents[indexPath.section].countries[indexPath.item]
        let style: TestQuestionViewController.OptionSytle = countryModel.testingAspect == .flag ? .flag : .text
        let aspect: TestQuestionViewController.TestingAspect =  countryModel.testingAspect == .capital ? .capital : (countryModel.testingAspect == .country ? .country : .flag)
        
        let question = countryModel.makeTestQuestion(for: country)
        
        let vc = TestQuestionViewController(question: question, style: style, aspect: aspect)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        // Save answer result to the model, then refresh snapshots.
        vc.onAnswerSelected = { [weak self] isCorrect in
            guard let self else { return }
            
            self.countryModel.updateTestResult(for: country, aspect: self.countryModel.testingAspect, result: isCorrect)
            
            
            UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.reloadSnapshot()
            })
            self.setResetButtonState()
        }
        
        
        present(vc, animated: true)
    }
    
}

// MARK: - Navigation Title Appearance
extension CountryViewController {
    
    /// Configures navigation bar title font and color.
    private func configureNavigationTitle() {
        let appearance = UINavigationBarAppearance()
        
        appearance.titleTextAttributes = [.font: UIFont.rounded(ofSize: 18.scaled, weight: .medium),.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
}

// MARK: - Reset Button State
extension CountryViewController {
    
    /// Enables/disables reset button depending on whether progress exists.
    func setResetButtonState() {
        switch countryModel.currentConfig.mode {
        case .learning:
            resetButton.isEnabled =  countryModel.startedLearning ? true : false
        case .testing:
            resetButton.isEnabled =  countryModel.startedTesting ? true : false
        }
    }
}

//MARK: - Search
extension CountryViewController {
    
    /// Prepares UISearchController (presented modally).
    /// Search query is forwarded into the model and list is reloaded.
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
    
    /// Presents search controller from the bottom search button.
    @objc private func searchTapped() {
        present(searchController, animated: true)
    }
}

extension CountryViewController: UISearchBarDelegate, UISearchControllerDelegate {
    
    /// Updates model search query while the user types.
    /// Empty string resets the filter.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            countryModel.setSearchQuery(nil)
        } else {
            UIView.transition(with: self.collectionView, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.countryModel.setSearchQuery(searchText)
            })
        }
        reloadSnapshot()
    }
    
    
    /// Handles Cancel tap: resets search query and reloads full list.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        countryModel.setSearchQuery(nil)
        reloadSnapshot()
    }
    
    /// Handles Done/Search key: hides keyboard.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // скрыть клавиатуру (Done)
    }
    
    /// Called when search UI is dismissed: reset query and reload.
    func didDismissSearchController(_ searchController: UISearchController) {
        countryModel.setSearchQuery(nil)
        reloadSnapshot()
    }
}

//MARK: - Keyboard Show/Hide methods
extension CountryViewController {
    
    /// Marks keyboard visible. Used to prevent presenting testing question over active search keyboard.
    @objc private func keyboardWillShow() {
        isKeyboardVisible = true
    }
    
    /// Marks keyboard hidden.
    @objc private func keyboardWillHide() {
        isKeyboardVisible = false
    }
}

//Title Animation
extension CountryViewController {
    private func setAnimatedTitle(_ text: String) {
        guard let navigationBar = navigationController?.navigationBar else {
            title = text
            return
        }
        
        UIView.transition(with: navigationBar, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                self.title = text
            },
            completion: nil
        )
    }
}
