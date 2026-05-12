import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    private struct Page {
        let icon: String
        let title: String
        let subtitle: String
        let color: Color
    }

    private let pages: [Page] = [
        Page(icon: "sparkles",
             title: "Your Universe",
             subtitle: "Every place that shaped you is a star waiting to be named. Begin mapping your personal constellation.",
             color: .cyan),
        Page(icon: "mappin.and.ellipse",
             title: "Mark Your Stars",
             subtitle: "Tap the map, search by name, or use your location to drop a star anywhere on Earth.",
             color: .purple),
        Page(icon: "point.3.connected.trianglepath.dotted",
             title: "Build Constellations",
             subtitle: "Watch your stars connect into lines — a map of everywhere and everyone that matters to you.",
             color: .orange)
    ]

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.09).ignoresSafeArea()
            GlitteringStarsBackground().opacity(0.7)

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { i in
                        pageContent(pages[i]).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 460)

                // Page indicator dots
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? pages[currentPage].color : Color.white.opacity(0.25))
                            .frame(width: i == currentPage ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.4), value: currentPage)
                    }
                }
                .padding(.bottom, 44)

                Spacer()

                // CTA
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.4)) { currentPage += 1 }
                    } else {
                        withAnimation { hasSeenOnboarding = true }
                    }
                } label: {
                    Text(currentPage == pages.count - 1 ? "Begin My Journey" : "Next")
                        .font(.headline)
                        .tracking(0.5)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(pages[currentPage].color)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                        .shadow(color: pages[currentPage].color.opacity(0.4), radius: 20)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
                .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func pageContent(_ page: Page) -> some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.08))
                    .frame(width: 220, height: 220)
                Circle()
                    .fill(page.color.opacity(0.14))
                    .frame(width: 150, height: 150)
                Image(systemName: page.icon)
                    .font(.system(size: 62, weight: .light))
                    .foregroundColor(page.color)
                    .shadow(color: page.color.opacity(0.6), radius: 20)
            }

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text(page.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .lineSpacing(4)
                    .padding(.horizontal, 36)
            }
        }
    }
}
