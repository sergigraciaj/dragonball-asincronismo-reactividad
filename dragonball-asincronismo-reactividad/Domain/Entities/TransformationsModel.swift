struct TransformationsModel: Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let photo: String
    let hero: TransformationHero
}

struct TransformationHero: Codable, Equatable {
    let id: String
}

struct TransformationModelRequest: Codable {
    let id: String
}
