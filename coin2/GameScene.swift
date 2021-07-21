//
//  GameScene.swift
//  coin2
//
//  Created by adam januszewski on 7/11/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var demon: SKSpriteNode?
    var ghostTimer : Timer?
    var ceil: SKSpriteNode?
    var finalTimeLabel: SKLabelNode?
    var timeLabel: SKLabelNode?
    
    let coinManCategory : UInt32 = 0x1 << 1
    let ghostCategory : UInt32 = 0x1 << 2
    let bombCategory : UInt32 = 0x1 << 3
    let groundAndCeilingCategory : UInt32 = 0x1 << 4
    
    var timeGone = 0
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        demon = childNode(withName: "demon") as? SKSpriteNode
        demon?.physicsBody?.categoryBitMask = coinManCategory
        demon?.physicsBody?.contactTestBitMask = ghostCategory
        demon?.physicsBody?.collisionBitMask = groundAndCeilingCategory
        var demonFly : [SKTexture] = []
        for number in 1...4 {
            demonFly.append(SKTexture(imageNamed: "fly-\(number)"))
        }
        demon?.run(SKAction.repeatForever(SKAction.animate(with: demonFly, timePerFrame: 0.08)))


        ceil = childNode(withName: "ceil") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilingCategory
        ceil?.physicsBody?.collisionBitMask = coinManCategory
           
        startTimers()
        createGrass()
    }
    
    func createGrass() {
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width / sizingGrass.size.width) + 1
        for grassNumber in 0...numberOfGrass {
            let grass = SKSpriteNode(imageNamed: "grass")
            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody?.categoryBitMask = groundAndCeilingCategory
            grass.physicsBody?.collisionBitMask = coinManCategory
            grass.physicsBody?.affectedByGravity = false
            grass.physicsBody?.isDynamic = false
            addChild(grass)
            
            let grassX = (-size.width / 2 + grass.size.width / 2) + (grass.size.width * CGFloat(grassNumber))
            grass.position = CGPoint(x: grassX, y: (-size.height / 2) + (grass.size.height / 2 + 100))
            let speed = 100.0
            let moveLeft = SKAction.moveBy(x: -grass.size.width - grass.size.width * CGFloat(grassNumber), y: 0, duration: TimeInterval(grass.size.width + grass.size.width * CGFloat(grassNumber)) / speed)
            
            let resetGrass = SKAction.moveBy(x: size.width + grass.size.width, y: 0, duration: 0)
            let grassFullMove = SKAction.moveBy(x: -size.width - grass.size.width, y: 0, duration: TimeInterval(size.width + grass.size.width) / speed)
            let grassMovingForever = SKAction.repeatForever(SKAction.sequence([grassFullMove, resetGrass]))
            
            grass.run(SKAction.sequence([moveLeft, resetGrass, grassMovingForever]))
        }
    }
    
    func startTimers() {
        ghostTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createGhost()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scene?.isPaused == false {
            demon?.physicsBody?.applyForce(CGVector(dx: 0, dy: 50_000))
        }
        
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let theNodes = nodes(at: location)
            
            for node in theNodes {
                if node.name == "play" {
                    // Restart the game
                    timeGone = 0
                    node.removeFromParent()
                    finalTimeLabel?.removeFromParent()
                    timeLabel?.removeFromParent()
                    scene?.isPaused = false
                    timeLabel?.text = "Time Flying: \(timeGone)"
                    startTimers()
                }
            }
        }
        
    }
    
    func createGhost() {
        let ghost = SKSpriteNode(imageNamed: "ghost")
        ghost.physicsBody = SKPhysicsBody(rectangleOf: ghost.size)
        ghost.physicsBody?.affectedByGravity = false
        ghost.physicsBody?.categoryBitMask = ghostCategory
        ghost.physicsBody?.contactTestBitMask = coinManCategory
        addChild(ghost)
        
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        
        let maxY = size.height / 2 - ghost.size.height / 2
        let minY = -size.height / 2 + ghost.size.height / 2 + sizingGrass.size.height
        let range = maxY - minY
        let ghostY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        ghost.position = CGPoint(x: size.width / 2 + ghost.size.width / 2, y: ghostY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - ghost.size.width, y: 0, duration: 4)
        
        ghost.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == ghostCategory {
            contact.bodyA.node?.removeFromParent()
            gameOver()
        }
        if contact.bodyB.categoryBitMask == ghostCategory {
            contact.bodyA.node?.removeFromParent()
            gameOver()
        }
    }
    func gameOver() {
        scene?.isPaused = true
        
        ghostTimer?.invalidate()
        
        timeLabel? = SKLabelNode(text: "Time Survived:")
        timeLabel?.color = .blue
        timeLabel?.position = CGPoint(x: 0, y: 200)
        timeLabel?.fontSize = 80
        timeLabel?.zPosition = 1
        if timeLabel != nil {
            addChild(timeLabel!)
        }
        
        finalTimeLabel? = SKLabelNode(text: "\(timeGone)")
        finalTimeLabel?.position = CGPoint(x: 0, y: 0)
        finalTimeLabel?.fontSize = 80
        finalTimeLabel?.zPosition = 1
        if finalTimeLabel != nil {
            addChild(finalTimeLabel!)
        }
        
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.name = "play"
        playButton.zPosition = 1
        addChild(playButton)
    }

    
}
