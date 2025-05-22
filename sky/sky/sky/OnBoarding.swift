import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    private let totalPages = 4  // Total pages in TabView

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentPage) {
                OnboardingPage(imageName: "star",
                               title: "Welcome!",
                               description: "Create your own sky full of memories.")
                    .tag(0)
                
                OnboardingPage(imageName: "map",
                               title: "Choose Locations",
                               description: "Pick places you've visited and turn them into stars.")
                    .tag(1)
                
                OnboardingPage(imageName: "mappin.and.ellipse",
                               title: "Your stars have a home!",
                               description: "your stars will take place in your sky based on the coordinates of the locations you choose! ")
                    .tag(2)
                
                VStack {
                    Text("Let's Get Started!")
                        .font(.title)
                        .bold()
                        .padding()
                    
                    Button(action: {
                        hasSeenOnboarding = true
                    }) {
                        Text("Start Exploring")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width < -threshold {
                            // Swiped left: go to next page
                            withAnimation {
                                currentPage = min(currentPage + 1, totalPages - 1)
                            }
                        } else if value.translation.width > threshold {
                            // Swiped right: go to previous page
                            withAnimation {
                                currentPage = max(currentPage - 1, 0)
                            }
                        }
                    }
            )
        }
        .frame(width: 350, height: 600)
    }
}

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding()
            
            Text(title)
                .font(.title)
                .bold()
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
