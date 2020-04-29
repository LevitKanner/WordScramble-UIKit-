//
//  ViewController.swift
//  WordScramble
//
//  Created by Levit Kanner on 29/04/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        let url = Bundle.main.url(forResource: "start", withExtension: "txt")!
        allWords = try! String(contentsOf: url).components(separatedBy: "\n")
        startGame()
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    
    @objc func startGame() {
        title = allWords.randomElement()?.uppercased()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let controller = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        controller.addTextField(configurationHandler: nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self , weak controller] _ in
            guard let answer = controller?.textFields?.first?.text else {return}
            self?.submit(answer)
        }
        controller.addAction(submitAction)
        present(controller, animated: true, completion: nil)
    }
    
    
    func submit(_ answer: String) {
        let word = answer.lowercased()
        guard isPossible(word: word) && isValid(word: word) && isOriginal(word: word) else {
            configureAlert(title: "Used word", message: "word already used")
            return
        }
        usedWords.insert(word, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        print(usedWords)
    }
    
    //Check to see if user input can be constructed from the current word
    func isPossible(word: String) -> Bool {
        guard var currentWord = title?.lowercased() else { return false}
        
        for letter in word {
            if let position = currentWord.firstIndex(of: letter){
                currentWord.remove(at: position)
                continue
            }
            return false
        }
        return true
    }
    
    //checks if user input has not been used already
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    
    //Checks if user input is an english word
    func isValid(word: String) -> Bool {
        guard !word.isEmpty && word.count > 2 && word != title?.lowercased() else {
            configureAlert(title: "Invalid", message: "Empty or too short")
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    
    func configureAlert(title: String , message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

