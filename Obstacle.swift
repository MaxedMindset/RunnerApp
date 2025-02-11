//
//  Obstacle.swift
//  EcoRunner
//
//  Erstellt von ChatGPT - Beispielprojekt
//

import SpriteKit

/// Die Klasse `Obstacle` repräsentiert ein Hindernis, das dem Spieler den Weg versperrt.
/// Hindernisse werden von rechts hereingeschoben und müssen vermieden werden.
class Obstacle: SKSpriteNode {
    
    // MARK: – Initialisierung
    /// Initialisiert ein Hindernis an einer bestimmten Position und mit einer definierten Größe.
    /// - Parameters:
    ///   - position: Die Startposition des Hindernisses.
    ///   - size: Die Größe des Hindernisses.
    init(position: CGPoint, size: CGSize) {
        // Erstelle eine Textur aus dem Bild "obstacle"
        let texture = SKTexture(imageNamed: "obstacle")
        super.init(texture: texture, color: .clear, size: size)
        self.position = position
        self.setupPhysics()
        self.zPosition = 1
    }
    
    /// Initialisierung für den Fall, dass das Hindernis aus einem Archiv geladen wird.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPhysics()
    }
    
    // MARK: – Physik Setup
    /// Konfiguriert den Physik-Body des Hindernisses, damit es als statisches Objekt in der Welt agiert.
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.obstacle
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.player
    }
    
    // MARK: – Bewegung
    /// Startet die Bewegung des Hindernisses von rechts nach links.
    /// - Parameters:
    ///   - duration: Die Zeit, die das Hindernis benötigt, um den Bildschirm zu durchqueren.
    ///   - sceneWidth: Die Breite der Szene, um die Bewegung richtig zu berechnen.
    func startMoving(withDuration duration: TimeInterval, sceneWidth: CGFloat) {
        let moveLeft = SKAction.moveBy(x: -sceneWidth - self.size.width * 2, y: 0, duration: duration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveLeft, remove])
        self.run(sequence)
    }
    
    // -------------------------------------------------------------------------------------
    // Erweiterte Kommentare:
    //
    // Hindernisse sind entscheidend, um den Schwierigkeitsgrad des Spiels zu erhöhen.
    // Sie werden periodisch erzeugt und bewegen sich mit konstanter Geschwindigkeit nach links.
    // Der Physik-Body ist so eingestellt, dass Kollisionen mit dem Spieler erkannt werden.
    // -------------------------------------------------------------------------------------
    
    // Zusätzliche leere Zeilen zur Erweiterung:
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
