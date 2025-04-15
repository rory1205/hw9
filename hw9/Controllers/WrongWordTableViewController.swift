//
//  WrongWordTableViewController.swift
//  hw9
//
//  Created by Rory on 2025/4/12.
//

import UIKit

protocol WrongWordTableViewControllerDelegate: AnyObject {
    func deleteWrongWord(_ controller: WrongWordTableViewController, didDeleteWordAt index: Int)
}

class WrongWordTableViewController: UITableViewController {
    
    weak var delegate: WrongWordTableViewControllerDelegate?
    
    var wrongWordList: [WordItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "錯題本"
        
        // 設置背景圖片
        let backgroundImage = UIImage(named: "wwbg")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleToFill
        tableView.backgroundView = backgroundImageView
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wrongWordList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as? WrongWordTableViewCell else {
            fatalError("Unable to dequeue WrongWordTableViewCell")
        }
        let word = wrongWordList[indexPath.row]
        cell.delegate = self
        cell.configure(with: word)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delegate?.deleteWrongWord(self, didDeleteWordAt: indexPath.row)
            wrongWordList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}

extension WrongWordTableViewController: WrongWordTableViewCellDelegate {
    func didTapReference(word: String) {
        let controller = UIReferenceLibraryViewController(term: word)
        present(controller, animated: true, completion: nil)
    }
}
