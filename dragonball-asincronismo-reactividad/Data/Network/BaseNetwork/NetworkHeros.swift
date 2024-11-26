import Foundation
import KcLibraryswift

protocol NetworkHerosProtocol {
    func getHeros(filter: String) async -> [HerosModel]
}

final class NetworkHeros: NetworkHerosProtocol {
    func getHeros(filter: String) async -> [HerosModel] {
        var modelReturn = [HerosModel]()
        
        let urlCad : String = "\(ConstantsApp.CONST_API_URL)\(EndPoints.heros.rawValue)"
        var request : URLRequest = URLRequest(url: URL(string: urlCad)!)
        request.httpMethod = HTTPMethods.post
        request.httpBody = try? JSONEncoder().encode(HeroModelRequest(name: filter))
        request.addValue(HTTPMethods.content, forHTTPHeaderField: "Content-type")
    
        let JwtToken =  KeyChainKC().loadKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        if let tokenJWT = JwtToken{
            request.addValue("Bearer \(tokenJWT)", forHTTPHeaderField: "Authorization") //Token
        }
        
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            if let resp = response  as? HTTPURLResponse {
                if resp.statusCode == HTTPResponseCodes.SUCCESS {
                    modelReturn = try! JSONDecoder().decode([HerosModel].self, from: data)
                }
            }
        }catch{
            
        }
        return modelReturn
    }
}

final class NetworkHerosFake: NetworkHerosProtocol {
    func getHeros(filter: String) async -> [HerosModel] {
        return getHerosFromJson()
    }
}

func getHerosFromJson() -> [HerosModel] {
    if let url = Bundle.main.url(forResource: "heros", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([HerosModel].self, from: data)
            return jsonData
        } catch {
            print("error:\(error)")
        }
    }
    return []
}
