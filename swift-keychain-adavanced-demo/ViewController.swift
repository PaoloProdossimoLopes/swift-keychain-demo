import UIKit

typealias ReaderAndWritter = Writter & Reader & Lister & Deleter

final class ViewController: UIViewController {
    
    private var client: ReaderAndWritter
    private let application = "example.appliaction.com"
    
    private lazy var contentView = View()
    
    init(client: ReaderAndWritter) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func loadView() {
        super.loadView()
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        contentView.delegate = self
    }
    
    private func presentAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message:message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "ok", style: .destructive)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension ViewController: ViewDelegate {
    
    func writeDidTapped(_ fields: WriteFields) {
        do {
            try client.write(WritterParams(
                application: application,
                identifier: fields.account,
                secure: fields.password.data(using: .utf8)!
            ))
            presentAlert(
                withTitle: "Write Success",
                message: "Salvo com sucesso"
            )
        } catch let error {
            presentAlert(
                withTitle: "Write Failed",
                message: "Um erro ocorre \(error)"
            )
        }
    }
    
    func getDidTapped(_ fields: ReadFields) {
        do {
            let result = try client.read(ReadParams(
                application: application,
                identifier: fields.account
            ))
            let passwordRecieved = result.secure.asString
            presentAlert(
                withTitle: "Read Success",
                message: "A senha ??: \(passwordRecieved)"
            )
        } catch let error {
            presentAlert(
                withTitle: "Read Failed",
                message: "Um erro ocorre \(error)"
            )
        }
    }
    
    func deleteDidTapped(_ fields: DeleteFields) {
        do {
            try client.delete(DeleteParams(
                application: application,
                identifier: fields.account
            ))
            presentAlert(
                withTitle: "Delete Succeded",
                message: "Conta \(fields.account) removida com successo do keychain"
            )
        } catch let error {
            presentAlert(
                withTitle: "Delete Failed",
                message: "Um erro ocorre \(error)"
            )
        }
    }
    
    func listDidTapped() {
        let params = ListParams(application: application)
        let result = (try? client.list(params)) ?? []
        contentView.reloadList(with: result)
    }
}

private extension Data {
    var asString: String {
        String.init(decoding: self, as: UTF8.self)
    }
}
