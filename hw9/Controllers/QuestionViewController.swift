//
//  QuestionViewController.swift
//  hw9
//
//  Created by Rory on 2025/4/8.
//

import UIKit
import AVFoundation

class QuestionViewController: UIViewController, WrongWordTableViewControllerDelegate {
    func deleteWrongWord(_ controller: WrongWordTableViewController, didDeleteWordAt index: Int) {
        wrongWordList.remove(at: index)
    }
    
    @IBOutlet weak var currentCountLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var wordTypeLabel: UILabel!
    
    @IBOutlet var optionButtons: [UIButton]!
    
    var wordList: [WordItem]?
    var wrongWordList: [WordItem] = []
    var currentQuestion: QuizQuestion? {
        didSet {
            updateUI()
            speak(currentQuestion?.word ?? "")
        }
    }
    
    private var isAnswerLocked = false
    
    var rightCount = 0
    var wrongCount = 0
    
    let synthesizer = AVSpeechSynthesizer()
    let speakVoice = AVSpeechSynthesisVoice()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch loadWordList() {
        case .success(let words):
            wordList = words
            currentQuestion = generateQuizQuestion(from: words)
        case .failure(let error):
            showError(error)
        }
    }
    
    private func showError(_ error: WordListError) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(
                title: "載入單字失敗",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    enum WordListError: LocalizedError {
        case fileNotFound
        case decodingError(Error)
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "找不到單字列表檔案"
            case .decodingError(let error):
                return "解析單字列表失敗：\(error.localizedDescription)"
            }
        }
    }
    
    func loadWordList() -> Result<[WordItem], WordListError> {
        guard let url = Bundle.main.url(forResource: "word_list", withExtension: "json") else {
            return .failure(.fileNotFound)
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(WordList.self, from: data)
            return .success(response.word_list)
        } catch {
            return .failure(.decodingError(error))
        }
    }
    
    func updateUI() {
        currentCountLabel.text = "\(rightCount)/\(rightCount + wrongCount)"
        wordLabel.text = currentQuestion?.word
        wordTypeLabel.text = currentQuestion?.wordType
        
        for (index, button) in optionButtons.enumerated() {
            button.setTitle(currentQuestion?.options[index], for: .normal)
            button.tintColor = .systemBlue
        }
    }
    
    func generateQuizQuestion(from wordList: [WordItem]) -> QuizQuestion? {
        guard !wordList.isEmpty else { return nil }
        
        let selectedWord = wordList.randomElement()!
        let correctMeaning = selectedWord.meaning
        
        var wrongOptions = [String]()
        let otherMeanings = wordList.filter { $0.id != selectedWord.id }
            .map { $0.meaning }
        
        wrongOptions = Array(otherMeanings.shuffled().prefix(3))
        
        var options = [correctMeaning] + wrongOptions
        options.shuffle()
        
        return QuizQuestion(word: selectedWord.word, wordType: selectedWord.word_type, options: options, correctAnswer: correctMeaning)
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        synthesizer.speak(utterance)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        isAnswerLocked = false
        currentQuestion = generateQuizQuestion(from: wordList ?? [])
    }
    
    @IBAction func optionButton(_ sender: UIButton) {
        guard !isAnswerLocked else { return }
        
        let selectedOption = sender.titleLabel?.text
        let correctAnswer = currentQuestion?.correctAnswer
        
        if selectedOption == correctAnswer {
            rightCount += 1
            currentQuestion = generateQuizQuestion(from: wordList ?? [])
        } else {
            wrongCount += 1
            isAnswerLocked = true
            
            if let currentWord = wordList?.first(where: { $0.word == currentQuestion?.word }) {
                if !wrongWordList.contains(where: { $0.id == currentWord.id }) {
                    wrongWordList.append(currentWord)
                    print("add \(currentWord.word)")
                }
            }
            
            for button in optionButtons {
                if button.titleLabel?.text == correctAnswer {
                    button.setTitle("\(correctAnswer ?? "") ← 正確答案", for: .normal)
                    button.tintColor = .systemRed
                    break
                }
            }
            
            for button in optionButtons {
                if button.titleLabel?.text != correctAnswer {
                    button.tintColor = .systemGray
                }
            }
        }
    }
    
    @IBAction func resetButton(_ sender: Any) {
        rightCount = 0
        wrongCount = 0
        isAnswerLocked = false
        currentQuestion = generateQuizQuestion(from: wordList ?? [])
    }
    
    @IBAction func speakButton(_ sender: Any) {
        if let word = currentQuestion?.word {
            speak(word)
        }
    }
    
    @IBAction func wrongWordListButton(_ sender: Any) {
        performSegue(withIdentifier: "ShowWrongWords", sender: self)
    }
    
    @IBSegueAction func showWrongWords(_ coder: NSCoder) -> WrongWordTableViewController? {
        let controller = WrongWordTableViewController(coder: coder)
        controller?.wrongWordList = wrongWordList
        controller?.delegate = self
        return controller
    }
}

