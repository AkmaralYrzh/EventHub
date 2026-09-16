import UIKit
import Combine

class SignUpViewController: UIViewController {

    // MARK: - Замыкания (их задаёт AppCoordinator)
    var onSignUpSuccess: (() -> Void)?

    private let viewModel: SignUpViewModel
    private let signUpView = SignUpView()
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = signUpView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L("signup_title")
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupBindings() {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: signUpView.firstNameField)
            .compactMap { ($0.object as? UITextField)?.text }
            .receive(on: DispatchQueue.main)
            .assign(to: \.firstName, on: viewModel)
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: signUpView.lastNameField)
            .compactMap { ($0.object as? UITextField)?.text }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastName, on: viewModel)
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: signUpView.emailField)
            .compactMap { ($0.object as? UITextField)?.text }
            .receive(on: DispatchQueue.main)
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: signUpView.passwordField)
            .compactMap { ($0.object as? UITextField)?.text }
            .receive(on: DispatchQueue.main)
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: signUpView.confirmPasswordField)
            .compactMap { ($0.object as? UITextField)?.text }
            .receive(on: DispatchQueue.main)
            .assign(to: \.confirmPassword, on: viewModel)
            .store(in: &cancellables)

        viewModel.$isReadyToSignUp
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReady in
                self?.signUpView.signUpButton.isEnabled = isReady
                self?.signUpView.signUpButton.alpha = isReady ? 1 : 0.5
            }
            .store(in: &cancellables)

        signUpView.roleControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.viewModel.role = self.signUpView.roleControl.selectedSegmentIndex == 0 ? .user : .organizer
        }, for: .valueChanged)

        signUpView.signUpButton.addAction(UIAction { [weak self] _ in
            self?.signUpTapped()
        }, for: .touchUpInside)
    }

    private func signUpTapped() {
            signUpView.errorLabel.isHidden = true

        viewModel.signUp()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.signUpView.errorLabel.text = error.localizedDescription
                        self?.signUpView.errorLabel.isHidden = false
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.onSignUpSuccess?()
                }
            )
            .store(in: &cancellables)
    }
}
