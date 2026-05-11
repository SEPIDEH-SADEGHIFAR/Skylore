import Foundation
import CoreLocation

struct Star: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let date: Date

    enum CodingKeys: String, CodingKey {
        case id, name, description, latitude, longitude, date
    }

    init(id: UUID = UUID(), name: String, description: String, coordinate: CLLocationCoordinate2D, date: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.coordinate = coordinate
        self.date = date
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        date = try container.decode(Date.self, forKey: .date)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(date, forKey: .date)
    }
}

class StarViewModel: ObservableObject {
    @Published var stars: [Star] = []
    @Published var selectedStar: Star?

    private let storageKey = "stars"

    init() {
        loadStars()
    }

    func addStar(coordinate: CLLocationCoordinate2D, name: String, description: String, date: Date) {
        let newStar = Star(name: name, description: description, coordinate: coordinate, date: date)
        stars.append(newStar)
        saveStars()
    }

    func removeStar(_ star: Star) {
        stars.removeAll { $0.id == star.id }
        saveStars()
    }

    func position(for coordinate: CLLocationCoordinate2D, in size: CGSize) -> CGPoint {
        let x = (coordinate.longitude + 180) / 360 * size.width
        let y = (1 - (coordinate.latitude + 90) / 180) * size.height
        return CGPoint(x: x, y: y)
    }

    private func saveStars() {
        if let encodedData = try? JSONEncoder().encode(stars) {
            UserDefaults.standard.set(encodedData, forKey: storageKey)
        }
    }

    private func loadStars() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decodedStars = try? JSONDecoder().decode([Star].self, from: savedData) {
            stars = decodedStars
        }
    }
}

/*// MARK: - Milky Way Color Helper
func milkyWayColor(from coordinate: CLLocationCoordinate2D) -> Color {
    let seed = abs(sin(coordinate.latitude * 14.313 + coordinate.longitude * 37.137))
    let t = seed.truncatingRemainder(dividingBy: 1.0)
    
    let palette: [Color] = [
        Color(hue: 0.6, saturation: 0.8, brightness: 1.0),  // Deep blue
        Color(hue: 0.75, saturation: 0.7, brightness: 1.0), // Neon violet
        Color(hue: 0.9, saturation: 0.6, brightness: 1.0),  // Pinkish
        Color(hue: 0.12, saturation: 0.8, brightness: 1.0), // Gold
        Color(hue: 0.5, saturation: 0.8, brightness: 1.0)   // Cyan
    ]
    
    let index = Int(t * Double(palette.count)) % palette.count
    return palette[index]
}*/
