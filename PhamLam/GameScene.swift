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
    
    var flyShootCount : Int = 0
    var fliesMoveCount : Int = 0
    
    var score : Int = 0
    var playerHealth : Int = 10
    
    var playerBullet : [SKSpriteNode] = []
    var flies : [SKSpriteNode] = []
    var explosions : [SKSpriteNode] = []
    
    let PLAYER_BULLET_NAME = "Player bullet"
    let FLIES_NAME = "Flies Name"
    
    let fly1Texture1 = SKTexture(imageNamed: "fly-1-1.png")
    let fly1Texture2 = SKTexture(imageNamed: "fly-1-2.png")
    let explosionTexture0 = SKTexture(imageNamed: "explosion-0.png")
    let explosionTexture1 = SKTexture(imageNamed: "explosion-1.png")
    let explosionTexture2 = SKTexture(imageNamed: "explosion-2.png")
    let explosionTexture3 = SKTexture(imageNamed: "explosion-3.png")
    
    
    let spaceshipBack = SKEmitterNode(fileNamed: "spacship.sks")
    let playerAttackedSks = SKEmitterNode(fileNamed: "plahyerattacked.sks")
    
    
    
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
        scoreLabel.text = "Score : \(score)"
        self.view?.addSubview(scoreLabel)
        
        heathLabel = UILabel(frame: CGRect(x: 0 , y: self.size.height - 40, width: 100, height: 20))
        heathLabel.textColor = UIColor.blue
        heathLabel.text = "Heath : \(playerHealth)"
        self.view?.addSubview(heathLabel)
        
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
            score += 1
            scoreLabel.text = "Score : \(score)"
        }
        
        if (bodyA.categoryBitMask | bodyB.categoryBitMask) == 12 {
            addExplosion(position: playerNode.position, size : 1, duration : 0.01  )
            playerNode.run(SKAction.playSoundFileNamed("player-explosion.wav", waitForCompletion: false))
            if playerHealth > 1 {
                playerHealth -= 1
                heathLabel.text = "Heath : \(playerHealth)"
            }else{
                heathLabel.text = "Heath : 0"
                self.view?.presentScene(SKScene(fileNamed: "MyScene"))
            }
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
        playerNode.physicsBody?.categoryBitMask = 4 //1000
        playerNode.physicsBody?.contactTestBitMask = 8
        addChild(playerNode)
    }
    
    func addFlies() -> Void {
        //        let flyWidth : CGFloat = 28
        //        let flySpace : CGFloat = 10
        //        let flyMid : CGFloat = size.width / 2
        //        let random = Int(arc4random_uniform(UInt32(7)))
        //        var sp : Int = 0
        //
        //        if (random % 2) == 0 {
        //            sp = random / 2
        //        }else{
        //            sp = ((random - 1) / 2) + 1
        //        }
        //        for flyIndex in 0...random{
        //            let SPACE : CGFloat = flyWidth + flySpace
        //            let flyX : CGFloat = flyMid + (CGFloat(flyIndex) - CGFloat(sp)) * SPACE
        //            let flyY : CGFloat = self.size.height - 5
        //            let flyNode = SKSpriteNode(imageNamed: "fly-1-1.png")
        //            flyNode.name = FLIES_NAME
        //            flyNode.anchorPoint = CGPoint(x : 0.5, y : 1)
        //            flyNode.position = CGPoint(x: flyX , y: flyY )
        //            flyNode.physicsBody = SKPhysicsBody(rectangleOf: flyNode.size)
        //            flyNode.physicsBody?.velocity = CGVector(dx: 0, dy: -50)
        //            flyNode.physicsBody?.collisionBitMask = 0
        //            flyNode.physicsBody?.linearDamping = 0
        //            flyNode.physicsBody?.categoryBitMask = 2 //000010
        //            flyNode.physicsBody?.contactTestBitMask = 1
        //
        //            flyNode.run(.repeatForever(.animate(with: [fly1Texture1, fly1Texture2], timePerFrame: 0.1)))
        //            addChild(flyNode)
        //            flies.append(flyNode)
        //        }
        let flyNode = SKSpriteNode(imageNamed: "fly-1-1")
        let randomFlyPosition = GKRandomDistribution(lowestValue: 50, highestValue: Int(self.size.width) - 50)
        let flyPosition = CGFloat(randomFlyPosition.nextInt())
        
        flyNode.position = CGPoint(x: flyPosition, y: self.size.height)
        flyNode.physicsBody = SKPhysicsBody(rectangleOf: flyNode.size)
        flyNode.physicsBody?.velocity = CGVector(dx: 0, dy: -50)
        flyNode.physicsBody?.collisionBitMask = 0
        flyNode.physicsBody?.linearDamping = 0
        flyNode.physicsBody?.categoryBitMask = 2 //000010
        flyNode.physicsBody?.contactTestBitMask = 1
        
        flyNode.run(.repeatForever(.animate(with: [fly1Texture1, fly1Texture2], timePerFrame: 0.1)))
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
    
    
    override func update(_ currentTime: TimeInterval) {
        if startTime == -1 {
            score = 0
            startTime = currentTime
            fliesStartTime = currentTime
            fliesMoveTime = currentTime
        }
        
        if currentTime - fliesStartTime > 1 {
            addFlies()
            fliesStartTime = currentTime
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
            shoot()
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
    
    func shoot() -> Void {
        let bulletNode = SKSpriteNode(imageNamed: "bullet-1.png")
        bulletNode.name = PLAYER_BULLET_NAME
        bulletNode.position = CGPoint(x: playerNode.position.x, y: playerNode.position.y + playerNode.size.height)
        bulletNode.physicsBody = SKPhysicsBody(rectangleOf: bulletNode.size)
        bulletNode.physicsBody?.categoryBitMask = 1
        bulletNode.physicsBody?.contactTestBitMask = 2
        bulletNode.physicsBody?.collisionBitMask = 0
        bulletNode.physicsBody?.velocity = CGVector(dx: 0 , dy: 400)
        bulletNode.physicsBody?.mass = 0
        bulletNode.run(SKAction.playSoundFileNamed("player-shoot.wav", waitForCompletion: false))
        addChild(bulletNode)
        playerBullet.append(bulletNode)
        
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
}
