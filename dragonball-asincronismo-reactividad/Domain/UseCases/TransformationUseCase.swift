import Foundation

protocol TransformationUseCaseProtocol {
    var repo: TransformationsRepositoryProtocol { get set }
    func getTransformations(filter: String) async -> [TransformationsModel]
}

final class TransformationUseCase: TransformationUseCaseProtocol {
    var repo: TransformationsRepositoryProtocol
    
    init(repo: TransformationsRepositoryProtocol = TransformationsRepository(network: NetworkTransformation())) {
        self.repo = repo
    }
    
    func getTransformations(filter: String) async -> [TransformationsModel] {
        return await repo.getTransformations(filter: filter)
    }
}

final class TransformationUseCaseFake: TransformationUseCaseProtocol {
    var repo: TransformationsRepositoryProtocol
    
    init(repo: TransformationsRepositoryProtocol = TransformationsRepository(network: NetworkTransformationsFake())) {
        self.repo = repo
    }
    
    func getTransformations(filter: String) async -> [TransformationsModel] {
        return await repo.getTransformations(filter: filter)
    }
}
