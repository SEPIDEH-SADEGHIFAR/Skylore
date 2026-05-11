import SwiftUI

struct StarDetailsSheet: View {
    let star: Star
    @Environment(\.dismiss) var dismiss

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: star.date)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic Nebula Gradient
                LinearGradient(
                    gradient: Gradient(colors: [milkyWayColor(from: star.coordinate).opacity(0.6), Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                GlitteringStarsBackground().opacity(0.3)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(star.name.uppercased())
                            .font(.system(size: 36, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .shadow(color: milkyWayColor(from: star.coordinate), radius: 10)

                        HStack(spacing: 15) {
                            VStack(alignment: .leading) {
                                Text("LATITUDE").font(.caption2).foregroundColor(.gray).tracking(2)
                                Text(String(format: "%.4f", star.coordinate.latitude)).font(.system(.body, design: .monospaced))
                            }
                            VStack(alignment: .leading) {
                                Text("LONGITUDE").font(.caption2).foregroundColor(.gray).tracking(2)
                                Text(String(format: "%.4f", star.coordinate.longitude)).font(.system(.body, design: .monospaced))
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("MEMORY LOG - \(formattedDate.uppercased())")
                                .font(.caption2).foregroundColor(.gray).tracking(2)
                            
                            Text(star.description)
                                .font(.body)
                                .lineSpacing(6)
                                .foregroundColor(Color(red: 240/255, green: 240/255, blue: 255/255))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)

                    }
                    .padding(25)
                }
            }
            .navigationBarItems(trailing: Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            })
        }
        .preferredColorScheme(.dark)
    }
}
