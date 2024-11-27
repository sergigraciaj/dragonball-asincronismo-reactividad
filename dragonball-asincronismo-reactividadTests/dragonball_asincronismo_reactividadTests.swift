import XCTest
import Combine
import KcLibraryswift
import CombineCocoa
import UIKit
@testable import dragonball_asincronismo_reactividad

final class Tests: XCTestCase {
    let hero = HerosModel(id: "fakeId", favorite: true, description: "fakeDescription", photo: "fakePhoto", name: "fakeName")
    
    func testKeyChainLibrary() throws {
        let KC = KeyChainKC()
        XCTAssertNotNil(KC)
        
        let save = KC.saveKC(key: "Test", value: "123")
        XCTAssertEqual(save, true)
        
        let value = KC.loadKC(key: "Test")
        if let valor = value {
            XCTAssertEqual(valor, "123")
        }
        XCTAssertNoThrow(KC.deleteKC(key: "Test"))
    }
    
    func testLoginFake() async throws {
        let KC = KeyChainKC()
        XCTAssertNotNil(KC)
        
        
        let obj = LoginUseCaseFake()
        XCTAssertNotNil(obj)
        
        //Validate Token
        let resp = await obj.validateToken()
        XCTAssertEqual(resp, true)
        
        
        // login
        let loginDo = await obj.loginApp(user: "", password: "")
        XCTAssertEqual(loginDo, true)
        var jwt = KC.loadKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        XCTAssertNotEqual(jwt, "")
        
        //Close Session
        await obj.logout()
        jwt = KC.loadKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        XCTAssertEqual(jwt, "")
    }
    
    func testLoginReal() async throws  {
        let CK = KeyChainKC()
        XCTAssertNotNil(CK)
        //reset the token
        CK.saveKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN, value: "")
        
        //Caso se uso con repo Fake
        let userCase = LoginUseCase(repo: LoginRepositoryFake())
        XCTAssertNotNil(userCase)
        
        //validacion
        let resp = await userCase.validateToken()
        XCTAssertEqual(resp, false)
        
        //login
        let loginDo = await userCase.loginApp(user: "", password: "")
        XCTAssertEqual(loginDo, true)
        var jwt = CK.loadKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        XCTAssertNotEqual(jwt, "")
        
        //Close Session
        await userCase.logout()
        jwt = CK.loadKC(key: ConstantsApp.CONST_TOKEN_ID_KEYCHAIN)
        XCTAssertEqual(jwt, "")
    }
    
    func testLoginAutoLoginAsincrono()  throws  {
        var suscriptor = Set<AnyCancellable>()
        let exp = self.expectation(description: "Login Auto ")
        
        let vm = AppState(loginUseCase: LoginUseCaseFake())
        XCTAssertNotNil(vm)
        
        vm.$statusLogin
            .sink { completion in
                switch completion{
                    
                case .finished:
                    print("finalizado")
                }
            } receiveValue: { estado in
                if estado == .success {
                    exp.fulfill()
                }
            }
            .store(in: &suscriptor)

         vm.validateControlLogin()
        
        self.waitForExpectations(timeout: 10)
    }
    
    func testUIErrorView() async throws  {

        let appStateVM = AppState(loginUseCase: LoginUseCaseFake())
        XCTAssertNotNil(appStateVM)

        appStateVM.statusLogin = .error
        
        let vc = await ErrorViewController(appState: appStateVM, error: "Error Testing")
        XCTAssertNotNil(vc)
    }
    
    func testUILoginView()  throws  {
        XCTAssertNoThrow(LoginView())
        let view = LoginView()
        XCTAssertNotNil(view)
        
        let logo =   view.getLogoImageView()
        XCTAssertNotNil(logo)
        let txtUser = view.getEmailView()
        XCTAssertNotNil(txtUser)
        let txtPass = view.getPasswordView()
        XCTAssertNotNil(txtPass)
        let button = view.getLoginButtonView()
        XCTAssertNotNil(button)
        
        XCTAssertEqual(txtUser.placeholder, "Correo electrónico")
        XCTAssertEqual(txtPass.placeholder, "Clave")
        XCTAssertEqual(button.titleLabel?.text, "Login")
        
        
        //la vista esta generada
       let View2 =  LoginViewController(appState: AppState(loginUseCase: LoginUseCaseFake()))
       XCTAssertNotNil(View2)
        XCTAssertNoThrow(View2.loadView()) //generamos la vista
        XCTAssertNotNil(View2.loginButton)
        XCTAssertNotNil(View2.emailTextfield)
        XCTAssertNotNil(View2.logo)
        XCTAssertNotNil(View2.passwordTextfield)
        
        //el binding
        XCTAssertNoThrow(View2.bindingUI())
        
        View2.emailTextfield?.text = "Hola"
        
        //el boton debe estar desactivado
        XCTAssertEqual(View2.emailTextfield?.text, "Hola")
    }
    
    func testHeroiewViewModel() async throws  {
        let vm = HerosViewModel(useCase: HeroUseCaseFake())
        XCTAssertNotNil(vm)
        sleep(10)
        XCTAssertEqual(vm.herosData.count, 2) //debe haber 2 heroes Fake mokeados
    }
    
    func testHerosUseCase() async throws  {
       let caseUser = HeroUseCase(repo: HerosRepositoryFake())
        XCTAssertNotNil(caseUser)
        
        let data = await caseUser.getHeros(filter: "")
        XCTAssertNotNil(data)
        XCTAssertEqual(data.count, 2)
    }
    
    func testHeros_Combine() async throws  {
        var suscriptor = Set<AnyCancellable>()
        let exp = self.expectation(description: "Heros get")
        
        let vm = HerosViewModel(useCase: HeroUseCaseFake())
        XCTAssertNotNil(vm)
        
        vm.$herosData
            .sink { completion in
                switch completion{
                    
                case .finished:
                    print("finalizado")
                }
            } receiveValue: { data in
      
                if data.count == 2 {
                    exp.fulfill()
                }
            }
            .store(in: &suscriptor)
      
        
        await fulfillment(of: [exp], timeout: 10)
    }
    
    func testHeros_Data() async throws  {
        let network = NetworkHerosFake()
        XCTAssertNotNil(network)
        let repo = HerosRepository(network: network)
        XCTAssertNotNil(repo)
        
        let repo2 = HerosRepositoryFake()
        XCTAssertNotNil(repo2)
        
        let data = await repo.getHeros(filter: "")
        XCTAssertNotNil(data)
        XCTAssertEqual(data.count, 2)
        
        
        let data2 = await repo2.getHeros(filter: "")
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2.count, 2)
    }
    
    func testHeros_Domain() async throws  {
       //Models
        let model = hero
        XCTAssertNotNil(model)
        XCTAssertEqual(model.name, "fakeName")
        XCTAssertEqual(model.favorite, true)
        
        let requestModel = HeroModelRequest(name: "goku")
        XCTAssertNotNil(requestModel)
        XCTAssertEqual(requestModel.name, "goku")
    }
    
    func testHeros_Presentation() async throws  {
        let viewModel = HerosViewModel(useCase: HeroUseCaseFake())
        XCTAssertNotNil(viewModel)
        
        let view =  await HerosTableViewController(appState: AppState(loginUseCase: LoginUseCaseFake()), viewModel: viewModel)
        XCTAssertNotNil(view)
        
    }
    
    func testTransformationsViewModel() async throws  {
        let vm = TransformationsViewModel(hero: hero, useCase: TransformationUseCaseFake())
        XCTAssertNotNil(vm)
        sleep(10)
        XCTAssertEqual(vm.transformationsData.count, 3) //debe haber 3 transformaciones Fake mokeadas
    }
    
    func testTransformationsUseCase() async throws  {
       let caseUser = TransformationUseCase(repo: TransformationsRepositoryFake())
        XCTAssertNotNil(caseUser)
        
        let data = await caseUser.getTransformations(filter: "fakeId")
        XCTAssertNotNil(data)
        XCTAssertEqual(data.count, 3)
    }
    
    func testTransformations_Combine() async throws  {
        var suscriptor = Set<AnyCancellable>()
        let exp = self.expectation(description: "Transformations get")
        
        let vm = TransformationsViewModel(hero: hero, useCase: TransformationUseCaseFake())
        XCTAssertNotNil(vm)
        
        vm.$transformationsData
            .sink { completion in
                switch completion{
                    
                case .finished:
                    print("finalizado")
                }
            } receiveValue: { data in
      
                if data.count == 3 {
                    exp.fulfill()
                }
            }
            .store(in: &suscriptor)
      
        
        await fulfillment(of: [exp], timeout: 10)
    }
    
    func testTransformations_Data() async throws  {
        let network = NetworkTransformationsFake()
        XCTAssertNotNil(network)
        let repo = TransformationsRepository(network: network)
        XCTAssertNotNil(repo)
        
        let repo2 = TransformationsRepositoryFake()
        XCTAssertNotNil(repo2)
        
        let data = await repo.getTransformations(filter: "fakeId")
        XCTAssertNotNil(data)
        XCTAssertEqual(data.count, 3)
        
        
        let data2 = await repo2.getTransformations(filter: "fakeId")
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2.count, 3)
    }
    
    func testTransformations_Domain() async throws  {
       //Models
        let transformationHero = TransformationHero(id: "fakeId")
        let model = TransformationsModel(id: "fakeId", name: "fakeName", description: "fakeDescription", photo: "fakePhoto", hero: transformationHero)
        XCTAssertNotNil(model)
        XCTAssertEqual(model.name, "fakeName")
        
        let requestModel = HeroModelRequest(name: "transformación de goku")
        XCTAssertNotNil(requestModel)
        XCTAssertEqual(requestModel.name, "transformación de goku")
    }
    
    func testTransformation_Presentation() async throws  {
        let viewModel = TransformationsViewModel(hero: hero, useCase: TransformationUseCaseFake())
        XCTAssertNotNil(viewModel)
        
        let view =  await TransformationsTableViewController(appState: AppState(loginUseCase: LoginUseCaseFake()), viewModel: viewModel)
        XCTAssertNotNil(view)
        
    }
}
