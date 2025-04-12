//
//  WrongWordTableViewCell.swift
//  hw9
//
//  Created by Rory on 2025/4/12.
//

import UIKit
import AVFoundation

class WrongWordTableViewCell: UITableViewCell {
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var wordTypeLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var speakButton: UIButton!
    
    private let synthesizer = AVSpeechSynthesizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 設定 cell 背景為透明
        contentView.backgroundColor = .clear
        backgroundColor = UIColor.cyan.withAlphaComponent(0.3)
        
        // 添加圓角效果
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(with word: WordItem) {
        wordLabel.text = word.word
        wordTypeLabel.text = word.word_type
        meaningLabel.text = word.meaning
    }
    
    @IBAction func speakButtonTapped(_ sender: Any) {
        if let word = wordLabel.text {
            let utterance = AVSpeechUtterance(string: word)
            synthesizer.speak(utterance)
        }
    }
}
