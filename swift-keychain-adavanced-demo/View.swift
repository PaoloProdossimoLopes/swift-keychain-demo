import UIKit

struct WriteFields {
    let account: String
    let password: String
}

struct ReadFields {
    let account: String
}

protocol ViewDelegate: AnyObject {
    func writeDidTapped(_ fields: WriteFields)
    func getDidTapped(_ fields: ReadFields)
}

final class View: UIView {
    
    weak var delegate: ViewDelegate?
    
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
            getAccountPlaceholder, getButton, UIView()
        ].forEach(stack.addArrangedSubview)
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
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
}
