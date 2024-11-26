final class TransformationsRepository: TransformationsRepositoryProtocol {
    private var network: NetworkTransformationsProtocol
    
    init(network: NetworkTransformationsProtocol) {
        self.network = network
    }
    
    func getTransformations(filter: String) async -> [TransformationsModel] {
        return await network.getTransformations(filter: filter)
    }
}

final class TransformationsRepositoryFake: TransformationsRepositoryProtocol {
    private var network: NetworkTransformationsProtocol
    
    init(network: NetworkTransformationsProtocol = NetworkTransformationsFake()) {
        self.network = network
    }
    
    func getTransformations(filter: String) async -> [TransformationsModel] {
        return await network.getTransformations(filter: filter)
    }
}
