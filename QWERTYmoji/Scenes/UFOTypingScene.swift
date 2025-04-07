//
//  UFOTypingScene.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 2/16/25.
//

import SpriteKit

struct RoundStats: Codable {
    let endDate: Date
}

protocol TypingScene: SKScene, Hashable {
    static var friendlyName: String { get }
    static var thumbnail: String { get }

    var roundStats: RoundStats? { get set }
    var onGameOver: (() -> Void)? { get set }

    func pause()
    func resume()
    func handleEmojiInput(_ emoji: String)
}

extension TypingScene {
    static var thumbnail: String {
        String(describing: Self.self) + "_thumbnail"
    }
}

// MARK: - Game Scene
class UFOTypingScene: SKScene, TypingScene, SKPhysicsContactDelegate {

    static var friendlyName: String { "Alien Invasion" }

    var roundStats: RoundStats?
    var onGameOver: (() -> Void)?

    private var ufoNodes: [UFONode] = []
    private var lastUpdateTime: TimeInterval = 0
    private var spawnTimer: TimeInterval = 0
    private var totalSpawnedUFOs: Int = 0
    private var difficulty: CGFloat = 1.0
    private var cityBackground: SKNode?

    // Configurable properties
    private let minSpawnInterval: TimeInterval = 1.0
    private let maxUFOs = 5
    private let baseSpeed: CGFloat = 50.0
    private let projectileSpeed: CGFloat = 400.0
    private let minVerticalSpacing: CGFloat = 100.0  // Minimum space between UFOs

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupBackground()
        setupPhysics()

        // Set physics contact delegate
        physicsWorld.contactDelegate = self
    }

    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        // Create boundary to detect when UFOs get too low
        let boundary = SKNode()
        boundary.position = CGPoint(x: frame.midX, y: frame.height * 0.2)
        boundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 2))
        boundary.physicsBody?.isDynamic = false
        boundary.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        addChild(boundary)
    }

    private func setupBackground() {
        // Placeholder image background TODO: investigate animated/parallax alts.
        let background = SKSpriteNode(imageNamed: "invasionBackground")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        addChild(background)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.projectile | PhysicsCategory.ufo {
            // Handle UFO destruction
            let ufo = (contact.bodyA.categoryBitMask == PhysicsCategory.ufo) ? contact.bodyA.node : contact.bodyB.node
            let projectile = (contact.bodyA.categoryBitMask == PhysicsCategory.projectile) ? contact.bodyA.node : contact.bodyB.node

            if let ufoNode = ufo as? UFONode {
                // Remove from tracking array
                ufoNodes.removeAll { $0 === ufoNode }

                // Create simple explosion effect
                createExplosionEffect(at: ufoNode.position)

                // Remove nodes
                ufoNode.removeFromParent()
                projectile?.removeFromParent()

                // Check for end game condition
                if totalSpawnedUFOs == 10 && ufoNodes.isEmpty {
                    endGame()
                }
            }
        }
    }

    func handleEmojiInput(_ emoji: String) {
        guard let bottomUFO = ufoNodes
            .filter({ $0.wasShotAt == false })
            .min(by: { $0.position.y < $1.position.y })
        else { return }

        if bottomUFO.emoji == emoji {
            fireProjectile(at: bottomUFO)
        }
    }

    func pause() {
        // no-op TODO: tb
    }

    func resume() {
        // no-op TODO: tb
    }

    private func endGame() {
        roundStats = RoundStats(endDate: Date())
        onGameOver?()
    }

    private func createExplosionEffect(at position: CGPoint) {
        // Create multiple particles spreading out
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = .yellow
            particle.strokeColor = .orange
            particle.position = position

            // Random direction
            let angle = CGFloat.random(in: 0...2 * .pi)
            let distance: CGFloat = 50

            // Create actions for the particle
            let moveAction = SKAction.moveBy(
                x: cos(angle) * distance,
                y: sin(angle) * distance,
                duration: 0.5
            )
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            let scaleAction = SKAction.scale(by: 0.1, duration: 0.5)
            let group = SKAction.group([moveAction, fadeAction, scaleAction])
            let sequence = SKAction.sequence([
                group,
                SKAction.removeFromParent()
            ])

            addChild(particle)
            particle.run(sequence)
        }
    }

    private func fireProjectile(at target: UFONode) {
        target.wasShotAt = true
        let projectile = SKSpriteNode(color: .green, size: CGSize(width: 10, height: 20))
        projectile.position = CGPoint(x: frame.midX, y: frame.height * 0.1)

        // Configure physics body
        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.ufo
        projectile.physicsBody?.collisionBitMask = 0
        projectile.physicsBody?.affectedByGravity = false
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.allowsRotation = false
        projectile.physicsBody?.linearDamping = 0
        projectile.physicsBody?.friction = 0
        addChild(projectile)

        // Calculate interception point
        let targetVelocity = target.physicsBody?.velocity ?? .zero
        let targetPosition = target.position
        let projectilePosition = projectile.position

        // Time to intercept calculation
        let a = targetVelocity.dx * targetVelocity.dx + targetVelocity.dy * targetVelocity.dy - projectileSpeed * projectileSpeed
        let b = 2 * (targetVelocity.dx * (targetPosition.x - projectilePosition.x) +
                     targetVelocity.dy * (targetPosition.y - projectilePosition.y))
        let c = (targetPosition.x - projectilePosition.x) * (targetPosition.x - projectilePosition.x) +
                (targetPosition.y - projectilePosition.y) * (targetPosition.y - projectilePosition.y)

        // Quadratic formula to solve for intercept time
        let discriminant = b * b - 4 * a * c
        var interceptTime: CGFloat

        if abs(a) < 0.001 {
            // Target is barely moving, direct shot
            interceptTime = sqrt(c) / projectileSpeed
        } else if discriminant >= 0 {
            // Use the smaller positive solution
            interceptTime = (-b - sqrt(discriminant)) / (2 * a)
            if interceptTime < 0 {
                interceptTime = (-b + sqrt(discriminant)) / (2 * a)
            }
        } else {
            // Fallback to simple targeting if no solution found
            interceptTime = 0
        }

        // Calculate interception point
        let interceptX = targetPosition.x + targetVelocity.dx * interceptTime
        let interceptY = targetPosition.y + targetVelocity.dy * interceptTime

        // Calculate velocity needed to hit intercept point
        let direction: CGVector
        if interceptTime > 0 {
            direction = CGVector(
                dx: interceptX - projectilePosition.x,
                dy: interceptY - projectilePosition.y
            )
        } else {
            // Direct targeting fallback
            direction = CGVector(
                dx: targetPosition.x - projectilePosition.x,
                dy: targetPosition.y - projectilePosition.y
            )
        }

        let normalized = normalize(direction)
        let velocity = CGVector(
            dx: normalized.dx * projectileSpeed,
            dy: normalized.dy * projectileSpeed
        )

        projectile.physicsBody?.velocity = velocity

        // Remove projectile after 3 seconds if it hasn't hit anything
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.removeFromParent()
        ])
        projectile.run(removeAction)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update spawn timer
        spawnTimer += dt
        if spawnTimer >= minSpawnInterval && ufoNodes.count < maxUFOs {
            spawnUFO()
            spawnTimer = 0
        }

        // Sort UFOs by height
        let sortedUFOs = ufoNodes.sorted { $0.position.y < $1.position.y }

        // Check if any UFO is too low
        if let lowestUFO = sortedUFOs.first {
            let threshold = frame.height * 0.3
            let isTooLow = lowestUFO.position.y < threshold

            if isTooLow {
                // Slow down all UFOs
                difficulty = max(0.5, difficulty - 0.1)

                // Stop all UFOs while maintaining relative positions
                for ufo in ufoNodes {
                    ufo.physicsBody?.velocity = .zero
                }
            } else {
                // Resume movement and gradually increase difficulty
                difficulty = min(2.0, difficulty + 0.01)

                // Update UFO positions while maintaining spacing
                for (index, ufo) in sortedUFOs.enumerated() {
                    let targetY: CGFloat
                    if index == 0 {
                        // Lowest UFO moves freely (subject to minimum height)
                        targetY = ufo.position.y
                    } else {
                        // Higher UFOs maintain spacing with UFO below
                        let ufoBelow = sortedUFOs[index - 1]
                        targetY = ufoBelow.position.y + minVerticalSpacing

                        // If current UFO is too close to the one below, adjust its position
                        if ufo.position.y < targetY {
                            ufo.position.y = targetY
                        }
                    }

                    // Apply velocity only if not too low
                    if !isTooLow {
                        ufo.physicsBody?.velocity.dy = -baseSpeed * difficulty
                    }
                }
            }
        }
    }

    private func spawnUFO() {
        guard totalSpawnedUFOs < 10 else { return }

        let key = KeyboardLayout.allKeys.randomElement()!

        let ufo = UFONode(emoji: key.emoji)
        ufo.position = CGPoint(
            x: CGFloat.random(in: frame.width * 0.2...frame.width * 0.8),
            y: frame.height + ufo.bodyNode.size.height
        )
        ufoNodes.append(ufo)
        addChild(ufo)

        totalSpawnedUFOs += 1
    }
}

// MARK: - UFO Node
class UFONode: SKNode {
    let emoji: String
    let bodyNode: SKSpriteNode
    var wasShotAt: Bool = false

    init(emoji: String) {
        self.emoji = emoji
        self.bodyNode = SKSpriteNode(imageNamed: "ufoProto")
        let desiredWidth: CGFloat = 100
        let aspectRatio = bodyNode.size.height / bodyNode.size.width
        bodyNode.size = CGSize(width: desiredWidth, height: desiredWidth * aspectRatio)
        super.init()

        addChild(bodyNode)

        let label = SKLabelNode(text: emoji)
        label.fontSize = 32
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: -5)
        addChild(label)

        self.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        self.physicsBody?.categoryBitMask = PhysicsCategory.ufo
        self.physicsBody?.contactTestBitMask = PhysicsCategory.projectile | PhysicsCategory.boundary
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Physics Categories
struct PhysicsCategory {
    static let ufo: UInt32 = 0b1
    static let projectile: UInt32 = 0b10
    static let boundary: UInt32 = 0b100
}

// MARK: - Utility Functions
func normalize(_ vector: CGVector) -> CGVector {
    let length = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    return CGVector(dx: vector.dx / length, dy: vector.dy / length)
}
