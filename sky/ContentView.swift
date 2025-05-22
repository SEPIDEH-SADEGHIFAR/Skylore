import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var selectedLocation: SearchResult?
    
    var body: some View {
        ZStack {
            MapView(region: $locationManager.region, 
                   selectedLocation: $selectedLocation)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                LocationSearchView(region: $locationManager.region, 
                                 selectedResult: $selectedLocation)
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 