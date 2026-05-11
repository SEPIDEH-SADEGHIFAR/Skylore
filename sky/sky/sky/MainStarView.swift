import SwiftUI
import CoreLocation

struct MainStarView: View {
    @StateObject private var viewModel = StarViewModel()
    @State private var isShowingAddStarForm = false

    // Zoom & pan
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    // Auto-zoom target
    @State private var focusCenter: CGPoint?

    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 5.0
    private let deClusterScale: CGFloat = 2.0 // scale threshold to stop clustering

    private func groupStars(intoClusters stars: [Star], threshold: CGFloat, in size: CGSize) -> [[Star]] {
        var clusters: [[Star]] = []
        var ungrouped = stars
        while !ungrouped.isEmpty {
            let first = ungrouped.removeFirst()
            var cluster = [first]
            let p0 = viewModel.position(for: first.coordinate, in: size)
            ungrouped.removeAll { s in
                let p = viewModel.position(for: s.coordinate, in: size)
                return hypot(p0.x - p.x, p0.y - p.y) < threshold ? { cluster.append(s); return true }() : false
            }
            clusters.append(cluster)
        }
        return clusters
    }

    var body: some View {
        ZStack {
            GlitteringStarsBackground()
            GeometryReader { geo in
                ZStack {
                    if scale >= deClusterScale {
                        ForEach(viewModel.stars) { star in
                            let pos = viewModel.position(for: star.coordinate, in: geo.size)
                            let glow = milkyWayColor(from: star.coordinate)
                            ZStack {
                                Circle()
                                    .fill(glow)
                                    .frame(width: 35, height: 35)
                                    .blur(radius: 10)
                                    .opacity(0.5)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 13, height: 13)
                            }
                            .position(
                                x: pos.x * scale + offset.width,
                                y: pos.y * scale + offset.height
                            )
                            .contextMenu {
                                Button("Remove Star") {
                                    withAnimation(.easeInOut) {
                                        viewModel.removeStar(star)
                                    }
                                }
                            }
                            .onTapGesture {
                                viewModel.selectedStar = star
                            }
                        }
                    } else {
                        let clusters = groupStars(
                            intoClusters: viewModel.stars,
                            threshold: 50 / scale,
                            in: geo.size
                        )
                        ForEach(clusters.indices, id: \.self) { i in
                            let cluster = clusters[i]
                            let rawPositions = cluster.map { viewModel.position(for: $0.coordinate, in: geo.size) }
                            let avg = CGPoint(
                                x: rawPositions.map { $0.x }.reduce(0, +) / CGFloat(rawPositions.count),
                                y: rawPositions.map { $0.y }.reduce(0, +) / CGFloat(rawPositions.count)
                            )
                            let center: CGPoint = {
                                if let fc = focusCenter, cluster.count > 1 {
                                    return fc
                                }
                                return CGPoint(x: avg.x * scale + offset.width, y: avg.y * scale + offset.height)
                            }()

                            if cluster.count == 1 {
                                let star = cluster[0]
                                let glow = milkyWayColor(from: star.coordinate)
                                ZStack {
                                    Circle()
                                        .fill(glow)
                                        .frame(width: 35, height: 35)
                                        .blur(radius: 10)
                                        .opacity(0.5)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 13, height: 13)
                                }
                                .position(center)
                                .contextMenu {
                                    Button("Remove Star") {
                                        withAnimation(.easeInOut) {
                                            viewModel.removeStar(star)
                                        }
                                    }
                                }
                                .onTapGesture {
                                    viewModel.selectedStar = star
                                }
                            } else {
                                let glow = milkyWayColor(from: cluster[0].coordinate)
                                ZStack {
                                    Group {
                                        Rectangle().fill(glow.opacity(0.5)).frame(width: 50, height: 10)
                                        Rectangle().fill(glow.opacity(0.5)).frame(width: 10, height: 50)
                                    }
                                    .blur(radius: 12)
                                    Circle().fill(Color.white).frame(width: 20, height: 20)
                                }
                                .position(center)
                                .onTapGesture {
                                    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.75)) {
                                        scale = min(maxScale, 2.5)
                                        lastScale = scale
                                        let screenCenter = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                                        offset = CGSize(
                                            width: screenCenter.x - avg.x * scale,
                                            height: screenCenter.y - avg.y * scale
                                        )
                                        lastOffset = offset
                                        focusCenter = screenCenter
                                    }
                                }
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = min(max(minScale, lastScale * value), maxScale)
                                scale = newScale
                            }
                            .onEnded { _ in
                                lastScale = scale
                                focusCenter = nil
                            },
                        DragGesture()
                            .onChanged { gesture in
                                offset = CGSize(
                                    width: lastOffset.width + gesture.translation.width,
                                    height: lastOffset.height + gesture.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                                focusCenter = nil
                            }
                    )
                )
            }

            VStack {
                Spacer()
                HStack {
                    Button {
                        withAnimation(.easeInOut) {
                            scale = 1
                            lastScale = 1
                            offset = .zero
                            lastOffset = .zero
                            focusCenter = nil
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Button {
                        isShowingAddStarForm.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
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
        .sheet(item: $viewModel.selectedStar) {
            StarDetailsSheet(star: $0)
        }
    }
}
