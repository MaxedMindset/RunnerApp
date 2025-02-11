//
//  PowerUp.swift
//  EcoRunner
//
//  Erstellt von ChatGPT - Beispielprojekt
//

import SpriteKit

/// Die Klasse `PowerUp` repräsentiert ein umweltfreundliches Bonus-Objekt, das der Spieler sammeln kann.
/// Beim Einsammeln wird der Eco-Score erhöht und visuelle Effekte werden ausgelöst.
class PowerUp: SKSpriteNode {
    
    // MARK: – Initialisierung
    /// Initialisiert ein PowerUp an einer bestimmten Position mit gegebener Größe.
    /// - Parameters:
    ///   - position: Die Position, an der das PowerUp erscheinen soll.
    ///   - size: Die Größe des PowerUps.
    init(position: CGPoint, size: CGSize) {
        let texture = SKTexture(imageNamed: "powerup")
        super.init(texture: texture, color: .clear, size: size)
        self.position = position
        self.setupPhysics()
        self.zPosition = 1
    }
    
    /// Initialisierung für den Fall, dass das PowerUp aus einem Archiv geladen wird.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPhysics()
    }
    
    // MARK: – Physik Setup
    /// Konfiguriert den Physik-Body des PowerUps, damit Kollisionen mit dem Spieler erkannt werden.
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.powerUp
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.player
    }
    
    // MARK: – Bewegung
    /// Lässt das PowerUp von rechts nach links über den Bildschirm gleiten.
    /// - Parameters:
    ///   - duration: Die Dauer, die das PowerUp für die Bewegung benötigt.
    ///   - sceneWidth: Die Breite der Szene.
    func startMoving(withDuration duration: TimeInterval, sceneWidth: CGFloat) {
        let moveLeft = SKAction.moveBy(x: -sceneWidth - self.size.width * 2, y: 0, duration: duration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveLeft, remove])
        self.run(sequence)
    }
    
    // -------------------------------------------------------------------------------------
    // Erweiterte Kommentare:
    //
    // PowerUps tragen zur Abwechslung im Spiel bei und motivieren den Spieler, geschickt Hindernissen auszuweichen.
    // Beim Einsammeln wird der Eco-Score erhöht, was wiederum positive Effekte im Spiel auslöst.
    // Diese Klasse kann später um zusätzliche Effekte, Animationen oder Soundeffekte erweitert werden.
    // -------------------------------------------------------------------------------------
    
    // Zusätzliche leere Zeilen:
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
