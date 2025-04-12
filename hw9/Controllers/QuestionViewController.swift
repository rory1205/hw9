//
//  QuestionViewController.swift
//  hw9
//
//  Created by Rory on 2025/4/8.
//

import UIKit
import AVFoundation

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var currentCountLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var wordTypeLabel: UILabel!
    
    @IBOutlet var optionButtons: [UIButton]!
    
    var wordList: [WordItem]?
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
        
        // 隨機選一個單字作為題目
        let selectedWord = wordList.randomElement()!
        let correctMeaning = selectedWord.meaning
        
        // 從其他單字中隨機選 3 個錯誤答案
        var wrongOptions = [String]()
        let otherMeanings = wordList.filter { $0.id != selectedWord.id }
            .map { $0.meaning }
        
        wrongOptions = Array(otherMeanings.shuffled().prefix(3))
        
        // 合併並打亂選項
        var options = [correctMeaning] + wrongOptions
        options.shuffle()
        
        return QuizQuestion(word: selectedWord.word, wordType: selectedWord.word_type, options: options, correctAnswer: correctMeaning)
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        synthesizer.speak(utterance)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        isAnswerLocked = false  // 解除答案鎖定
        currentQuestion = generateQuizQuestion(from: wordList ?? [])
    }
    
    @IBAction func optionButton(_ sender: UIButton) {
        // 如果答案已鎖定，直接返回
        guard !isAnswerLocked else { return }
        
        let selectedOption = sender.titleLabel?.text
        let correctAnswer = currentQuestion?.correctAnswer
        
        if selectedOption == correctAnswer {
            rightCount += 1
            currentQuestion = generateQuizQuestion(from: wordList ?? [])
        } else {
            wrongCount += 1
            isAnswerLocked = true  // 鎖定答案狀態
            
            // 找到正確答案的按鈕並更改其文字
            for button in optionButtons {
                if button.titleLabel?.text == correctAnswer {
                    button.setTitle("\(correctAnswer ?? "") ← 正確答案", for: .normal)
                    button.tintColor = .systemRed
                    break
                }
            }
            
            // 將錯誤選項變灰
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
        isAnswerLocked = false  // 解除答案鎖定
        currentQuestion = generateQuizQuestion(from: wordList ?? [])
    }
    
    @IBAction func speakButton(_ sender: Any) {
        if let word = currentQuestion?.word {
            speak(word)
        }
    }
}

#Preview {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateInitialViewController()!
}
