import SwiftUI
import MapKit

struct StarDetailsSheet: View {
    let star: Star
    @Environment(\.dismiss) var dismiss

    @State private var mapRegion: MKCoordinateRegion

    init(star: Star) {
        self.star = star
        self._mapRegion = State(initialValue: MKCoordinateRegion(
            center: star.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        ))
    }

    private var formattedDate: String {
        let f = DateFormatter(); f.dateStyle = .long
        return f.string(from: star.date)
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [star.category.color.opacity(0.35), Color(red: 0.04, green: 0.04, blue: 0.09)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                GlitteringStarsBackground().opacity(0.2)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Header
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                               // Text(star.category.emoji).font(.title)
                                Text(star.category.label.uppercased())
                                    .font(.caption2).tracking(2)
                                    .foregroundColor(star.category.color)
                                    .padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(star.category.color.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            Text(star.name.uppercased())
                                .font(.system(size: 30, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                                .shadow(color: star.category.color.opacity(0.7), radius: 10)
                        }

                        // Mini map
                        Map(coordinateRegion: .constant(mapRegion),
                            interactionModes: [],
                            annotationItems: [star]) { s in
                            // Pass the SwiftUI Color directly here:
                            MapMarker(coordinate: s.coordinate, tint: s.category.color)
                        }
                        .frame(height: 190)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(star.category.color.opacity(0.35), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 10)

                        // Coordinates row
                        HStack(spacing: 12) {
                            coordCard(label: "LATITUDE",
                                      value: String(format: "%.4f°", star.coordinate.latitude))
                            coordCard(label: "LONGITUDE",
                                      value: String(format: "%.4f°", star.coordinate.longitude))
                        }

                        // Date
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundColor(star.category.color)
                            Text(formattedDate)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)

                        // Memory log
                        if !star.description.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("MEMORY LOG")
                                    .font(.caption2).foregroundColor(.gray).tracking(2)
                                Text(star.description)
                                    .font(.body)
                                    .lineSpacing(6)
                                    .foregroundColor(Color(red: 0.92, green: 0.92, blue: 1.0))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func coordCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.caption2).foregroundColor(.gray).tracking(2)
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
