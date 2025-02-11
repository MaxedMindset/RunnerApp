//
//  Hero.swift
//  EcoRunner
//
//  Erstellt von ChatGPT – Erweiterte Version
//
//  Diese Klasse definiert den spielbaren Helden mit mehreren Animationszuständen,
//  Partikeleffekten, Spezialfähigkeiten und einem Zustandsautomaten.
//

import SpriteKit

enum HeroState {
    case idle, running, jumping, attacking, hit
}

class Hero: SKSpriteNode {
    
    // MARK: – Eigenschaften für Animationen und Zustände
    var idleFrames: [SKTexture] = []
    var runFrames: [SKTexture] = []
    var jumpFrame: SKTexture!
    var attackFrames: [SKTexture] = []
    
    var currentState: HeroState = .idle
    
    // Invincibility
    var isInvincible: Bool = false
    var invincibleDuration: TimeInterval = 1.5
    var invincibleTimer: TimeInterval = 0
    
    // Partikel bei Landung
    var landingEmitter: SKEmitterNode?
    
    // MARK: – Initialisierung
    init() {
        let textureAtlas = SKTextureAtlas(named: "Hero")
        let initialTexture = textureAtlas.textureNamed("hero_idle1")
        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())
        setupIdleAnimations(with: textureAtlas)
        setupRunAnimations(with: textureAtlas)
        setupJumpAnimation(with: textureAtlas)
        setupAttackAnimations(with: textureAtlas)
        setupPhysics()
        setupLandingEmitter()
        
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
        let textureNames = atlas.textureNames.filter { $0.hasPrefix("hero_idle") }
        let sortedNames = textureNames.sorted()
        for name in sortedNames {
            idleFrames.append(atlas.textureNamed(name))
        }
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
    
    // MARK: – Physik Setup
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.obstacle | GameScene.PhysicsCategory.powerUp | GameScene.PhysicsCategory.ground
        self.physicsBody?.collisionBitMask = GameScene.PhysicsCategory.ground | GameScene.PhysicsCategory.obstacle
    }
    
    // MARK: – Landing Emitter
    func setupLandingEmitter() {
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
        let completion = SKAction.run { [weak self] in self?.startRunning() }
        let sequence = SKAction.sequence([attackAction, completion])
        self.run(sequence, withKey: "attack")
    }
    
    // MARK: – Springen und Landen
    func jump() {
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
        if let emitter = landingEmitter, let parent = self.parent {
            emitter.position = CGPoint(x: self.position.x, y: self.position.y - self.size.height / 2)
            parent.addChild(emitter)
            let wait = SKAction.wait(forDuration: 0.3)
            let remove = SKAction.run { emitter.removeFromParent() }
            emitter.run(SKAction.sequence([wait, remove]))
        }
        currentState = .running
        startRunning()
    }
    
    // MARK: – Update-Methode
    func update(deltaTime: TimeInterval) {
        if isInvincible {
            invincibleTimer += deltaTime
            if invincibleTimer >= invincibleDuration {
                isInvincible = false
                invincibleTimer = 0
                self.alpha = 1.0
            } else {
                self.alpha = self.alpha == 1.0 ? 0.5 : 1.0
            }
        }
        // Weitere Zustandsprüfungen und Speziallogik können hier ergänzt werden.
    }
    
    // MARK: – Spezialfähigkeiten
    func triggerSpecialMove() {
        currentState = .attacking
        isInvincible = true
        invincibleTimer = 0
        let specialAction = SKAction.sequence([
            SKAction.run { /* Optional: Sound abspielen */ },
            SKAction.animate(with: attackFrames, timePerFrame: 0.08, resize: false, restore: true),
            SKAction.run { self.startRunning() }
        ])
        self.run(specialAction, withKey: "special")
    }
    
    func takeDamage() {
        currentState = .hit
        self.removeAllActions()
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        let blinkRepeat = SKAction.repeat(blink, count: 5)
        let completion = SKAction.run { self.startRunning() }
        self.run(SKAction.sequence([blinkRepeat, completion]), withKey: "hit")
    }
    
    // Zusätzliche Debugging-Kommentare:
    // Diese Klasse vereint Animation, Physik, Zustandsverwaltung und Spezialeffekte.
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
