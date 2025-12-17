//
//  TestQuestionViewController.swift
//  AtlasMaster
//
//  Created by Dmitri  on 15.12.25.
//

import UIKit

final class TestQuestionViewController: UIViewController {
    enum OptionSytle: CGFloat {
        case text = 18
        case flag = 50
        
        var size: CGFloat { self.rawValue }
        
        var optionFontSize: CGFloat {
            switch self {
            case .flag: return 60
            case .text: return 18
            }
        }
    }
    
    enum TestingAspect {
        case country
        case capital
        case flag
        
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
    
    var onAnswerSelected: ((Bool) -> Void)?
    
    let style: OptionSytle
    let country: Country
    let aspect: TestingAspect
    let question: TestQuestion
    
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.quaternaryfill//UIColor.systemBackground.withAlphaComponent(0.9)
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false

        // Тень для «карточки»
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.2
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v
    }()
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Question"
        lbl.font = .rounded(ofSize: 20, weight: .semibold)
        lbl.textAlignment = .center
        lbl.textColor = AppColors.greyblue
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
        
    }()
    
    let questionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "What is the capital of France?"
        lbl.font = .rounded(ofSize: 16, weight: .regular)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let resultLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .rounded(ofSize: 22, weight: .semibold)
        lbl.textAlignment = .center
        lbl.alpha = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Done", for: .normal)
        btn.titleLabel?.font = .rounded(ofSize: 16, weight: .semibold)
        return btn
    }()
    
    let optionsVStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let optionOneButton: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()
    
    let optionTwoButton: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()
    
    let optionThreeButton: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()
    
    let optionFourButton: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()
    
    init(question: TestQuestion, style: OptionSytle, /*country: Country, */aspect: TestingAspect) {
        self.question = question
        self.style = style
        self.country = question.country
        self.aspect = aspect
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Полупрозрачный фон всего экрана
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
    
    private func setupCardView() {
        view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 320),
        ])
    }
    
    private func setupResultLabel() {
        cardView.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            resultLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }
    
    private func setupDoneButton() {
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        cardView.addSubview(doneButton)

        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            doneButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12)
        ])
    }
    
    private func setupTitleLabel() {
        cardView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])
    }
    
    private func setupQuestionLabel() {
        cardView.addSubview(questionLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            questionLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            questionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
        ])
    }
    
    private func setupOptionButtons() {
        let size = style.size
        [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton].forEach {
            $0.addTarget(self, action: #selector(choiceMade(sender:)), for: .touchUpInside)
          //  $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
            $0.titleLabel?.font = .systemFont(ofSize: size, weight: .medium)
            $0.tintColor = AppColors.darkblue
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.lineBreakMode = .byWordWrapping
            
//            $0.contentHorizontalAlignment = .leading
//            $0.titleLabel?.textAlignment = .left
//            $0.titleLabel?.setContentCompressionResistancePriority(.required, for: .vertical)
//            $0.titleLabel?.setContentHuggingPriority(.required, for: .vertical)
        }
    }
    
    private func setupOptionsVStack() {

        cardView.addSubview(optionsVStack)

        NSLayoutConstraint.activate([
            optionsVStack.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 24),
            optionsVStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            optionsVStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            optionsVStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24)
        ])

        switch style {
        case .text:
            setupTextOptions()
        case .flag:
            setupFlagOptions()
        }
    }
    
    private func presentOptionAnswers() {
       // let indexes = (0..<4).map { _ in Int.random(in: 0..<4) }
        let buttons = [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton]
//        let options = question.options.shuffled()
//
//        for (button, option) in zip(buttons, options) {
//            button.setTitle(option.title, for: .normal)
//        }
        for (index, button) in buttons.enumerated() {
                let option = question.options[index]
                button.setTitle(option.title, for: .normal)
                button.tag = index   // 🔑 это индекс option
            }
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
    
    @objc private func choiceMade(sender: UIButton) {
        
        let isCorrect = sender.tag == question.correctIndex
        
        showResult(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.onAnswerSelected?(isCorrect)
            self.dismiss(animated: true)
        }
    }
    
    private func showResult(isCorrect: Bool) {
        resultLabel.text = isCorrect ? "Correct ✓" : "Wrong ✕"
        resultLabel.textColor = isCorrect ? .systemGreen : .systemRed

        UIView.animate(withDuration: 0.25) {
            self.resultLabel.alpha = 1
            self.optionsVStack.alpha = 0.14
        }
    }
}

//MARK: - Setup Up Layout Options for OptionsVStack
extension TestQuestionViewController {
    private func setupTextOptions() {
        [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton].forEach {
            optionsVStack.addArrangedSubview($0)
        }
    }
    
    private func setupFlagOptions() {

        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 16
        row1.distribution = .fillEqually

        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 16
        row2.distribution = .fillEqually

        row1.addArrangedSubview(optionOneButton)
        row1.addArrangedSubview(optionTwoButton)

        row2.addArrangedSubview(optionThreeButton)
        row2.addArrangedSubview(optionFourButton)

        optionsVStack.addArrangedSubview(row1)
        optionsVStack.addArrangedSubview(row2)
    }
}
