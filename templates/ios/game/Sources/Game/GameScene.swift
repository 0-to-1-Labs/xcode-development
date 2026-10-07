import SpriteKit

/// Starter SpriteKit scene. Tap anywhere to spawn a bouncing ball.
final class GameScene: SKScene {
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private(set) var score = 0

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.08, green: 0.10, blue: 0.20, alpha: 1)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)

        scoreLabel.fontSize = 36
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        spawnBall(at: touch.location(in: self))
    }

    func spawnBall(at point: CGPoint) {
        let ball = SKShapeNode(circleOfRadius: 24)
        ball.fillColor = SKColor(hue: .random(in: 0...1), saturation: 0.8, brightness: 1, alpha: 1)
        ball.strokeColor = .clear
        ball.position = point
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 24)
        ball.physicsBody?.restitution = 0.8
        addChild(ball)

        score += 1
        scoreLabel.text = "Score: \(score)"
    }
}
