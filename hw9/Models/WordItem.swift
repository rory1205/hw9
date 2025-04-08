//
//  WordItem.swift
//  hw9
//
//  Created by Rory on 2025/4/8.
//

struct WordItem: Codable {
    let id: Int
    let word: String
    let word_type: String
    let meaning: String
}

struct WordList: Codable {
    let word_list: [WordItem]
}
