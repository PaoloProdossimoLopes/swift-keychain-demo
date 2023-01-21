import UIKit

struct WriteFields {
    let account: String
    let password: String
}

struct ReadFields {
    let account: String
}

struct DeleteFields {
    let account: String
}

protocol ViewDelegate: AnyObject {
    func writeDidTapped(_ fields: WriteFields)
    func getDidTapped(_ fields: ReadFields)
    func deleteDidTapped(_ fields: DeleteFields)
    func listDidTapped()
}

final class View: UIView {
    
    weak var delegate: ViewDelegate?
    private var params = [ListResult]()
    
    private lazy var writeAccountPlaceholder: UITextField = {
        let field = UITextField()
        field.placeholder = "Account"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var writePasswordPlaceholder: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var writeButton: UIButton = {
        let button = UIButton()
        button.setTitle("WRITE", for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: #selector(writeDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var getAccountPlaceholder: UITextField = {
        let field = UITextField()
        field.placeholder = "Account"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var getButton: UIButton = {
        let button = UIButton()
        button.setTitle("GET", for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: #selector(getDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteAccountPlaceholder: UITextField = {
        let field = UITextField()
        field.placeholder = "Account"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Delete", for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: #selector(deleteDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var listButton: UIButton = {
        let button = UIButton()
        button.setTitle("List", for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: #selector(listDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        return table
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [
            writeAccountPlaceholder, writePasswordPlaceholder, writeButton,
            getAccountPlaceholder, getButton,
            deleteAccountPlaceholder, deleteButton,
            listButton, tableView
        ].forEach(stack.addArrangedSubview)
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func reloadList(with result: [ListResult]) {
        params = result
        tableView.reloadData()
    }
    
    required init?(coder: NSCoder) { nil }
    
    @objc private func writeDidTapped() {
        delegate?.writeDidTapped(WriteFields(
            account: writeAccountPlaceholder.text!,
            password: writePasswordPlaceholder.text!
        ))
    }
    
    @objc private func getDidTapped() {
        delegate?.getDidTapped(ReadFields(
            account: getAccountPlaceholder.text!
        ))
    }
    
    @objc private func deleteDidTapped() {
        delegate?.deleteDidTapped(DeleteFields(
            account: getAccountPlaceholder.text!
        ))
    }
    
    @objc private func listDidTapped() {
        delegate?.listDidTapped()
    }
}

extension View: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        params.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let param = params[indexPath.row]
        cell.textLabel?.text = """
        Aplication: \(param.application)
        Identifier: \(param.identifier)
        Security: \(param.security)
        """
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        return cell
    }
}
