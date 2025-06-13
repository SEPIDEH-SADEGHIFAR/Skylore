import SwiftUI

struct StarDetailsSheet: View {
    let star: Star
    @Environment(\.dismiss) var dismiss

    // Date formatter to display date nicely
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: star.date)
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.3, blue: 0.5),
                        Color(red: 0.2, green: 0.8, blue: 0.6),
                        Color(red: 0.5, green: 0.4, blue: 0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    Text("Meet \(star.name)")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)

                    Text("Born at Latitude: \(star.coordinate.latitude)")
                        .font(.title3)
                    Text("and Longitude: \(star.coordinate.longitude)")
                        .font(.title3)

                    Text("Memory Date: \(formattedDate)")
                        .font(.title3)
                        .italic()
                    
                    Text("A memory written in the sky:")
                        .font(.title2)
                        .bold()

                    Text(star.description)
                        .font(.body)

                    Spacer()
                }
                .padding(.leading, 5)
                .padding()
                .foregroundColor(Color(red: 230/255, green: 230/255, blue: 250/255))
            }
            .navigationTitle("Your Star’s Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Star’s Story")
                        .font(.headline)
                        .foregroundColor(Color(red: 230/255, green: 230/255, blue: 250/255))
                }
            }
            .navigationBarItems(trailing: Button("Done") { dismiss() }
                                    .foregroundColor(.white))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
