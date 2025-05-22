
import Foundation
import CoreLocation

struct Star: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let coordinate: CLLocationCoordinate2D

    enum CodingKeys: String, CodingKey {
        case id, name, description, latitude, longitude
    }

    init(id: UUID = UUID(), name: String, description: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.description = description
        self.coordinate = coordinate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}

//star view model
class StarViewModel: ObservableObject {
    @Published var stars: [Star] = []
    @Published var selectedStar: Star?

    private let storageKey = "stars"

    init() {
        loadStars()
    }

    func addStar(coordinate: CLLocationCoordinate2D, name: String, description: String) {
        let newStar = Star(name: name, description: description, coordinate: coordinate)
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
