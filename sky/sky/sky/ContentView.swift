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

    // Zoom and pan state variables
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    // Minimum and maximum zoom scale
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 5.0

    var body: some View {
        ZStack {
            GlitteringStarsBackground()

            GeometryReader { geo in
                ZStack {
                    ForEach(viewModel.stars) { star in
                        let pos = viewModel.position(for: star.coordinate, in: geo.size)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 13, height: 13)
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
                    }
                }
                .scaleEffect(scale)
                .contentShape(Rectangle()) // Makes the entire area draggable
                .gesture(
                    // Magnification gesture for zooming
                    MagnificationGesture()
                        .onChanged { value in
                            // Calculate new scale based on gesture and previous scale
                            let newScale = lastScale * value.magnitude
                            // Clamp scale to min/max values
                            scale = min(max(newScale, minScale), maxScale)
                        }
                        .onEnded { value in
                            // Store the current scale for next gesture
                            lastScale = scale
                        }
                )
                .gesture(
                    // Drag gesture for panning
                    DragGesture()
                        .onChanged { value in
                            // Update offset based on gesture translation and previous offset
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { value in
                            // Store the current offset for next gesture
                            lastOffset = offset
                        }
                )
                .clipped()
            }

            // Reset zoom/pan and plus buttons at the bottom corners
            VStack {
                Spacer()
                HStack {
                    // Reset button (bottom left, outline style)
                    Button(action: {
                        // Reset zoom and pan
                        withAnimation(.spring()) {
                            scale = 1.0
                            lastScale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise") // outline style
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    // Plus button (bottom right)
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
            AddStarForm { coordinate, name, description in
                viewModel.addStar(coordinate: coordinate, name: name, description: description)
            }
        }
        .sheet(item: $viewModel.selectedStar) { star in
            StarDetailsSheet(star: star)
        }
    }
}

