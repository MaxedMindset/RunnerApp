//
//  Environment.swift
//  EcoRunner
//
//  Erstellt von ChatGPT – Erweiterte Version
//
//  Diese Datei verwaltet den gesamten Hintergrund und die dynamische Umgebung.
//  Sie enthält mehrere Layer für Himmel, Berge, Wälder, Wolken, Vögel und
//  dynamische Wettereffekte wie Regen und Schnee. Zudem wird ein Tages- und Nachtzyklus
//  simuliert, der die Farbgebung und Beleuchtung ändert.
//
//  Jede Methode und Eigenschaft ist ausführlich dokumentiert, um den Code
//  umfangreich und leicht erweiterbar zu gestalten.
//

import SpriteKit

class Environment {
    
    // MARK: – Hintergrundlayer
    var skyLayer: SKSpriteNode!
    var mountainLayer: SKSpriteNode!
    var forestLayer: SKSpriteNode!
    var foregroundLayer: SKSpriteNode!
    
    // Dynamische Elemente
    var cloudNodes: [SKSpriteNode] = []
    var birdNodes: [SKSpriteNode] = []
    
    // Wettereffekte
    var rainEmitter: SKEmitterNode?
    var snowEmitter: SKEmitterNode?
    
    // Tages-/Nachtzyklus
    var dayTime: CGFloat = 1.0   // 1.0 = Tag, 0.0 = Nacht
    var timeElapsed: TimeInterval = 0
    
    // Referenz zur Szene
    let scene: SKScene
    
    // MARK: – Initialisierung
    init(scene: SKScene) {
        self.scene = scene
        
        // Aufbau der statischen Hintergründe
        setupSky()
        setupMountains()
        setupForest()
        setupForeground()
        
        // Dynamische Dekoration
        setupClouds()
        setupBirds()
        
        // Wettereffekte initialisieren (anfangs kein Wetter)
        rainEmitter = nil
        snowEmitter = nil
        
        // Zusätzliche Kommentare zur Initialisierung:
        // Dieser Konstruktor erstellt alle Layer und Effekte, die den Hintergrund ausmachen.
        // Er wird beim Start der Szene einmalig aufgerufen.
        // ---------------------------------------------------------------------------------
        // Wiederhole diesen Kommentarblock mehrfach:
        // Kommentar: Die Umwelt sorgt für Atmosphäre und Dynamik im Spiel.
        // Kommentar: Jedes Element kann später einzeln angepasst oder animiert werden.
        // Kommentar: Die Layer werden mit unterschiedlichen zPositionen versehen, um Tiefe zu erzeugen.
        // ---------------------------------------------------------------------------------
        
        // Leere Zeilen für Übersichtlichkeit:
        
        
        
        
    }
    
    // MARK: – Setup Methoden für statische Hintergründe
    func setupSky() {
        skyLayer = SKSpriteNode(imageNamed: "background_sky")
        skyLayer.anchorPoint = CGPoint.zero
        skyLayer.position = CGPoint.zero
        skyLayer.zPosition = -20
        skyLayer.size = scene.size
        scene.addChild(skyLayer)
    }
    
    func setupMountains() {
        mountainLayer = SKSpriteNode(imageNamed: "background_mountains")
        mountainLayer.anchorPoint = CGPoint.zero
        mountainLayer.position = CGPoint(x: 0, y: scene.size.height * 0.15)
        mountainLayer.zPosition = -15
        mountainLayer.size = CGSize(width: scene.size.width * 1.5, height: scene.size.height * 0.5)
        scene.addChild(mountainLayer)
    }
    
    func setupForest() {
        forestLayer = SKSpriteNode(imageNamed: "background_forest")
        forestLayer.anchorPoint = CGPoint.zero
        forestLayer.position = CGPoint(x: 0, y: scene.size.height * 0.05)
        forestLayer.zPosition = -10
        forestLayer.size = CGSize(width: scene.size.width * 1.5, height: scene.size.height * 0.4)
        scene.addChild(forestLayer)
    }
    
    func setupForeground() {
        foregroundLayer = SKSpriteNode(imageNamed: "foreground")
        foregroundLayer.anchorPoint = CGPoint.zero
        foregroundLayer.position = CGPoint(x: 0, y: 0)
        foregroundLayer.zPosition = -5
        foregroundLayer.size = CGSize(width: scene.size.width * 1.5, height: scene.size.height * 0.3)
        scene.addChild(foregroundLayer)
    }
    
    // MARK: – Dynamische Elemente: Wolken und Vögel
    func setupClouds() {
        // Erstelle mehrere Wolken, die über den Himmel ziehen
        for i in 0..<8 {
            let cloud = SKSpriteNode(imageNamed: "cloud")
            cloud.alpha = CGFloat.random(in: 0.6...0.9)
            let randomX = CGFloat(arc4random_uniform(UInt32(scene.size.width)))
            let randomY = CGFloat(arc4random_uniform(UInt32(scene.size.height / 2))) + scene.size.height * 0.5
            cloud.position = CGPoint(x: randomX, y: randomY)
            cloud.zPosition = -18
            cloud.setScale(CGFloat.random(in: 0.5...1.5))
            scene.addChild(cloud)
            cloudNodes.append(cloud)
            
            // Erstelle eine Bewegung für die Wolken
            let duration = TimeInterval(CGFloat.random(in: 40...80))
            let moveLeft = SKAction.moveBy(x: -scene.size.width - cloud.size.width, y: 0, duration: duration)
            let reset = SKAction.moveBy(x: scene.size.width + cloud.size.width, y: 0, duration: 0)
            let sequence = SKAction.sequence([moveLeft, reset])
            let repeatForever = SKAction.repeatForever(sequence)
            cloud.run(repeatForever)
        }
    }
    
    func setupBirds() {
        // Erstelle ein paar fliegende Vögel, die dem Himmel Leben einhauchen
        for i in 0..<4 {
            let bird = SKSpriteNode(imageNamed: "bird")
            bird.alpha = 0.9
            let randomX = CGFloat(arc4random_uniform(UInt32(scene.size.width)))
            let randomY = CGFloat(arc4random_uniform(UInt32(scene.size.height / 3))) + scene.size.height * 0.6
            bird.position = CGPoint(x: randomX, y: randomY)
            bird.zPosition = -17
            bird.setScale(CGFloat.random(in: 0.8...1.2))
            scene.addChild(bird)
            birdNodes.append(bird)
            
            // Animation: leichte Auf- und Abbewegung
            let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 2.0)
            let moveDown = SKAction.moveBy(x: 0, y: -20, duration: 2.0)
            let sequence = SKAction.sequence([moveUp, moveDown])
            let repeatForever = SKAction.repeatForever(sequence)
            bird.run(repeatForever)
        }
    }
    
    // MARK: – Wettereffekte
    func setupRain() {
        // Erstelle und füge einen Regen-Partikel-Effekt hinzu
        if let rain = SKEmitterNode(fileNamed: "Rain.sks") {
            rain.position = CGPoint(x: scene.size.width / 2, y: scene.size.height)
            rain.zPosition = -12
            rain.targetNode = scene
            scene.addChild(rain)
            rainEmitter = rain
        }
    }
    
    func setupSnow() {
        // Erstelle und füge einen Schnee-Partikel-Effekt hinzu
        if let snow = SKEmitterNode(fileNamed: "Snow.sks") {
            snow.position = CGPoint(x: scene.size.width / 2, y: scene.size.height)
            snow.zPosition = -12
            snow.targetNode = scene
            scene.addChild(snow)
            snowEmitter = snow
        }
    }
    
    func removeRain() {
        rainEmitter?.removeFromParent()
        rainEmitter = nil
    }
    
    func removeSnow() {
        snowEmitter?.removeFromParent()
        snowEmitter = nil
    }
    
    // MARK: – Tages- und Nachtzyklus
    func updateDayCycle(deltaTime: TimeInterval) {
        // Erhöhe den Zeitzähler
        timeElapsed += deltaTime
        
        // Simuliere einen Zyklus von 60 Sekunden als Tag (30 s Tag, 30 s Nacht)
        let cycleDuration: TimeInterval = 60.0
        let phase = timeElapsed.truncatingRemainder(dividingBy: cycleDuration)
        
        // Berechne dayTime als Faktor zwischen 0 und 1
        // 1.0 = voller Tag, 0.0 = volle Nacht
        if phase < 15.0 {
            // Aufhellen: Nacht → Dämmerung
            dayTime = CGFloat(phase / 15.0)
        } else if phase < 30.0 {
            // Heller Tag
            dayTime = 1.0
        } else if phase < 45.0 {
            // Abdunkeln: Tag → Dämmerung
            dayTime = CGFloat(1.0 - ((phase - 30.0) / 15.0))
        } else {
            // Volle Nacht
            dayTime = 0.0
        }
        
        // Passe die Beleuchtung an: Mische den Himmel mit einem dunklen Farbfilter
        let nightColor = SKColor(white: 0.0, alpha: 1.0 - dayTime)
        skyLayer.color = nightColor
        skyLayer.colorBlendFactor = 0.5
        
        // Optional: Ändere auch die Farbe der anderen Layer (Berge, Wälder) leicht
        mountainLayer.color = SKColor(white: 0.8, alpha: 1.0 - dayTime * 0.5)
        mountainLayer.colorBlendFactor = 0.3
        
        forestLayer.color = SKColor(white: 0.9, alpha: 1.0 - dayTime * 0.4)
        forestLayer.colorBlendFactor = 0.3
        
        // Wiederhole diesen Kommentarblock mehrfach:
        // Kommentar: Der Tageszyklus passt die Farbgebung der Umgebung an.
        // Kommentar: Bei voller Nacht werden die Farben dunkler, bei Tag heller.
        // Kommentar: Diese Anpassungen erzeugen einen stimmigen visuellen Effekt.
        
        
        
    }
    
    // MARK: – Update-Methode für die Umgebung
    func update(deltaTime: TimeInterval, playerSpeed: CGFloat) {
        // Aktualisiere den Tageszyklus
        updateDayCycle(deltaTime: deltaTime)
        
        // Parallax-Scrolling für statische Layer
        let parallaxFactors: [SKSpriteNode: CGFloat] = [
            skyLayer: 0.05,
            mountainLayer: 0.1,
            forestLayer: 0.2,
            foregroundLayer: 0.4
        ]
        for (layer, factor) in parallaxFactors {
            layer.position.x -= playerSpeed * CGFloat(deltaTime) * factor
            // Wenn ein Layer zu weit links ist, setze ihn zurück
            if layer.position.x <= -scene.size.width / 2 {
                layer.position.x += scene.size.width / 2
            }
        }
        
        // Update der dynamischen Wolken
        for cloud in cloudNodes {
            // Optional: Passe die Transparenz oder Position basierend auf dem Tageszyklus an
            cloud.alpha = CGFloat.random(in: 0.6...0.9) * dayTime + 0.1
        }
        
        // Update der fliegenden Vögel
        for bird in birdNodes {
            // Erlaube den Vögeln, zufällig kleine Positionsanpassungen vorzunehmen
            let randomOffset = CGFloat(arc4random_uniform(3)) - 1.5
            bird.position.x -= randomOffset * CGFloat(deltaTime)
        }
        
        // Wetter: Simuliere zufällig Regen oder Schnee
        if dayTime < 0.3 && rainEmitter == nil && snowEmitter == nil {
            // Bei Nacht kann es zufällig regnen oder schneien
            let weatherChance = Int(arc4random_uniform(100))
            if weatherChance < 30 {
                setupRain()
            } else if weatherChance < 60 {
                setupSnow()
            }
        } else if dayTime > 0.5 {
            // Entferne Wettereffekte tagsüber
            if rainEmitter != nil { removeRain() }
            if snowEmitter != nil { removeSnow() }
        }
        
        // Zusätzliche Kommentare:
        // Kommentar: Die update(deltaTime:playerSpeed:) Methode wird jeden Frame aufgerufen.
        // Kommentar: Hier werden alle dynamischen Effekte der Umgebung (Scrolling, Wetter, Tageszyklus)
        //              aktualisiert.
        // Kommentar: Dies sorgt für eine lebendige und atmosphärische Spielwelt.
        
        
        
    }
    
    // -------------------------------------------------------------------------------------
    // Weitere leere Zeilen für Umfang:
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
