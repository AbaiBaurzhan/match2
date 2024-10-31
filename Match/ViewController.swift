//
//  ViewController.swift
//  Match
//
//  Created by Абай Бауржан on 27.10.2024.
//

import UIKit

class ViewController: UIViewController {
    var images = ["1", "2", "3", "4", "5", "6", "7", "8", "1", "2", "3", "4", "5", "6", "7", "8"]
    
    var state = [Int](repeating: 0, count: 16)
    
    var isActive = false
    var timer: Timer?
    var totalSeconds = 0
    var moveCount = 0
    
   
    @IBOutlet weak var bestScoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var moveCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetGame()
        loadBestScore()
    }
    
    func resetGame() {
        state = [Int](repeating: 0, count: 16)
        images.shuffle()
        moveCount = 0
        moveCountLabel.text = "Ходы: \(moveCount)"
        timerLabel.text = "00:00:00"
        totalSeconds = 0
        
        isActive = false
        
        for index in 0..<16 {
            let button = view.viewWithTag(index + 1) as? UIButton
            button?.setBackgroundImage(nil, for: .normal)
            button?.backgroundColor = UIColor.systemMint
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        totalSeconds += 1
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    @IBAction func game(_ sender: UIButton) {
        if state[sender.tag - 1] != 0 || isActive {
            return
        }
        
        sender.setBackgroundImage(UIImage(named: images[sender.tag - 1]), for: .normal)
        sender.backgroundColor = UIColor.white
        state[sender.tag - 1] = 1
        
        moveCount += 1
        moveCountLabel.text = "Ходы: \(moveCount)"
        
        let openedCards = state.enumerated().filter { $0.element == 1 }.map { $0.offset }
        
        if openedCards.count == 2 {
            isActive = true
            
            let firstCardIndex = openedCards[0]
            let secondCardIndex = openedCards[1]
            
            if images[firstCardIndex] == images[secondCardIndex] {
                state[firstCardIndex] = 2
                state[secondCardIndex] = 2
                checkForWin()
            } else {
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(clear), userInfo: openedCards, repeats: false)
            }
        }
        startTimer()
    }
    
    @objc func clear(timer: Timer) {
        guard let openedCards = timer.userInfo as? [Int] else { return }
        
        for index in openedCards {
            if state[index] == 1 {
                state[index] = 0
                let button = view.viewWithTag(index + 1) as? UIButton
                button?.setBackgroundImage(nil, for: .normal)
                button?.backgroundColor = UIColor.systemMint
            }
        }
        
        isActive = false
    }

    func checkForWin() {
        if !state.contains(0) {
            timer?.invalidate()
            
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            
            let alertMessage = String(format: "Поздравляем, вы закончили игру за %02d:%02d:%02d и %d ходов!", hours, minutes, seconds, moveCount)
            
            let alert = UIAlertController(title: "Игра окончена", message: alertMessage, preferredStyle: .alert)
            
            updateBestScore()
            
            alert.addAction(UIAlertAction(title: "Начать заново", style: .default, handler: { _ in self.resetGame() }))
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
        isActive = false
    }

    func updateBestScore() {
        let currentBestScore = UserDefaults.standard.integer(forKey: "bestScore")
        if moveCount < currentBestScore || currentBestScore == 0 {
            UserDefaults.standard.set(moveCount, forKey: "bestScore")
            bestScoreLabel.text = "Лучший результат: \(moveCount) ходов"
        }
    }

    func loadBestScore() {
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        bestScoreLabel.text = "Лучший результат: \(bestScore) ходов"
    }
}
