import SwiftUI

struct StarDetailsSheet: View {
    let star: Star
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 20) {
                    Text("⭐ \(star.name)")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    Text("Latitude: \(star.coordinate.latitude)")
                        .font(.title3)
                    Text("Longitude: \(star.coordinate.longitude)")
                        .font(.title3)
                    Text("Description:")
                                            .font(.title2)
                                            .bold()
                                        Text(star.description)
                                            .font(.body)
                    Spacer()
                    
                }
                .padding(.leading, 20)
                .padding()
            }
            .navigationTitle("Star Details")
            .navigationBarItems(trailing: Button("Done") { dismiss() }
                                    .foregroundColor(.white))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
