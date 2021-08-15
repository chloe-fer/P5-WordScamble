//
//  ViewController.swift
//  Project-5
//
//  Created by Chloe Fermanis on 13/8/21.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        // Challenge 3: Bar Button to restart / create a new game
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Restart", style: .plain, target: self, action: #selector(startGame))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startGame))
        
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
        
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    
                    // Challenge 1: Disallow words less that 3 letters.
                    if lowerAnswer.count < 3 {
                        
                        // Challenge 2: Refactoring
                        showErrorMessage(
                            errorTitle: "Word too short",
                            errorMessage: "Must be three letters or longer.")
                        
                    } else {
                        
                        // Challenge 1: Dissalow using the original word.
                        if lowerAnswer == title {
                            
                            // Challenge 2: Refactoring
                            showErrorMessage(
                                errorTitle: "Original Word",
                                errorMessage: "Dont use original word!")
        
                        } else {
                            // Bonus: Fix case-sensitive bug.
                            usedWords.insert(answer.lowercased(), at: 0)
                            let indexPath = IndexPath(row: 0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            
                            return
                        }
                    }
                    
                } else {
                    
                    // Challenge 2: Refactoring
                    showErrorMessage(
                        errorTitle: "Word not recognised",
                        errorMessage: "You can't just make them up!")

                }
            } else {
                
                // Challenge 2: Refactoring
                showErrorMessage(
                    errorTitle: "Word aleady used",
                    errorMessage: "Be more original!")
               
            }
        } else {
            guard let title = title else { return }
            
            // Challenge 2: Refactoring
            showErrorMessage(
                errorTitle: "Word not possible",
                errorMessage: "You can't spell that word from \(title.lowercased()).")
        }
        
        
        
        
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    // Challenge 2: Refactoring
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
}

