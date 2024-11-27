import Foundation

struct HerosModel: Codable {
    let id: String
    let favorite: Bool
    let description: String
    let photo: String
    let name: String
}

struct HeroModelRequest: Codable {
    let name: String
}
