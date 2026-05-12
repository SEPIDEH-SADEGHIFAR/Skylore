import SwiftUI
import CoreLocation

struct MainStarView: View {
    @StateObject private var viewModel = StarViewModel()
    @State private var isShowingAddStarForm = false
    @State private var isShowingDetails = false

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let minScale: CGFloat = 0.4
    private let maxScale: CGFloat = 6.0
    private let deClusterScale: CGFloat = 2.0
    private let showLabelsScale: CGFloat = 2.8
    private let constellationMaxDegrees: Double = 30.0

    // MARK: - Clustering

    private func groupStars(_ stars: [Star], threshold: CGFloat, in size: CGSize) -> [[Star]] {
        var clusters: [[Star]] = []
        var remaining = stars
        while !remaining.isEmpty {
            let first = remaining.removeFirst()
            var cluster = [first]
            let p0 = viewModel.position(for: first.coordinate, in: size)
            remaining.removeAll { s in
                let p = viewModel.position(for: s.coordinate, in: size)
                guard hypot(p0.x - p.x, p0.y - p.y) < threshold else { return false }
                cluster.append(s)
                return true
            }
            clusters.append(cluster)
        }
        return clusters
    }

    // MARK: - Constellation lines path

    private func constellationPath(in size: CGSize) -> Path {
        var path = Path()
        let stars = viewModel.stars
        for i in 0..<stars.count {
            for j in (i + 1)..<stars.count {
                let s1 = stars[i], s2 = stars[j]
                let dist = sqrt(
                    pow(s1.coordinate.latitude  - s2.coordinate.latitude,  2) +
                    pow(s1.coordinate.longitude - s2.coordinate.longitude, 2)
                )
                guard dist < constellationMaxDegrees else { continue }
                let p1 = viewModel.position(for: s1.coordinate, in: size)
                let p2 = viewModel.position(for: s2.coordinate, in: size)
                path.move(to: CGPoint(x: p1.x * scale + offset.width,
                                      y: p1.y * scale + offset.height))
                path.addLine(to: CGPoint(x: p2.x * scale + offset.width,
                                         y: p2.y * scale + offset.height))
            }
        }
        return path
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            GlitteringStarsBackground()

            GeometryReader { geo in
                ZStack {
                    // Constellation lines
                    if viewModel.stars.count > 1 {
                        constellationPath(in: geo.size)
                            .stroke(
                                Color.cyan.opacity(0.12),
                                style: StrokeStyle(lineWidth: 0.6, dash: [4, 8])
                            )
                    }

                    // Stars (clustered or individual)
                    if scale >= deClusterScale {
                        ForEach(viewModel.stars) { star in
                            starDot(star, in: geo.size)
                        }
                    } else {
                        let clusters = groupStars(viewModel.stars, threshold: 55 / scale, in: geo.size)
                        ForEach(clusters.indices, id: \.self) { i in
                            clusterDot(clusters[i], in: geo.size)
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { v in scale = min(max(minScale, lastScale * v), maxScale) }
                            .onEnded   { _ in lastScale = scale },
                        DragGesture()
                            .onChanged { g in
                                offset = CGSize(
                                    width:  lastOffset.width  + g.translation.width,
                                    height: lastOffset.height + g.translation.height
                                )
                            }
                            .onEnded { _ in lastOffset = offset }
                    )
                )
            }

            // Stats HUD
            VStack {
                if viewModel.totalStars > 0 {
                    statsHUD
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.5), value: viewModel.totalStars)
                }
                Spacer()
                bottomBar
            }

            // Quick-peek card
            if let star = viewModel.selectedStar, !isShowingDetails {
                VStack {
                    Spacer()
                    quickPeek(star: star)
                        .padding(.bottom, 110)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.selectedStar?.id)
            }
        }
        .sheet(isPresented: $isShowingAddStarForm) {
            AddStarForm { coord, name, desc, date, cat in
                viewModel.addStar(coordinate: coord, name: name,
                                  description: desc, date: date, category: cat)
            }
        }
        .sheet(isPresented: $isShowingDetails, onDismiss: {
            viewModel.selectedStar = nil
        }) {
            if let star = viewModel.selectedStar {
                StarDetailsSheet(star: star)
            }
        }
    }

    // MARK: - Individual star dot

    @ViewBuilder
    private func starDot(_ star: Star, in size: CGSize) -> some View {
        let pos = viewModel.position(for: star.coordinate, in: size)
        let isSelected = viewModel.selectedStar?.id == star.id
        let color = star.category.color

        ZStack {
            // Outer glow
            Circle()
                .fill(color)
                .frame(width: isSelected ? 52 : 38, height: isSelected ? 52 : 38)
                .blur(radius: 14)
                .opacity(isSelected ? 0.7 : 0.45)
            // Core
            Circle()
                .fill(Color.white)
                .frame(width: isSelected ? 17 : 12, height: isSelected ? 17 : 12)

            // Labels at high zoom
           /* if scale >= showLabelsScale {
                Text(star.category.emoji)
                    .font(.system(size: 11))
                    .offset(y: -22)
                Text(star.name)
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
                    .offset(y: 20)
            }*/
        }
        .scaleEffect(isSelected ? 1.25 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .position(
            x: pos.x * scale + offset.width,
            y: pos.y * scale + offset.height
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectedStar = (viewModel.selectedStar?.id == star.id) ? nil : star
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                withAnimation { viewModel.removeStar(star) }
            } label: {
                Label("Remove Star", systemImage: "trash")
            }
        }
    }

    // MARK: - Cluster dot

    @ViewBuilder
    private func clusterDot(_ cluster: [Star], in size: CGSize) -> some View {
        let positions = cluster.map { viewModel.position(for: $0.coordinate, in: size) }
        let avg = CGPoint(
            x: positions.map(\.x).reduce(0, +) / CGFloat(positions.count),
            y: positions.map(\.y).reduce(0, +) / CGFloat(positions.count)
        )
        let center = CGPoint(x: avg.x * scale + offset.width,
                             y: avg.y * scale + offset.height)

        if cluster.count == 1 {
            starDot(cluster[0], in: size)
        } else {
            let color = cluster[0].category.color
            ZStack {
                // Cross-ray glow
                Group {
                    Rectangle().fill(color.opacity(0.4)).frame(width: 56, height: 8)
                    Rectangle().fill(color.opacity(0.4)).frame(width: 8, height: 56)
                }
                .blur(radius: 10)
                // Centre dot
                Circle().fill(Color.white).frame(width: 24, height: 24)
                Text("\(cluster.count)")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.black)
            }
            .position(center)
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.75)) {
                    scale = min(maxScale, 2.5)
                    lastScale = scale
                    // Compute canvas size from screen
                    let screenW = UIScreen.main.bounds.width
                    let screenH = UIScreen.main.bounds.height
                    offset = CGSize(
                        width:  screenW / 2 - avg.x * scale,
                        height: screenH / 2 - avg.y * scale
                    )
                    lastOffset = offset
                }
            }
        }
    }

    // MARK: - Stats HUD

    private var statsHUD: some View {
        HStack(spacing: 18) {
            Label("\(viewModel.totalStars) Stars", systemImage: "star.fill")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.cyan)
            Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 18)
            Label("\(viewModel.regionCount) Regions", systemImage: "globe")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.purple)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.3), radius: 10)
        .padding(.top, 58)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1; lastScale = 1
                    offset = .zero; lastOffset = .zero
                    viewModel.selectedStar = nil
                }
            } label: {
                Image(systemName: "scope")
                    .font(.title2).foregroundColor(.cyan)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .cyan.opacity(0.25), radius: 10)
            }

            Spacer()

            Button { isShowingAddStarForm = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                    Text("New Star").fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .background(
                    LinearGradient(colors: [.cyan, .blue],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Capsule())
                .shadow(color: .blue.opacity(0.45), radius: 14)
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 44)
    }

    // MARK: - Quick-peek card

    private func quickPeek(star: Star) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(star.category.color.opacity(0.18)).frame(width: 52, height: 52)
               // Text(star.category.emoji).font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(star.name)
                    .font(.headline).foregroundColor(.white).lineLimit(1)
                HStack(spacing: 6) {
                    Text(star.category.label)
                        .font(.caption).foregroundColor(star.category.color)
                    Text("·").foregroundColor(.gray)
                    Text(formattedDate(star.date))
                        .font(.caption).foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(spacing: 10) {
                Button {
                    isShowingDetails = true
                } label: {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title2).foregroundColor(.cyan)
                }

                Button {
                    withAnimation { viewModel.selectedStar = nil }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2).foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(star.category.color.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .shadow(color: star.category.color.opacity(0.25), radius: 18)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .medium
        return f.string(from: date)
    }
}
