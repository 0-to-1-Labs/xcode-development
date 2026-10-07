import SpriteKit
import Testing
@testable import __APP_NAME__

struct GameSceneTests {
    @Test func spawningBallIncrementsScore() {
        let scene = GameScene(size: CGSize(width: 400, height: 800))
        scene.spawnBall(at: CGPoint(x: 100, y: 100))
        scene.spawnBall(at: CGPoint(x: 200, y: 200))
        #expect(scene.score == 2)
        #expect(scene.children.filter { $0 is SKShapeNode }.count == 2)
    }
}
