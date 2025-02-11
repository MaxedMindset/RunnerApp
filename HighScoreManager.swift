//
//  HighScoreManager.swift
//  EcoRunner
//
//  Erstellt von ChatGPT – HighScore Manager
//  Diese Klasse verwaltet das Speichern und Laden von Highscores mithilfe von UserDefaults.
//  Detaillierte Kommentare und Hilfsfunktionen ermöglichen spätere Erweiterungen.
//
 
import Foundation

class HighScoreManager {
    static let shared = HighScoreManager()
    private let highScoreKey = "EcoRunnerHighScore"
    
    private init() { }
    
    func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
    func setHighScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: highScoreKey)
        UserDefaults.standard.synchronize()
    }
    
    // Zusätzliche Hilfsfunktionen können hier ergänzt werden,
    // z. B. das Speichern von Highscore-Listen, Namen, etc.
}
