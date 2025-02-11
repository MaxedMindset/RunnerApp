//
//  SoundManager.swift
//  EcoRunner
//
//  Erstellt von ChatGPT – Sound Manager
//
//  Diese Singleton-Klasse verwaltet die Hintergrundmusik und Soundeffekte des Spiels.
//  Sie verwendet AVFoundation, um Musik abzuspielen und ermöglicht das einfache Abspielen von Sounds.
//

import AVFoundation
import SpriteKit

class SoundManager {
    static let shared = SoundManager()
    var backgroundMusicPlayer: AVAudioPlayer?
    
    private init() { }
    
    func playBackgroundMusic(filename: String) {
        if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = 0.5
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                print("Error loading \(filename): \(error)")
            }
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    func playSoundEffect(filename: String) {
        let soundAction = SKAction.playSoundFileNamed(filename, waitForCompletion: false)
        if let view = UIApplication.shared.keyWindow?.rootViewController?.view as? SKView,
           let scene = view.scene {
            scene.run(soundAction)
        }
    }
}
