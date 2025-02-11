//
//  Hero.swift
//  EcoRunner
//
//  Erstellt von ChatGPT – Erweiterte Version
//
//  Diese Version der Hero-Klasse beinhaltet mehrere Animationszustände:
//  - Idle
//  - Running
//  - Jumping
//  - Attacking (optional)
//  - Spezialeffekte (z. B. Partikel bei Landung)
//
//  Zusätzlich wird ein Zustandsautomaten implementiert, um zwischen den Zuständen zu wechseln.
//  Alle Animationen werden aus einem TextureAtlas geladen und in fließenden Übergängen abgespielt.
//  Umfangreiche Kommentare und Hilfsfunktionen sorgen für Erweiterbarkeit und optische Schönheit.
//

import SpriteKit

// MARK: – Definition der Hero-Zustände
enum HeroState {
    case idle
    case running
    case jumping
    case attacking
    case hit
}

class Hero: SKSpriteNode {
    
    // MARK: – Eigenschaften für Animationen und Zustände
    var idleFrames: [SKTexture] = []
    var runFrames: [SKTexture] = []
    var jumpFrame: SKTexture!
    var attackFrames: [SKTexture] = []
    
    var currentState: HeroState = .idle
    
    // Timer und Flags
    var isInvincible: Bool = false
    var invincibleDuration: TimeInterval = 1.5
    var invincibleTimer: TimeInterval = 0
    
    // Partikel für Landung
    var landingEmitter: SKEmitterNode?
    
    // MARK: – Initialisierung
    init() {
        // Lade den TextureAtlas "Hero" (bitte stelle sicher, dass alle Texturen vorhanden sind)
        let textureAtlas = SKTextureAtlas(named: "Hero")
        let initialTexture = textureAtlas.textureNamed("hero_idle1")
        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())
        
        // Setup der Animationen und Zustände
        setupIdleAnimations(with: textureAtlas)
        setupRunAnimations(with: textureAtlas)
        setupJumpAnimation(with: textureAtlas)
        setupAttackAnimations(with: textureAtlas)
        setupPhysics()
        setupLandingEmitter()
        
        // Setze initialen Zustand
        currentState = .running
        startRunning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let textureAtlas = SKTextureAtlas(named: "Hero")
        setupIdleAnimations(with: textureAtlas)
        setupRunAnimations(with: textureAtlas)
        setupJumpAnimation(with: textureAtlas)
        setupAttackAnimations(with: textureAtlas)
        setupPhysics()
        setupLandingEmitter()
        currentState = .running
        startRunning()
    }
    
    // MARK: – Setup der Animationen
    func setupIdleAnimations(with atlas: SKTextureAtlas) {
        idleFrames.removeAll()
        // Lade alle idle-Texturen (z. B. "hero_idle1", "hero_idle2", …)
        let textureNames = atlas.textureNames.filter { $0.hasPrefix("hero_idle") }
        let sortedNames = textureNames.sorted()
        for name in sortedNames {
            idleFrames.append(atlas.textureNamed(name))
        }
        // Wiederhole Kommentare:
        // Kommentar: Idle-Animationen lassen den Helden ruhen und kleinlebendig wirken.
        // Kommentar: Diese Animation wird verwendet, wenn keine Eingabe erfolgt.
        
        
        
    }
    
    func setupRunAnimations(with atlas: SKTextureAtlas) {
        runFrames.removeAll()
        let textureNames = atlas.textureNames.filter { $0.hasPrefix("hero_run") }
        let sortedNames = textureNames.sorted()
        for name in sortedNames {
            runFrames.append(atlas.textureNamed(name))
        }
    }
    
    func setupJumpAnimation(with atlas: SKTextureAtlas) {
        // Angenommen, es gibt nur ein Bild für den Sprung
        jumpFrame = atlas.textureNamed("hero_jump")
    }
    
    func setupAttackAnimations(with atlas: SKTextureAtlas) {
        attackFrames.removeAll()
        let textureNames = atlas.textureNames.filter { $0.hasPrefix("hero_attack") }
        let sortedNames = textureNames.sorted()
        for name in sortedNames {
            attackFrames.append(atlas.textureNamed(name))
        }
    }
    
    // MARK: – Setup der Physik
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.obstacle | GameScene.PhysicsCategory.powerUp | GameScene.PhysicsCategory.ground
        self.physicsBody?.collisionBitMask = GameScene.PhysicsCategory.ground | GameScene.PhysicsCategory.obstacle
    }
    
    // MARK: – Setup Landing Particles
    func setupLandingEmitter() {
        // Lade einen Partikel-Effekt für die Landung (z. B. "Landing.sks")
        if let emitter = SKEmitterNode(fileNamed: "Landing.sks") {
            landingEmitter = emitter
            landingEmitter?.zPosition = 5
            landingEmitter?.targetNode = self.parent
        }
    }
    
    // MARK: – Animationen starten
    func startIdle() {
        currentState = .idle
        self.removeAction(forKey: "running")
        let idleAction = SKAction.animate(with: idleFrames, timePerFrame: 0.2, resize: false, restore: true)
        let repeatIdle = SKAction.repeatForever(idleAction)
        self.run(repeatIdle, withKey: "idle")
    }
    
    func startRunning() {
        currentState = .running
        self.removeAction(forKey: "idle")
        self.removeAction(forKey: "jump")
        self.removeAction(forKey: "attack")
        let runAction = SKAction.animate(with: runFrames, timePerFrame: 0.1, resize: false, restore: true)
        let repeatRun = SKAction.repeatForever(runAction)
        self.run(repeatRun, withKey: "running")
    }
    
    func startAttack() {
        currentState = .attacking
        self.removeAction(forKey: "running")
        let attackAction = SKAction.animate(with: attackFrames, timePerFrame: 0.1, resize: false, restore: true)
        let completion = SKAction.run { [weak self] in
            self?.startRunning()
        }
        let sequence = SKAction.sequence([attackAction, completion])
        self.run(sequence, withKey: "attack")
    }
    
    // MARK: – Aktionen: Springen und Landen
    func jump() {
        // Nur springen, wenn der Held aktuell nicht springt
        if currentState != .jumping {
            currentState = .jumping
            self.removeAction(forKey: "running")
            self.texture = jumpFrame
            if let body = self.physicsBody, body.velocity.dy == 0 {
                body.applyImpulse(CGVector(dx: 0, dy: 350))
            }
        }
    }
    
    func landed() {
        // Blende den Landing-Partikeleffekt ein
        if let emitter = landingEmitter, let parent = self.parent {
            emitter.position = CGPoint(x: self.position.x, y: self.position.y - self.size.height / 2)
            parent.addChild(emitter)
            let wait = SKAction.wait(forDuration: 0.3)
            let remove = SKAction.run { emitter.removeFromParent() }
            emitter.run(SKAction.sequence([wait, remove]))
        }
        // Zustand wiederherstellen
        currentState = .running
        startRunning()
    }
    
    // MARK: – Update-Methode des Helden
    func update(deltaTime: TimeInterval) {
        // Aktualisiere den Heldenzustand
        // Prüfe, ob der Held invincible ist und aktualisiere den Timer
        if isInvincible {
            invincibleTimer += deltaTime
            if invincibleTimer >= invincibleDuration {
                isInvincible = false
                invincibleTimer = 0
                self.alpha = 1.0 // Sichtbar
            } else {
                // Blinke-Effekt während der Invincibility
                self.alpha = self.alpha == 1.0 ? 0.5 : 1.0
            }
        }
        
        // Hier können weitere Zustandsprüfungen erfolgen
        // Beispielsweise: Übergang von Springen zu Laufen, wenn der Held den Boden berührt
        
        // Wiederhole diesen Kommentarblock:
        // Kommentar: Die update(deltaTime:) Methode wird jeden Frame aufgerufen.
        // Kommentar: Hier werden Animationen, Partikeleffekte und Zustandsänderungen verwaltet.
        // Kommentar: Alle Logiken, die den Helden betreffen, sollten hier integriert werden.
        
        
        
    }
    
    // MARK: – Zusätzliche Aktionen und Spezialfähigkeiten
    func triggerSpecialMove() {
        // Beispiel für einen Spezialangriff, der den Helden kurzzeitig invincible macht
        currentState = .attacking
        isInvincible = true
        invincibleTimer = 0
        
        // Spiel eine spezielle Animation ab
        let specialAction = SKAction.sequence([
            SKAction.run { [weak self] in
                // Optional: Soundeffekt abspielen
                // self?.run(SKAction.playSoundFileNamed("special.wav", waitForCompletion: false))
            },
            SKAction.animate(with: attackFrames, timePerFrame: 0.08, resize: false, restore: true),
            SKAction.run { [weak self] in
                self?.startRunning()
            }
        ])
        self.run(specialAction, withKey: "special")
    }
    
    func takeDamage() {
        // Beispiel: Wenn der Held Schaden nimmt, wechsle in den "hit"-Zustand und spiele eine Animation
        currentState = .hit
        self.removeAllActions()
        // Setze den Held blinken (visueller Hinweis)
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        let blinkRepeat = SKAction.repeat(blink, count: 5)
        let completion = SKAction.run { [weak self] in
            self?.startRunning()
        }
        self.run(SKAction.sequence([blinkRepeat, completion]), withKey: "hit")
    }
    
    // MARK: – Erweiterte Debugging-Kommentare und Hilfsfunktionen
    func debugInfo() {
        // Zeige Debug-Informationen über den aktuellen Zustand
        print("Hero State: \(currentState)")
        print("Invincible: \(isInvincible) (Timer: \(invincibleTimer))")
    }
    
    // Wiederhole diesen Kommentarblock mehrfach:
    // Kommentar: Die Hero-Klasse ist zentral für das Spielerlebnis.
    // Kommentar: Sie vereint Animationen, Physik, Zustandsmanagement und Spezialeffekte.
    // Kommentar: Alle zukünftigen Erweiterungen (z. B. neue Bewegungen, Effekte) sollten hier integriert werden.
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
