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

