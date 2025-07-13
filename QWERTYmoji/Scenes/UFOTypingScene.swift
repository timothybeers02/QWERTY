//
//  UFOTypingScene.swift
//  QWERTYmoji
//
//  Created by Timothy Beers on 2/16/25.
//

import SpriteKit

private enum Constants {
    static let totalUFOCount: Int = 20
}

struct KeyStrokeStat: Codable {
    let actualEmoji: String
    let enteredEmoji: String
    let timeToType: TimeInterval
}

struct RoundStats: Codable {
    let gameMode: String
    var endDate = Date.now
    var keyStrokeStats: [KeyStrokeStat] = []
}

protocol TypingScene: SKScene, Hashable {
    static var friendlyName: String { get }
    static var thumbnail: String { get }

    //    var roundStats: RoundStats { get set }
    var onGameOver: ((RoundStats) -> Void)? { get set }

    var remainingTargets: Int { get }
    var totalMistypes: Int { get }

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
@Observable
class UFOTypingScene: SKScene, TypingScene, SKPhysicsContactDelegate {

    static var friendlyName: String { "Alien Invasion" }

    /// Number of consecutive UFO destructions needed before spawn rate ramps up
    var rampUpThreshold: Int = 1
    var rampUpEnabled: Bool = true

    /// Current interval between spawns; initialized in didMove
    private var currentSpawnInterval: TimeInterval = 0

    /// Minimum allowed spawn interval when ramping up
    private let minAllowedSpawnInterval: TimeInterval = 0.2

    /// Count of back-to-back UFO destructions since last spawn
    private var consecutiveDestroyCount: Int = 0
    var roundStats = RoundStats(gameMode: friendlyName)
    var onGameOver: ((RoundStats) -> Void)?

    private var ufoNodes: [UFONode] = []
    var remainingTargets: Int {
        return ufoNodes.count
    }

    private(set) var mistypeCount: Int = 0
    var totalMistypes: Int {
        return mistypeCount
    }
    private var lastUpdateTime: TimeInterval = 0
    private var spawnTimer: TimeInterval = 0
    private var totalSpawnedUFOs: Int = 0
    private var lastLowestUFO: UFONode?
    private var difficulty: CGFloat = 1.0
    private var cityBackground: SKNode?

    // Configurable properties
    private let minSpawnInterval: TimeInterval = 2.0
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

        currentSpawnInterval = minSpawnInterval
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
        // Remove any existing background nodes
        enumerateChildNodes(withName: "backgroundLayer") { node, _ in
            node.removeFromParent()
        }

        let backgroundNames = [
            ("invasionBackgroundTop", -3, 5.0),
            ("invasionBackgroundMid", -2, 4.0),
            ("invasionBackgroundBottom", -1, 2.5)
        ]

        // Calculate the scaled heights for each layer
        var scaledHeights: [CGFloat] = []
        for (imageName, _, _) in backgroundNames {
            let sprite = SKSpriteNode(imageNamed: imageName)
            let scale = frame.width / sprite.size.width
            scaledHeights.append(sprite.size.height * scale)
        }

        // For each layer, compute the cumulative Y offset so each stacks on the previous
        for (index, (imageName, zPos, speed)) in backgroundNames.enumerated() {
            // Add two sprites for seamless looping, precisely end-to-end horizontally
            let tempSprite = SKSpriteNode(imageNamed: imageName)
            let scale = frame.width / tempSprite.size.width
            let scaledWidth = tempSprite.size.width * scale
            let yOffset = scaledHeights[(index+1)...].reduce(0, +)
            for i in 0..<2 {
                let sprite = SKSpriteNode(imageNamed: imageName)
                sprite.anchorPoint = CGPoint(x: 0, y: 0)
                sprite.xScale = scale
                sprite.yScale = scale
                sprite.position = CGPoint(
                    x: CGFloat(i) * scaledWidth,
                    y: frame.minY + yOffset
                )
                sprite.zPosition = CGFloat(zPos)
                sprite.name = "backgroundLayer"
                addChild(sprite)

                // Move left by exactly the scaled width, then reset
                let moveLeft = SKAction.moveBy(x: -scaledWidth, y: 0, duration: speed * 10)
                let reset = SKAction.moveBy(x: scaledWidth, y: 0, duration: 0)
                let sequence = SKAction.sequence([moveLeft, reset])
                let repeatForever = SKAction.repeatForever(sequence)
                sprite.run(repeatForever)
            }
        }
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

                // Track consecutive destructions for spawn ramp-up
                consecutiveDestroyCount += 1
                if rampUpEnabled && consecutiveDestroyCount > rampUpThreshold {
                    currentSpawnInterval = max(minAllowedSpawnInterval, currentSpawnInterval * 0.9)
                }

                // Check for end game condition
                if totalSpawnedUFOs == Constants.totalUFOCount && ufoNodes.isEmpty {
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
            // Compute time to type
            if let appeared = bottomUFO.bottomAppearedDate {
                let timeTaken = Date().timeIntervalSince(appeared)
                roundStats.keyStrokeStats.append(
                    KeyStrokeStat(
                        actualEmoji: bottomUFO.emoji,
                        enteredEmoji: emoji,
                        timeToType: timeTaken
                    )
                )
            }
            fireProjectile(at: bottomUFO)
        } else {
            mistypeCount += 1
        }
    }

    func pause() {
        // no-op TODO: tb
    }

    func resume() {
        // no-op TODO: tb
    }

    private func endGame() {
        roundStats.endDate = Date.now
        onGameOver?(roundStats)
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
        if spawnTimer >= currentSpawnInterval && ufoNodes.count < maxUFOs {
            spawnUFO()
            spawnTimer = 0
        }

        // Sort UFOs by height
        let sortedUFOs = ufoNodes.sorted { $0.position.y < $1.position.y }

        if let newLowest = sortedUFOs.first(where: { !$0.wasShotAt }), newLowest !== lastLowestUFO {
            newLowest.bottomAppearedDate = Date()
            lastLowestUFO = newLowest
        }

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
        guard totalSpawnedUFOs < Constants.totalUFOCount else { return }
        consecutiveDestroyCount = 0

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
    var bottomAppearedDate: Date?

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
