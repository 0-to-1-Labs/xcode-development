import SpriteKit
import SwiftUI

/// Hosts the SpriteKit scene inside SwiftUI. Scene size follows the view.
struct GameView: View {
    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: makeScene(size: proxy.size), preferredFramesPerSecond: 60)
                .ignoresSafeArea()
        }
    }

    private func makeScene(size: CGSize) -> SKScene {
        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        return scene
    }
}

#Preview {
    GameView()
}
