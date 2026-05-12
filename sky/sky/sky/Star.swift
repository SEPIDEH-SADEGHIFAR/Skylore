import Foundation
import CoreLocation
import SwiftUI

enum StarCategory: String, Codable, CaseIterable {
    case memory, adventure, home, love, food, nature, work, dream

    var label: String {
        switch self {
        case .memory:    return "Memory"
        case .adventure: return "Adventure"
        case .home:      return "Home"
        case .love:      return "Love"
        case .food:      return "Food"
        case .nature:    return "Nature"
        case .work:      return "Work"
        case .dream:     return "Dream"
        }
    }

    var icon: String {
        switch self {
        case .memory:    return "clock.arrow.circlepath"
        case .adventure: return "map"
        case .home:      return "house.fill"
        case .love:      return "heart.fill"
        case .food:      return "fork.knife"
        case .nature:    return "leaf.fill"
        case .work:      return "briefcase.fill"
        case .dream:     return "moon.stars.fill"
        }
    }

    var color: Color {
        switch self {
        case .memory:    return .cyan
        case .adventure: return .orange
        case .home:      return .yellow
        case .love:      return .pink
        case .food:      return Color(hue: 0.08, saturation: 0.75, brightness: 1.0)
        case .nature:    return .green
        case .work:      return .blue
        case .dream:     return .purple
        }
    }
}

struct Star: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let date: Date
    var category: StarCategory

    enum CodingKeys: String, CodingKey {
        case id, name, description, latitude, longitude, date, category
    }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        coordinate: CLLocationCoordinate2D,
        date: Date = Date(),
        category: StarCategory = .memory
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.coordinate = coordinate
        self.date = date
        self.category = category
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id          = try c.decode(UUID.self,   forKey: .id)
        name        = try c.decode(String.self, forKey: .name)
        description = try c.decode(String.self, forKey: .description)
        let lat     = try c.decode(Double.self, forKey: .latitude)
        let lon     = try c.decode(Double.self, forKey: .longitude)
        coordinate  = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        date        = try c.decode(Date.self,   forKey: .date)
        category    = (try? c.decode(StarCategory.self, forKey: .category)) ?? .memory
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,                   forKey: .id)
        try c.encode(name,                 forKey: .name)
        try c.encode(description,          forKey: .description)
        try c.encode(coordinate.latitude,  forKey: .latitude)
        try c.encode(coordinate.longitude, forKey: .longitude)
        try c.encode(date,                 forKey: .date)
        try c.encode(category,             forKey: .category)
    }
}


class StarViewModel: ObservableObject {
    @Published var stars: [Star] = []
    @Published var selectedStar: Star?

    private let storageKey = "stars_v2"

    init() { loadStars() }

    // MARK: - Stats
    var totalStars: Int { stars.count }

    var regionCount: Int {
        // Approximate unique regions via 5-degree coordinate tiles
        Set(stars.map {
            "\(Int($0.coordinate.latitude  / 5) * 5),\(Int($0.coordinate.longitude / 5) * 5)"
        }).count
    }

    // MARK: - CRUD
    func addStar(coordinate: CLLocationCoordinate2D,
                 name: String,
                 description: String,
                 date: Date,
                 category: StarCategory) {
        stars.append(Star(name: name, description: description,
                          coordinate: coordinate, date: date, category: category))
        saveStars()
    }

    func removeStar(_ star: Star) {
        stars.removeAll { $0.id == star.id }
        saveStars()
    }

    // Maps a geographic coordinate to a 2D canvas point
    func position(for coordinate: CLLocationCoordinate2D, in size: CGSize) -> CGPoint {
        CGPoint(
            x: (coordinate.longitude + 180) / 360 * size.width,
            y: (1 - (coordinate.latitude + 90) / 180) * size.height
        )
    }

    // MARK: - Persistence
    private func saveStars() {
        if let data = try? JSONEncoder().encode(stars) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadStars() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Star].self, from: data)
        else { return }
        stars = decoded
    }
}
