import UIKit

class LoginView: UIView {

    let languageControl = UISegmentedControl(items: ["RU", "EN", "KK"])

    let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .eventHubAccent
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = L("login_email_placeholder")
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = L("login_password_placeholder")
        textField.isSecureTextEntry = true
        textField.textContentType = .oneTimeCode
        return textField
    }()

    let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .eventHubError
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L("login_button"), for: .normal)
        button.backgroundColor = .eventHubAccent
        button.setTitleColor(.eventHubOnAccent, for: .normal)
        button.layer.cornerRadius = 12
        button.isEnabled = false
        return button
    }()

    let noAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L("login_no_account"), for: .normal)
        button.setTitleColor(.eventHubAccent, for: .normal)
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .eventHubBackground
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        languageControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: .normal)

        [emailTextField, passwordTextField, errorLabel, loginButton, noAccountButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }

        [languageControl, greetingLabel, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            languageControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            languageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            languageControl.heightAnchor.constraint(equalToConstant: 28),
            languageControl.widthAnchor.constraint(equalToConstant: 150),

            greetingLabel.topAnchor.constraint(equalTo: languageControl.bottomAnchor, constant: 18),
            greetingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            greetingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            stackView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            emailTextField.heightAnchor.constraint(equalToConstant: 48),
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
