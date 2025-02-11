//
//  GameScene.swift
//  EcoRunner
//
//  Erstellt von ChatGPT – Erweiterte Version
//
//  Diese Szene beinhaltet den gesamten Spielablauf: den Helden, das Environment,
//  Hindernisse, PowerUps, Score-Anzeige, Pause-Funktionalität, Game Over-Logik,
//  Highscore-Speicherung und weitere Details. Jeder einzelne Schritt ist ausführlich kommentiert.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Physikkategorien als Bitmasken
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let player    : UInt32 = 0b1       // 1
        static let obstacle  : UInt32 = 0b10      // 2
        static let powerUp   : UInt32 = 0b100     // 4
        static let ground    : UInt32 = 0b1000    // 8
    }
    
    // MARK: - Instanzen und Eigenschaften
    var hero: Hero!
    var environment: Environment!
    
    var scoreLabel: SKLabelNode!
    var ecoScoreLabel: SKLabelNode!
    
    var score: Int = 0
    var ecoScore: Int = 0
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    var gameOverState: Bool = false
    
    // Timer für das periodische Spawnen
    var obstacleTimer: TimeInterval = 0
    var powerUpTimer: TimeInterval = 0
    
    // Pause-Management
    var isGamePaused: Bool = false
    var pauseOverlay: SKNode?
    
    // Highscore-Speicher
    var highScore: Int = 0
    
    // MARK: - didMove(to:) wird aufgerufen, wenn die Szene erscheint
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.cyan
        
        // Konfiguriere die Physik-Welt.
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.contactDelegate = self
        
        // Initialisiere das Environment.
        environment = Environment(scene: self)
        
        // Erstelle den Boden.
        setupGround()
        
        // Erstelle den Helden und füge ihn der Szene hinzu.
        hero = Hero()
        hero.position = CGPoint(x: self.size.width * 0.2, y: 150)
        addChild(hero)
        hero.startRunning()
        
        // Richte Score-Labels ein.
        setupLabels()
        
        // Richte den Pause-Button ein.
        setupPauseButton()
        
        // Lade den Highscore.
        highScore = HighScoreManager.shared.getHighScore()
        
        // Initialisiere Zeitvariablen.
        lastUpdateTime = 0
        obstacleTimer = 0
        powerUpTimer = 0
        
        // Starte Hintergrundmusik.
        SoundManager.shared.playBackgroundMusic(filename: "backgroundMusic.mp3")
    }
    
    // MARK: - Boden Setup
    func setupGround() {
        let ground = SKSpriteNode(imageNamed: "ground")
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        ground.position = CGPoint(x: 0, y: 0)
        ground.size = CGSize(width: self.size.width * 2, height: 100)
        ground.zPosition = 2
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size,
                                           center: CGPoint(x: ground.size.width / 2, y: ground.size.height / 2))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(ground)
    }
    
    // MARK: - Score-Labels Setup
    func setupLabels() {
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: self.size.width - 20, y: self.size.height - 50)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "Score: \(score)"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        ecoScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        ecoScoreLabel.fontSize = 24
        ecoScoreLabel.fontColor = SKColor.green
        ecoScoreLabel.position = CGPoint(x: 20, y: self.size.height - 50)
        ecoScoreLabel.horizontalAlignmentMode = .left
        ecoScoreLabel.text = "Eco: \(ecoScore)"
        ecoScoreLabel.zPosition = 20
        addChild(ecoScoreLabel)
    }
    
    // MARK: - Pause-Button Setup
    func setupPauseButton() {
        let pauseButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        pauseButton.text = "❚❚"
        pauseButton.fontSize = 36
        pauseButton.fontColor = SKColor.black
        pauseButton.position = CGPoint(x: self.size.width - 40, y: self.size.height - 40)
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 50
        addChild(pauseButton)
    }
    
    // MARK: - Highscore Update
    func updateHighScore() {
        if score > highScore {
            highScore = score
            HighScoreManager.shared.setHighScore(highScore)
        }
    }
    
    // MARK: - Update-Schleife
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if gameOverState || isGamePaused { return }
        
        // Score erhöhen.
        score += Int(dt * 100)
        scoreLabel.text = "Score: \(score)"
        
        // Aktualisiere den Helden und das Environment.
        hero.update(deltaTime: dt)
        environment.update(deltaTime: dt, playerSpeed: 200)
        
        // Spawne Hindernisse.
        obstacleTimer += dt
        if obstacleTimer >= 2.0 {
            spawnObstacle()
            obstacleTimer = 0
        }
        
        // Spawne PowerUps.
        powerUpTimer += dt
        if powerUpTimer >= 5.0 {
            spawnPowerUp()
            powerUpTimer = 0
        }
        
        updateHighScore()
    }
    
    // MARK: - Hindernisse spawnen
    func spawnObstacle() {
        let obstacleSize = CGSize(width: 50, height: 50)
        let yPosition: CGFloat = 110  // knapp über dem Boden
        let spawnX = self.size.width + obstacleSize.width
        let obstacle = Obstacle(position: CGPoint(x: spawnX, y: yPosition), size: obstacleSize)
        addChild(obstacle)
        let duration = TimeInterval(4.0)
        obstacle.startMoving(withDuration: duration, sceneWidth: self.size.width)
    }
    
    // MARK: - PowerUps spawnen
    func spawnPowerUp() {
        let powerUpSize = CGSize(width: 40, height: 40)
        let randomY = CGFloat.random(in: 150...300)
        let spawnX = self.size.width + powerUpSize.width
        let powerUp = PowerUp(position: CGPoint(x: spawnX, y: randomY), size: powerUpSize)
        addChild(powerUp)
        let duration = TimeInterval(6.0)
        powerUp.startMoving(withDuration: duration, sceneWidth: self.size.width)
    }
    
    // MARK: - Touch-Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOverState { restartGame(); return }
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            // Überprüfe, ob der Pause-Button berührt wurde.
            for node in touchedNodes {
                if node.name == "pauseButton" {
                    togglePause()
                    return
                }
            }
            // Lasse den Helden springen.
            hero.jump()
        }
    }
    
    // MARK: - Pause-Management
    func togglePause() {
        isGamePaused = !isGamePaused
        self.isPaused = isGamePaused
        if isGamePaused {
            let overlay = SKShapeNode(rectOf: CGSize(width: self.size.width * 0.8, height: self.size.height * 0.5), cornerRadius: 20)
            overlay.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            overlay.fillColor = SKColor.black.withAlphaComponent(0.7)
            overlay.zPosition = 100
            overlay.name = "pauseOverlay"

            let resumeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            resumeLabel.text = "Resume"
            resumeLabel.fontSize = 32
            resumeLabel.fontColor = SKColor.white
            resumeLabel.position = CGPoint(x: 0, y: 20)
            resumeLabel.name = "resumeButton"
            resumeLabel.zPosition = 101
            overlay.addChild(resumeLabel)

            let menuLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            menuLabel.text = "Main Menu"
            menuLabel.fontSize = 32
            menuLabel.fontColor = SKColor.white
            menuLabel.position = CGPoint(x: 0, y: -20)
            menuLabel.name = "menuButton"
            menuLabel.zPosition = 101
            overlay.addChild(menuLabel)

            addChild(overlay)
            pauseOverlay = overlay
            SoundManager.shared.backgroundMusicPlayer?.setVolume(0.2, fadeDuration: 0.5)
        } else {
            pauseOverlay?.removeFromParent()
            pauseOverlay = nil
            SoundManager.shared.backgroundMusicPlayer?.setVolume(0.5, fadeDuration: 0.5)
        }
    }
    
    // Überschreibe touchesEnded, um Pause-Overlay-Touches zu behandeln.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGamePaused, let touch = touches.first {
            let location = touch.location(in: self)
            let nodesAtPoint = nodes(at: location)
            for node in nodesAtPoint {
                if node.name == "resumeButton" {
                    togglePause()
                } else if node.name == "menuButton" {
                    let mainMenu = MainMenuScene(size: self.size)
                    mainMenu.scaleMode = self.scaleMode
                    let transition = SKTransition.fade(withDuration: 1.0)
                    self.view?.presentScene(mainMenu, transition: transition)
                    SoundManager.shared.stopBackgroundMusic()
                }
            }
        }
    }
    
    // MARK: - Physikkontakt-Handling
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player &&
            secondBody.categoryBitMask == PhysicsCategory.obstacle {
            triggerGameOver()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player &&
            secondBody.categoryBitMask == PhysicsCategory.powerUp {
            if let powerUpNode = secondBody.node {
                collectPowerUp(powerUpNode)
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player &&
            secondBody.categoryBitMask == PhysicsCategory.ground {
            if hero.currentState == .jumping {
                hero.landed()
            }
        }
    }
    
    // MARK: - PowerUp einsammeln
    func collectPowerUp(_ node: SKNode) {
        ecoScore += 10
        ecoScoreLabel.text = "Eco: \(ecoScore)"
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        ecoScoreLabel.run(SKAction.sequence([scaleUp, scaleDown]))
        node.removeFromParent()
        SoundManager.shared.playSoundEffect(filename: "powerup.wav")
    }
    
    // MARK: - Game Over
    func triggerGameOver() {
        if gameOverState { return }
        gameOverState = true
        hero.removeFromParent()
        removeAllActions()
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        gameOverLabel.zPosition = 30
        addChild(gameOverLabel)
        
        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartLabel.text = "Tippe, um neu zu starten"
        restartLabel.fontSize = 32
        restartLabel.fontColor = SKColor.blue
        restartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 60)
        restartLabel.name = "restart"
        restartLabel.zPosition = 30
        addChild(restartLabel)
        
        SoundManager.shared.stopBackgroundMusic()
    }
    
    // MARK: - Neustart des Spiels
    func restartGame() {
        if let view = self.view {
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            let transition = SKTransition.fade(withDuration: 1.0)
            view.presentScene(newScene, transition: transition)
        }
    }
}
