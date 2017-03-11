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
    
    
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0, y: 0)
        configPhysics()
        addPlayer()
        addFlies()
        
        scoreLabel = UILabel(frame: CGRect(x: 0, y: self.size.height - 20, width: 100, height: 20 ))
        scoreLabel.textColor = UIColor.red
        scoreLabel.text = "Score : \(score)"
        self.view?.addSubview(scoreLabel)
        
        heathLabel = UILabel(frame: CGRect(x: 0 , y: self.size.height - 40, width: 100, height: 20))
        heathLabel.textColor = UIColor.blue
        heathLabel.text = "Heath : \(playerHealth)"
        self.view?.addSubview(heathLabel)
        
    }
    
    func addPlayer() -> Void {
        playerNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        playerNode.size = CGSize(width: self.size.width * 0.05, height: self.size.height * 0.05)
        playerNode.position = CGPoint(x: self.size.width/2, y: 0)
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerNode.size)
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.categoryBitMask = 4 //1000
        playerNode.physicsBody?.contactTestBitMask = 5
        addChild(playerNode)
    }
    
    func configPhysics() -> Void {
        self.physicsWorld.gravity = CGVector(dx : 0, dy : 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        let nodeA = bodyA.node
        let nodeB = bodyB.node
        
        if (bodyA.categoryBitMask | bodyB.categoryBitMask) == 3 {
            nodeA?.removeFromParent()
            nodeB?.removeFromParent()
            score += 1
            scoreLabel.text = "Score : \(score)"
        }
        
        if (bodyA.categoryBitMask | bodyB.categoryBitMask) == 5 {
            if playerHealth > 1 {
                playerHealth -= 1
                heathLabel.text = "Heath : \(playerHealth)"
            }else{
                playerHealth -= 1
                heathLabel.text = "Heath : \(playerHealth)"
                self.view?.presentScene(SKScene(fileNamed: "MyScene"))
            }
        }
    }
    
    let FLIES_NAME = "Flies Name"
    
    func addFlies() -> Void {
        let flyWidth : CGFloat = 28
        let flySpace : CGFloat = 10
        let flyMid : CGFloat = size.width / 2
        let flyIndexMid : CGFloat = 3
        for flyIndex in 0..<7{
            let SPACE : CGFloat = flyWidth + flySpace
            let flyX : CGFloat = flyMid + (CGFloat(flyIndex) - flyIndexMid) * SPACE
            let flyY : CGFloat = self.size.height - 5
            let flyNode = SKSpriteNode(imageNamed: "fly-1-1.png")
            flyNode.name = FLIES_NAME
            flyNode.anchorPoint = CGPoint(x : 0.5, y : 1)
            flyNode.position = CGPoint(x: flyX , y: flyY )
            flyNode.physicsBody = SKPhysicsBody(rectangleOf: flyNode.size)
            flyNode.physicsBody?.velocity = CGVector(dx: 0, dy: -50)
            flyNode.physicsBody?.collisionBitMask = 0
            flyNode.physicsBody?.linearDamping = 0
            flyNode.physicsBody?.categoryBitMask = 2 //000010
            flyNode.physicsBody?.contactTestBitMask = 1
            
            addChild(flyNode)
            flies.append(flyNode)
        }
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
            print(location)
            playerNode.position.x = location.x
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
            if (flyShootCount % 3) == 0 {
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
    
    let PLAYER_BULLET_NAME = "Player bullet"
    
    func shoot() -> Void {
        for count in 1...7 {
            let bulletNode = SKSpriteNode(imageNamed: "bullet-1.png")
            bulletNode.name = PLAYER_BULLET_NAME
            bulletNode.position = CGPoint(x: playerNode.position.x, y: playerNode.position.y + playerNode.size.height)
            bulletNode.physicsBody = SKPhysicsBody(rectangleOf: bulletNode.size)
            bulletNode.physicsBody?.categoryBitMask = 1
            bulletNode.physicsBody?.contactTestBitMask = 2
            bulletNode.physicsBody?.collisionBitMask = 0
            bulletNode.physicsBody?.velocity = CGVector(dx: (-300 + count * 75) , dy: 400)
            bulletNode.physicsBody?.mass = 0
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
        bulletNode.position = CGPoint(x: fly.position.x, y: fly.position.y - fly.size.height/2 )
        bulletNode.physicsBody = SKPhysicsBody(rectangleOf: bulletNode.size)
        bulletNode.physicsBody?.collisionBitMask = 0
        bulletNode.physicsBody?.velocity = CGVector(dx: 0, dy: -200)
        bulletNode.physicsBody?.mass = 0
        bulletNode.physicsBody?.categoryBitMask = 5
        bulletNode.physicsBody?.contactTestBitMask = 4
        
        addChild(bulletNode)
    }
    
}
