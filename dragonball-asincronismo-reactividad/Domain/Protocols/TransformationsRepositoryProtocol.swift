import Foundation

protocol TransformationsRepositoryProtocol {
    func getTransformations(filter: String) async -> [TransformationsModel]
}
