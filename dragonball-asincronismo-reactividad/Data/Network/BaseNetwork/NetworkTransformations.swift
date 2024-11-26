import Foundation
import KcLibraryswift

protocol NetworkTransformationsProtocol {
    func getTransformations(filter: String) async -> [TransformationsModel]
}

final class NetworkTransformation: NetworkTransformationsProtocol {
    func getTransformations(filter: String) async -> [TransformationsModel] {
        var modelReturn = [TransformationsModel]()
        
        let urlCad : String = "\(ConstantsApp.CONST_API_URL)\(EndPoints.transformations.rawValue)"
        var request : URLRequest = URLRequest(url: URL(string: urlCad)!)
        request.httpMethod = HTTPMethods.post
        request.httpBody = try? JSONEncoder().encode(TransformationModelRequest(id: filter))
        request.addValue(HTTPMethods.content, forHTTPHeaderField: "Content-type")
    
        let JwtToken =  KeyChainKC().loadKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        if let tokenJWT = JwtToken{
            request.addValue("Bearer \(tokenJWT)", forHTTPHeaderField: "Authorization") //Token
        }
        
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            if let resp = response  as? HTTPURLResponse {
                if resp.statusCode == HTTPResponseCodes.SUCCESS {
                    modelReturn = try! JSONDecoder().decode([TransformationsModel].self, from: data)
                }
            }
        }catch{
            
        }
        return modelReturn
    }
}

final class NetworkTransformationsFake: NetworkTransformationsProtocol {
    func getTransformations(filter: String) async -> [TransformationsModel] {
        return getTransformationsFromJson()
    }
}

func getTransformationsFromJson() -> [TransformationsModel] {
    if let url = Bundle.main.url(forResource: "transformations", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([TransformationsModel].self, from: data)
            return jsonData
        } catch {
            print("error:\(error)")
        }
    }
    return []
}
