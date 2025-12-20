//
//  TestQuestionViewController.swift
//
//  Created by Dmitri  on 15.12.25.
//
//  Description:
//  Modal view controller that presents a single test question
//  (country / capital / flag) with multiple answer options.
//  Handles answer selection, result feedback, and reports
//  correctness back via callback.
//

import UIKit

// MARK: - TestQuestionViewController
final class TestQuestionViewController: UIViewController {
    
    // MARK: - Option Style
    /// Defines how answer options are displayed (text or flag).
    enum OptionSytle: CGFloat {
        case text = 18
        case flag = 60
        
        /// Base size used for option layout.
        var size: CGFloat { self.rawValue.scaled }
        
        /// Font size for option titles depending on style.
        var optionFontSize: CGFloat {
            switch self {
            case .flag: return 60.scaled
            case .text: return 18.scaled
            }
        }
    }
    
    // MARK: - Testing Aspect
    /// Defines what is being tested: country, capital, or flag.
    enum TestingAspect {
        case country
        case capital
        case flag
        
        /// Generates question text based on selected aspect.
        func question(for country: Country) -> String {
            switch self {
            case .capital:
                return "What is the capital of \(country.name)?"
                
            case .country:
                return "\(country.capital) is the capital of which country?"
                
            case .flag:
                return "Which flag belongs to \(country.name)?"
            }
        }
    }
    
    // MARK: - Callbacks
    /// Called when user selects an answer.
    /// Returns true if answer is correct.
    var onAnswerSelected: ((Bool) -> Void)?
    
    // MARK: - Data
    let style: OptionSytle
    let country: Country
    let aspect: TestingAspect
    let question: TestQuestion
    
    // MARK: - UI Elements
    /// Card container view that holds all content.
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .quternaryFill
        v.layer.cornerRadius = 20.scaled
        v.translatesAutoresizingMaskIntoConstraints = false
        
        // Card shadow
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.2
        v.layer.shadowRadius = 10.scaled
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v
    }()
    
    /// Static title label ("Question").
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Question"
        lbl.font = .rounded(ofSize: 20.scaled, weight: .semibold)
        lbl.textAlignment = .center
        lbl.textColor = .greyBlue
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    /// Label that displays the actual question text.
    let questionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 16.scaled, weight: .regular)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    /// Label used to display result feedback (Correct / Wrong).
    private let resultLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 22.scaled, weight: .semibold)
        lbl.textAlignment = .center
        lbl.alpha = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    /// Button used to dismiss the question manually.
    let doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Done", for: .normal)
        btn.titleLabel?.font = .rounded(ofSize: 16.scaled, weight: .semibold)
        return btn
    }()
    
    /// Vertical stack that holds answer options.
    let optionsVStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16.scaled
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Option Buttons
    let optionOneButton: UIButton = { UIButton(type: .system) }()
    let optionTwoButton: UIButton = { UIButton(type: .system) }()
    let optionThreeButton: UIButton = { UIButton(type: .system) }()
    let optionFourButton: UIButton = { UIButton(type: .system) }()
    
    // MARK: - Init
    init(question: TestQuestion, style: OptionSytle, aspect: TestingAspect) {
        self.question = question
        self.style = style
        self.country = question.country
        self.aspect = aspect
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Semi-transparent background overlay
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        setupCardView()
        setupDoneButton()
        setupTitleLabel()
        setupQuestionLabel()
        setupOptionButtons()
        setupOptionsVStack()
        setupResultLabel()
        
        questionLabel.text = aspect.question(for: country)
        presentOptionAnswers()
    }
}

// MARK: - Setup UI
extension TestQuestionViewController {
    
    /// Adds and centers card view.
    private func setupCardView() {
        view.addSubview(cardView)
        
        let w: CGFloat = 320.scaled
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: w)
        ])
    }
    
    /// Adds result label to card view.
    private func setupResultLabel() {
        cardView.addSubview(resultLabel)
        
        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            resultLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }
    
    /// Adds Done button and binds action.
    private func setupDoneButton() {
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        cardView.addSubview(doneButton)
        
        let c: CGFloat = 12.scaled
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: c),
            doneButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -c)
        ])
    }
    
    /// Adds title label.
    private func setupTitleLabel() {
        cardView.addSubview(titleLabel)
        
        let t: CGFloat = 16.scaled
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: t),
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])
    }
    
    /// Adds question label below title.
    private func setupQuestionLabel() {
        cardView.addSubview(questionLabel)
        
        let t: CGFloat = 16.scaled
        let w: CGFloat = 8.scaled
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: t),
            questionLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: w),
            questionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -w)
        ])
    }
    
    /// Configures option buttons appearance and actions.
    private func setupOptionButtons() {
        let size = style.size
        [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton].forEach {
            $0.addTarget(self, action: #selector(choiceMade(sender:)), for: .touchUpInside)
            $0.titleLabel?.font = .systemFont(ofSize: size, weight: .medium)
            $0.tintColor = .darkBlue
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.lineBreakMode = .byWordWrapping
        }
    }
    
    /// Adds options stack and chooses layout based on style.
    private func setupOptionsVStack() {
        cardView.addSubview(optionsVStack)
        
        let d: CGFloat = 24.scaled
        NSLayoutConstraint.activate([
            optionsVStack.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: d),
            optionsVStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -d),
            optionsVStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: d),
            optionsVStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -d)
        ])
        
        switch style {
        case .text:
            setupTextOptions()
        case .flag:
            setupFlagOptions()
        }
    }
}

// MARK: - Data & Actions
extension TestQuestionViewController {
    
    /// Assigns option titles and tags to buttons.
    private func presentOptionAnswers() {
        let buttons = [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton]
        for (index, button) in buttons.enumerated() {
            let option = question.options[index]
            button.setTitle(option.title, for: .normal)
            button.tag = index
        }
    }
    
    /// Dismisses question without answering.
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
    
    /// Handles answer selection.
    @objc private func choiceMade(sender: UIButton) {
        let isCorrect = sender.tag == question.correctIndex
        showResult(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.onAnswerSelected?(isCorrect)
            self.dismiss(animated: true)
        }
    }
    
    /// Displays animated result feedback.
    private func showResult(isCorrect: Bool) {
        resultLabel.text = isCorrect ? "Correct ✓" : "Wrong ✕"
        resultLabel.textColor = isCorrect ? .systemGreen : .systemRed
        
        UIView.animate(withDuration: 0.25) {
            self.resultLabel.alpha = 1
            self.optionsVStack.alpha = 0.14
        }
    }
}

// MARK: - Options Layout
extension TestQuestionViewController {
    
    /// Layout for text-based options (vertical list).
    private func setupTextOptions() {
        [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton].forEach {
            optionsVStack.addArrangedSubview($0)
        }
    }
    
    /// Layout for flag-based options (2x2 grid).
    private func setupFlagOptions() {
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 16.scaled
        row1.distribution = .fillEqually
        
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 16.scaled
        row2.distribution = .fillEqually
        
        row1.addArrangedSubview(optionOneButton)
        row1.addArrangedSubview(optionTwoButton)
        
        row2.addArrangedSubview(optionThreeButton)
        row2.addArrangedSubview(optionFourButton)
        
        optionsVStack.addArrangedSubview(row1)
        optionsVStack.addArrangedSubview(row2)
    }
}

