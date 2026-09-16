import UIKit
import Combine

final class LoginViewController: UIViewController {

    var onLoginSuccess: ((AuthUser) -> Void)?
    var onSignUpTap: (() -> Void)?

    private let viewModel: LoginViewModel
    private let loginView = LoginView()
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLanguageControl()
        updateTexts()
        setupBindings()
    }

    private func setupLanguageControl() {
        let languages = ["ru", "en", "kk"]
        if let index = languages.firstIndex(of: LocalizationManager.shared.currentLanguage) {
            loginView.languageControl.selectedSegmentIndex = index
        }
        loginView.languageControl.addTarget(self, action: #selector(languageChanged), for: .valueChanged)
    }

    private func updateTexts() {
        title = L("login_title")
        loginView.emailTextField.placeholder = L("login_email_placeholder")
        loginView.passwordTextField.placeholder = L("login_password_placeholder")
        loginView.loginButton.setTitle(L("login_button"), for: .normal)
        loginView.noAccountButton.setTitle(L("login_no_account"), for: .normal)
        updateGreeting()
    }

    private func updateGreeting() {
        if let name = UserDefaults.standard.userName {
            loginView.greetingLabel.text = String(format: L("login_welcome_back"), name)
        } else {
            loginView.greetingLabel.text = L("login_welcome_new")
        }
    }

    @objc private func languageChanged() {
        let languages = ["ru", "en", "kk"]
        let code = languages[loginView.languageControl.selectedSegmentIndex]
        LocalizationManager.shared.setLanguage(code)
        updateTexts()
    }

    // MARK: - Связывание View и ViewModel
    private func setupBindings() {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: loginView.emailTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .receive(on: DispatchQueue.main)
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: loginView.passwordTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .receive(on: DispatchQueue.main)
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)

        viewModel.$isReadyToSignIn
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReady in
                self?.loginView.loginButton.isEnabled = isReady
                self?.loginView.loginButton.alpha = isReady ? 1 : 0.5
            }
            .store(in: &cancellables)

        loginView.loginButton.addAction(UIAction { [weak self] _ in
            self?.loginTapped()
        }, for: .touchUpInside)

        loginView.noAccountButton.addAction(UIAction { [weak self] _ in
            self?.onSignUpTap?()
        }, for: .touchUpInside)
    }

    // MARK: - Действия по нажатию
    private func loginTapped() {
        loginView.errorLabel.isHidden = true

        viewModel.signIn()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.loginView.errorLabel.text = error.localizedDescription
                        self?.loginView.errorLabel.isHidden = false
                    }
                },
                receiveValue: { [weak self] user in
                    self?.onLoginSuccess?(user)
                }
            )
            .store(in: &cancellables)
    }
}
