import Foundation

final class TransformationsViewModel: ObservableObject {
    @Published var transformationsData = [TransformationsModel]()
    
    private var useCaseTransformations: TransformationUseCaseProtocol
    var hero: HerosModel
    
    init(hero: HerosModel, useCase: TransformationUseCaseProtocol = TransformationUseCase()) {
        self.useCaseTransformations = useCase
        self.hero = hero
        Task {
            await getTransformations(id: hero.id)
        }
    }
    
    func getTransformations(id: String) async {
        let data = await useCaseTransformations.getTransformations(filter: id)
        
        DispatchQueue.main.async {
            self.transformationsData = data
            print("yup", self.transformationsData)
        }
    }
}
