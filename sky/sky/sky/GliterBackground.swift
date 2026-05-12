import SwiftUI

struct GlitteringStarsBackground: View {
    struct Star: Identifiable {
        let id = UUID()
        let position: CGPoint
        let size: CGFloat
        var opacity: Double
    }

    @State private var stars: [Star] = {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        return (0..<350).map { _ in
            Star(
                position: CGPoint(x: .random(in: 0...w), y: .random(in: 0...h)),
                size: .random(in: 1...2.5),
                opacity: .random(in: 0.5...1.0)
            )
        }
    }()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ForEach(stars) { star in
                Circle()
                    .fill(Color.white)
                    .frame(width: star.size, height: star.size)
                    .position(star.position)
                    .opacity(star.opacity)
            }
        }
        .ignoresSafeArea()
        .onAppear { startTwinkling() }
    }

    private func startTwinkling() {
        for index in stars.indices {
            let delay = Double.random(in: 0...2.0)
            let duration = Double.random(in: 1.0...2.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    stars[index].opacity = .random(in: 0.15...1.0)
                }
            }
        }
    }
}
