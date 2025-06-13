import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var viewModel = StarViewModel()
    @State private var isShowingAddStarForm = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
                    if hasSeenOnboarding {
                        MainStarView()
                    } else {
                        OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    }
                }
            }
        }

struct MainStarView: View {
    @StateObject private var viewModel = StarViewModel()
    @State private var isShowingAddStarForm = false

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 5.0

    private func groupStars(intoClusters stars: [Star], threshold: CGFloat, in size: CGSize) -> [[Star]] {
        var clusters: [[Star]] = []
        var ungroupedStars = stars

        while !ungroupedStars.isEmpty {
            let current = ungroupedStars.removeFirst()
            var cluster = [current]

            let currentPos = viewModel.position(for: current.coordinate, in: size)

            ungroupedStars.removeAll { star in
                let otherPos = viewModel.position(for: star.coordinate, in: size)
                let distance = hypot(currentPos.x - otherPos.x, currentPos.y - otherPos.y)
                if distance < threshold {
                    cluster.append(star)
                    return true
                }
                return false
            }

            clusters.append(cluster)
        }

        return clusters
    }

    var body: some View {
        ZStack {
            GlitteringStarsBackground()

            GeometryReader { geo in
                let clusters = groupStars(intoClusters: viewModel.stars, threshold: 50 / scale, in: geo.size)

                ZStack {
                    ForEach(clusters.indices, id: \.self) { index in
                        let cluster = clusters[index]

                        if cluster.count == 1 {
                            let star = cluster[0]
                            let pos = viewModel.position(for: star.coordinate, in: geo.size)
                            let glowColor = milkyWayColor(from: star.coordinate)

                            ZStack {
                                Circle()
                                    .fill(glowColor)
                                    .frame(width: 35, height: 35)
                                    .blur(radius: 10)
                                    .opacity(0.5)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 13, height: 13)
                            }
                            .position(
                                x: (pos.x * scale) + offset.width,
                                y: (pos.y * scale) + offset.height
                            )
                            .onTapGesture {
                                viewModel.selectedStar = star
                            }
                            .contextMenu {
                                Button("Remove Star") {
                                    viewModel.removeStar(star)
                                }
                            }

                        } else {
                            let avgX = cluster.map { viewModel.position(for: $0.coordinate, in: geo.size).x }.reduce(0, +) / CGFloat(cluster.count)
                            let avgY = cluster.map { viewModel.position(for: $0.coordinate, in: geo.size).y }.reduce(0, +) / CGFloat(cluster.count)

                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 60, height: 60)
                                    .blur(radius: 8)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 22, height: 22)

                                Text("\(cluster.count)")
                                    .font(.caption.bold())
                                    .foregroundColor(.black)
                            }
                            .position(
                                x: (avgX * scale) + offset.width,
                                y: (avgY * scale) + offset.height
                            )
                            .onTapGesture {
                                // Optional: you can zoom in or open a list of stars in the cluster here
                            }
                        }
                    }
                }
                .scaleEffect(scale)
                .contentShape(Rectangle())
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let newScale = lastScale * value.magnitude
                            scale = min(max(newScale, minScale), maxScale)
                        }
                        .onEnded { _ in
                            lastScale = scale
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .clipped()
            }

            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            scale = 1.0
                            lastScale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Button(action: {
                        isShowingAddStarForm.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingAddStarForm) {
            AddStarForm { coordinate, name, description, date in
                viewModel.addStar(coordinate: coordinate, name: name, description: description, date: date)
            }
        }
        .sheet(item: $viewModel.selectedStar) { star in
            StarDetailsSheet(star: star)
        }
    }
}

// MARK: - Milky Way Color Helper
func milkyWayColor(from coordinate: CLLocationCoordinate2D) -> Color {
    let seed = abs(sin(coordinate.latitude * 14.313 + coordinate.longitude * 37.137))
    let t = seed.truncatingRemainder(dividingBy: 1.0)
    
    let palette: [Color] = [
        Color(hue: 0.6, saturation: 0.4, brightness: 1.0),  // Soft blue
        Color(hue: 0.75, saturation: 0.5, brightness: 1.0), // Light violet
        Color(hue: 0.9, saturation: 0.4, brightness: 1.0),  // Pinkish
        Color(hue: 0.12, saturation: 0.5, brightness: 1.0), // Gold
        Color(hue: 0.5, saturation: 0.6, brightness: 1.0)   // Aqua-teal
    ]
    
    let index = Int(t * Double(palette.count)) % palette.count
    return palette[index]
}

