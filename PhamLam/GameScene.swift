//
//  GameScene.swift
//  SwiftLearning Sesson 3
//
//  Created by Pham Lam on 2/27/17.

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Sprite
    let playerNode = SKSpriteNode(imageNamed: "player-1.png")
    let fly1 = SKSpriteNode(imageNamed: "fly-1-1.png")
    let fly2 = SKSpriteNode(imageNamed: "fly-1-1.png")
    let Margin : CGFloat = 20
    
    var scoreLabel : UILabel!
    var heathLabel : UILabel!
    var stageLabel : UILabel!
    
    
    var flyShootCount : Int = 0
    var fliesMoveCount : Int = 0
    
    var currentScore : Int = 0
    var playerHealth : Int = 10
    var fliesHealth2 : Int = 2
    var fliesHealth3 : Int = 3
    
    
    var stage : Double = 0
    var playerNumberOfBullet : Int = 1
    
    
    var playerBullet : [SKSpriteNode] = []
    var flies : [SKSpriteNode] = []
    var explosions : [SKSpriteNode] = []
    
    let PLAYER_BULLET_NAME = "Player bullet"
    let FLIES_NAME = "Flies Name"
    
    let fly1Texture1 = SKTexture(imageNamed: "fly-1-1.png")
    let fly1Texture2 = SKTexture(imageNamed: "fly-1-2.png")
    let fly2Texture1 = SKTexture(imageNamed: "fly-2-1.png")
    let fly2Texture2 = SKTexture(imageNamed: "fly-2-2.png")
    let fly3Texture1 = SKTexture(imageNamed: "fly-3-1.png")
    let fly3Texture2 = SKTexture(imageNamed: "fly-3-2.png")
    let fly3Texture3 = SKTexture(imageNamed: "fly-3-3.png")
    
    let explosionTexture0 = SKTexture(imageNamed: "explosion-0.png")
    let explosionTexture1 = SKTexture(imageNamed: "explosion-1.png")
    let explosionTexture2 = SKTexture(imageNamed: "explosion-2.png")
    let explosionTexture3 = SKTexture(imageNamed: "explosion-3.png")
    
    
    let spaceshipBack = SKEmitterNode(fileNamed: "spacship.sks")
    let playerAttackedSks = SKEmitterNode(fileNamed: "plahyerattacked.sks")
    
    let randomXPosition = GKRandomDistribution(lowestValue: 50, highestValue: Int(UIScreen.main.bounds.width) - 50)
    
    //textures -> images
    
    override func didMove(to view: SKView) {
        
        func addStarField() -> Void {
            if let starFieldNode = SKEmitterNode(fileNamed: "background.sks"){
                starFieldNode.position.y = self.size.height + 20
                starFieldNode.position.x = self.size.width / 2
                starFieldNode.zPosition = -100
                starFieldNode.particlePositionRange = CGVector(dx: self.size.width, dy: 0)
                addChild(starFieldNode)
            }
        }
        
        func addSpaceshipBackFire() -> Void {
            spaceshipBack?.position.y = playerNode.position.y
            spaceshipBack?.position.x = playerNode.position.x
            spaceshipBack?.particlePositionRange = CGVector(dx: 0.001, dy: 0.05)
            
            addChild(spaceshipBack!)
        }
        
        
        anchorPoint = CGPoint(x: 0, y: 0)
        configPhysics()
        addPlayer()
        addFlies()
        addStarField()
        addSpaceshipBackFire()
        
        scoreLabel = UILabel(frame: CGRect(x: 0, y: self.size.height - 20, width: 100, height: 20 ))
        scoreLabel.textColor = UIColor.red
        scoreLabel.text = "Score : \(currentScore)"
        self.view?.addSubview(scoreLabel)
        
        heathLabel = UILabel(frame: CGRect(x: 0 , y: self.size.height - 40, width: 100, height: 20))
        heathLabel.textColor = UIColor.blue
        heathLabel.text = "Heath : \(playerHealth)"
        self.view?.addSubview(heathLabel)
        
        stageLabel = UILabel(frame: CGRect(x: self.size.width - 110, y: self.size.height - 30, width: 100, height: 20))
        stageLabel.textColor = UIColor.green
        stageLabel.text = "Stage : \(stage)"
        self.view?.addSubview(stageLabel)
        
    }
    
    func configPhysics() -> Void {
        self.physicsWorld.gravity = CGVector(dx : 0, dy : 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        guard let nodeA = bodyA.node, let nodeB = bodyB.node else {
            return
        }
        
        if (bodyA.categoryBitMask | bodyB.categoryBitMask) == 3 {
            nodeA.removeFromParent()
            nodeB.removeFromParent()
            addExplosion(position: nodeA.position, size : 0.5, duration : 0.01)
            currentScore += 1
            scoreLabel.text = "Score : \(currentScore)"
        }
        
        if (bodyA.categoryBitMask | bodyB.categoryBitMask) == 12 {
            addExplosion(position: playerNode.position, size : 1, duration : 0.01  )
            playerNode.run(SKAction.playSoundFileNamed("player-explosion.wav", waitForCompletion: false))
            if playerHealth > 1 {
                playerHealth -= 1
                heathLabel.text = "Heatlh : \(playerHealth)"
            }else{
                heathLabel.text = "Health : 0"
                self.view?.presentScene(SKScene(fileNamed: "MyScene"))
            }
        }
        
        if (bodyA.categoryBitMask | bodyB.categoryBitMask) == 20 {
            addExplosion(position: playerNode.position, size : 1, duration : 0.01  )
            playerNode.run(SKAction.playSoundFileNamed("player-explosion.wav", waitForCompletion: false))
            
            if playerHealth > 2 {
                playerHealth -= 2
                heathLabel.text = "Heath : \(playerHealth)"
            }else{
                heathLabel.text = "Health : 0"
                self.view?.presentScene(SKScene(fileNamed: "MyScene"))
            }
        }
        
        if (bodyA.categoryBitMask | bodyB.categoryBitMask) == 36 {
            if playerNumberOfBullet < 7 {
                playerNumberOfBullet += 2
            }
            if bodyA.categoryBitMask == 32 {
                nodeA.removeFromParent()
            }else{
                nodeB.removeFromParent()
            }

        }
        
        if (bodyA.categoryBitMask | bodyB.categoryBitMask) == 65 {
            nodeA.removeFromParent()
            nodeB.removeFromParent()
            addExplosion(position: nodeA.position, size : 0.5, duration : 0.01)
            currentScore += 2
            scoreLabel.text = "Score : \(currentScore)"
        }
        
        if (bodyA.categoryBitMask | bodyB.categoryBitMask) == 129 {
            nodeA.removeFromParent()
            nodeB.removeFromParent()
            addExplosion(position: nodeA.position, size : 0.5, duration : 0.01)
            currentScore += 3
            scoreLabel.text = "Score : \(currentScore)"
        }
    }
    
    func addExplosion(position: CGPoint, size : CGFloat, duration : TimeInterval) -> Void{
        let explosionNode = SKSpriteNode(imageNamed: "explosion-0.png")
        explosionNode.position = position
        let animationAction = SKAction.animate(with: [explosionTexture0, explosionTexture1, explosionTexture2, explosionTexture3], timePerFrame: 0.05)
        explosionNode.run(.sequence([.scale(by: size, duration: duration), animationAction, .removeFromParent()]))
        addChild(explosionNode)
    }
    
    func addPlayer() -> Void {
        playerNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        playerNode.size = CGSize(width: self.size.width * 0.05, height: self.size.height * 0.05)
        playerNode.position = CGPoint(x: self.size.width/2, y: 20)
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerNode.size)
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.categoryBitMask = 4
        playerNode.physicsBody?.contactTestBitMask = 8
        addChild(playerNode)
    }
    
    func addFlies() -> Void {

        let flyNode = SKSpriteNode(imageNamed: "fly-1-1")
        let randomPosition = CGFloat(randomXPosition.nextInt())
        
        flyNode.position = CGPoint(x: randomPosition, y: self.size.height)
        flyNode.physicsBody = SKPhysicsBody(rectangleOf: flyNode.size)
        flyNode.physicsBody?.velocity = CGVector(dx: 0, dy: -50)
        flyNode.physicsBody?.collisionBitMask = 0
        flyNode.physicsBody?.linearDamping = 0
        flyNode.physicsBody?.categoryBitMask = 2
        flyNode.physicsBody?.contactTestBitMask = 1
        
        flyNode.run(.repeatForever(.animate(with: [fly1Texture1, fly1Texture2], timePerFrame: 0.1)))
        flyNode.run(SKAction.playSoundFileNamed("attack-1.wav", waitForCompletion: false))
        addChild(flyNode)
        flies.append(flyNode)
        
    }
    
    func addFlies2() -> Void {
        let flyNode = SKSpriteNode(imageNamed: "fly-2-1")
        let randomPosition = CGFloat(randomXPosition.nextInt())
        
        flyNode.position = CGPoint(x: randomPosition, y: self.size.height)
        flyNode.physicsBody = SKPhysicsBody(rectangleOf: flyNode.size)
        flyNode.physicsBody?.velocity = CGVector(dx: 0, dy: -50)
        flyNode.physicsBody?.collisionBitMask = 0
        flyNode.physicsBody?.linearDamping = 0
        flyNode.physicsBody?.categoryBitMask = 64
        flyNode.physicsBody?.contactTestBitMask = 1
        
        flyNode.run(.repeatForever(.animate(with: [fly2Texture1, fly2Texture2], timePerFrame: 0.1)))
        flyNode.run(SKAction.playSoundFileNamed("attack-1.wav", waitForCompletion: false))
        addChild(flyNode)
        flies.append(flyNode)
    }
    
    func addFlies3() -> Void {
        let flyNode = SKSpriteNode(imageNamed: "fly-3-1")
        let randomPosition = CGFloat(randomXPosition.nextInt())
        
        flyNode.position = CGPoint(x: randomPosition, y: self.size.height)
        flyNode.physicsBody = SKPhysicsBody(rectangleOf: flyNode.size)
        flyNode.physicsBody?.velocity = CGVector(dx: 0, dy: -50)
        flyNode.physicsBody?.collisionBitMask = 0
        flyNode.physicsBody?.linearDamping = 0
        flyNode.physicsBody?.categoryBitMask = 128
        flyNode.physicsBody?.contactTestBitMask = 1
        
        flyNode.run(.repeatForever(.animate(with: [fly3Texture1, fly3Texture2, fly3Texture3, fly3Texture2], timePerFrame: 0.1)))
        flyNode.run(SKAction.playSoundFileNamed("attack-1.wav", waitForCompletion: false))
        addChild(flyNode)
        flies.append(flyNode)
    }
    
    func fliesMove(fly : SKSpriteNode, time : Int) {
        if time % 2 == 0 {
            fly.physicsBody?.velocity = CGVector(dx: 50, dy: -80)
        }else{
            fly.physicsBody?.velocity = CGVector(dx: -50, dy: -80)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let  firstTouch = touches.first {
            let location = firstTouch.location(in: self)
            playerNode.position.x = location.x
            spaceshipBack?.position.x = location.x
        }
        
    }
    
    var startTime : TimeInterval = -1
    var fliesStartTime : TimeInterval = -1
    var fliesMoveTime : TimeInterval = -1
    var fallenTime : TimeInterval = -1
    var addMoreBulletTime : TimeInterval = -1
    var score : Int = 0
    
    
    
    override func update(_ currentTime: TimeInterval) {
        if startTime == -1 {
            currentScore = 0
            score = 0
            stage = 1
            startTime = currentTime
            fliesStartTime = currentTime
            fliesMoveTime = currentTime
            fallenTime = currentTime
            addMoreBulletTime = currentTime
            stageLabel.text = "Stage : 1"
        }
        if (currentScore - score) > 20 {
            score = currentScore
            stage += 1
            stageLabel.text = "Stage : \(stage)"
        }
        if (currentTime - addMoreBulletTime) > 20 {
            addMoreBullet()
            addMoreBulletTime = currentTime
        }
        
        if Double((currentTime - fallenTime)) > Double(10 - (0.5 * stage)) {
            addFallenMeteorite()
            fallenTime = currentTime
        }
        
        if Double(currentTime - fliesStartTime) > Double(1 - (0.05 * stage)) {
            if stage < 4 {
                addFlies()
                fliesStartTime = currentTime
            }else if stage < 8{
                addFlies()
                addFlies2()
                fliesStartTime = currentTime
            }else{
                addFlies()
                addFlies2()
                addFlies3()
                fliesStartTime = currentTime
            }
        }
        
        if currentTime - fliesMoveTime > 0.7 {
            fliesMoveCount += 1
            for fly in self.flies {
                if ((fly.position.x - 100) > 0 || (fly.position.x + 100) < self.size.width) {
                    fliesMove(fly: fly, time: fliesMoveCount)
                }
            }
            fliesMoveTime = currentTime
        }
        
        if currentTime - startTime > 0.5{
            shoot(number: playerNumberOfBullet)
            flyShootCount += 1
            if (flyShootCount % 6) == 0 {
                for fly in self.flies {
                    if fly.parent != nil {
                        flyShoot(fly: fly)
                    }
                }
            }
            startTime = currentTime
        }
        
        self.enumerateChildNodes(withName: PLAYER_BULLET_NAME) {
            node, pointer in
            if node.position.y > self.size.height || node.position.y < 0{
                node.removeFromParent()
            }
        }
        
        self.enumerateChildNodes(withName: FLIES_NAME){
            node, pointer in
            if node.position.y < 0{
                node.position = CGPoint(x: node.position.x, y: node.position.y + self.size.height)
            }
        }
    }
    
    func shoot(number : Int) -> Void {
        for index in 1...number {
            let bulletNode = SKSpriteNode(imageNamed: "bullet-1.png")
            let mid = ((number - 1) / 2) + 1
            
            
            bulletNode.name = PLAYER_BULLET_NAME
            bulletNode.position = CGPoint(x: playerNode.position.x, y: playerNode.position.y + playerNode.size.height)
            bulletNode.physicsBody = SKPhysicsBody(rectangleOf: bulletNode.size)
            bulletNode.physicsBody?.velocity = CGVector(dx: -300 + (300 / mid) * index, dy: 400)
            bulletNode.physicsBody?.categoryBitMask = 1
            bulletNode.physicsBody?.contactTestBitMask = 2
            bulletNode.physicsBody?.collisionBitMask = 0
            bulletNode.physicsBody?.mass = 0
            bulletNode.run(SKAction.playSoundFileNamed("player-shoot.wav", waitForCompletion: false))
            addChild(bulletNode)
            playerBullet.append(bulletNode)
        }
        
    }
    
    func flyShoot(fly : SKSpriteNode) -> Void {
        let bulletNode = SKSpriteNode(imageNamed: "bullet-2.png")
        bulletNode.name = PLAYER_BULLET_NAME
        bulletNode.zRotation = CGFloat(M_PI)
        //anchor + position
        bulletNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        bulletNode.size = CGSize(width: self.size.width * 0.02, height: self.size.height * 0.02)
        bulletNode.position = CGPoint(x: fly.position.x, y: fly.position.y - fly.size.height/2 )
        bulletNode.physicsBody = SKPhysicsBody(rectangleOf: bulletNode.size)
        bulletNode.physicsBody?.collisionBitMask = 0
        //        bulletNode.run(SKAction.move(to: CGPoint(x : playerNode.position.x, y : playerNode.position.y - 40 ), duration : 1 ))
        bulletNode.physicsBody?.velocity = CGVector(dx: 0, dy: -200 )
        bulletNode.physicsBody?.mass = 0
        bulletNode.physicsBody?.categoryBitMask = 8
        bulletNode.physicsBody?.contactTestBitMask = 4
        bulletNode.run(SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false))
        addChild(bulletNode)
    }
    
    func addFallenMeteorite() -> Void {
        let warning = SKSpriteNode(imageNamed: "warning")
        let meteorite = SKEmitterNode(fileNamed: "meteorite.sks")
        
        let randomPosition = CGFloat(randomXPosition.nextInt())
        
        warning.anchorPoint = CGPoint(x: 0.5, y: 1)
        warning.position = CGPoint(x: randomPosition, y: self.size.height - 5)
        
        warning.size = CGSize(width: self.size.width * 0.08, height: self.size.height * 0.05)
        
        let warningAction = SKAction.sequence([.scale(by: 0.5, duration: 0.25), .wait(forDuration: 0.25), .scale(by: 2, duration: 0.25), .wait(forDuration: 0.25)])
        
        meteorite?.position = CGPoint(x: warning.position.x, y: self.size.height + 50)
        meteorite?.particleSize = CGSize(width: self.size.width * 0.05, height: self.size.height * 0.05)
        meteorite?.physicsBody = SKPhysicsBody(rectangleOf: (meteorite?.particleSize)!)
        //        meteorite?.physicsBody?.velocity = CGVector(dx: 0, dy: -1000)
        meteorite?.physicsBody?.collisionBitMask = 0
        meteorite?.physicsBody?.isDynamic = true
        meteorite?.physicsBody?.categoryBitMask = 16
        meteorite?.physicsBody?.contactTestBitMask = 4
        
        warning.run(SKAction.sequence([warningAction, warningAction, warningAction, .removeFromParent()]))
        meteorite?.run(SKAction.sequence([.wait(forDuration: 3), .move(to: CGPoint(x: warning.position.x, y: -50), duration: 2), .removeFromParent()]))
        addChild(warning)
        addChild(meteorite!)
    }
    
    func addMoreBullet() -> Void {
        let bulletAppend = SKSpriteNode(imageNamed: "bulletappend")
        
        bulletAppend.position = CGPoint(x: CGFloat(randomXPosition.nextInt()), y: (self.size.height + 50))
        bulletAppend.size = CGSize(width: self.size.width * 0.03, height: self.size.height * 0.03)
        bulletAppend.physicsBody = SKPhysicsBody(rectangleOf: bulletAppend.size)
        bulletAppend.physicsBody?.collisionBitMask = 0
        bulletAppend.physicsBody?.isDynamic = true
        bulletAppend.physicsBody?.categoryBitMask = 32
        bulletAppend.physicsBody?.contactTestBitMask = 4
        
        bulletAppend.run(SKAction.sequence([.move(to: playerNode.position, duration: 4), .removeFromParent()]))
        addChild(bulletAppend)
    }
    
}
