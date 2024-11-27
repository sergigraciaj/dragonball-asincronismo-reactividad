import UIKit
import Combine

class TransformationsTableViewController: UITableViewController {

    private var appState: AppState?
    private var viewModel: TransformationsViewModel
    var suscriptions = Set<AnyCancellable>()
    
    init(appState: AppState, viewModel: TransformationsViewModel) {
        self.appState = appState
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TransformationsTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeSession))
        // TODO: cambiar el titulo
        self.title = self.viewModel.hero.name
        self.bindingUI()
    }
    
    @objc func closeSession() {
        NSLog("Tap in close session button")
        self.appState?.closeSessionUser()
    }
    
    private func bindingUI() {
        self.viewModel.$transformationsData
            .receive(on: DispatchQueue.main)
            .sink{ data in
                self.tableView.reloadData()
            }
            .store(in: &suscriptions)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.transformationsData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TransformationsTableViewCell
        
        let transformation = self.viewModel.transformationsData[indexPath.row]
        cell.title.text = transformation.name
        cell.photo.loadImageRemote(url: URL(string: transformation.photo)!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

#Preview {
    TransformationsTableViewController(
        appState: AppState(loginUseCase: LoginUseCaseFake()),
        viewModel: TransformationsViewModel(hero: HerosModel(id: "fakeId", favorite: true, description: "fakeDescription", photo: "fakePhoto", name: "fakeName"), useCase: TransformationUseCaseFake()))
}
