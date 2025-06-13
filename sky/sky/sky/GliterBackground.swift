import SwiftUI

struct GlitteringStarsBackground: View {
    struct Star: Identifiable {
        let id = UUID()
        let position: CGPoint
        let size: CGFloat
        var opacity: Double
    }

    @State private var stars: [Star] = []

    init() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        _stars = State(initialValue: (0..<700).map { _ in
            Star(
                position: CGPoint(x: CGFloat.random(in: 0...width),
                                  y: CGFloat.random(in: 0...height)),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.6...1.0)
            )
        })
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ForEach(stars) { star in
                Circle()
                    .fill(Color.white)
                    .frame(width: star.size, height: star.size)
                    .position(star.position)
                    .opacity(star.opacity)
                    .animation(Animation.easeInOut(duration: Double.random(in: 0.5...1.5)).repeatForever(), value: star.opacity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startTwinkling()
        }
    }

    private func startTwinkling() {
        for index in stars.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...1.5)) {
                withAnimation(Animation.easeInOut(duration: Double.random(in: 0.5...1.5)).repeatForever()) {
                    stars[index].opacity = Double.random(in: 0.3...1.0)
                }
            }
        }
    }
}
