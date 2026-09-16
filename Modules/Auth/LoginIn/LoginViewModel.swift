import Foundation
import Combine

class LoginViewModel {

    // MARK: - Входные данные (что вводит пользователь)
    @Published var email: String = ""
    @Published var password: String = ""

    // MARK: - Выходные данные (что вычисляет ViewModel)
    @Published private(set) var isReadyToSignIn: Bool = false

    // MARK: - Внутреннее (сервисы и подписки)
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        $email.combineLatest($password)
            .map { email, password in
                !email.isEmpty && email.contains("@") && password.count >= 6
            }
            .removeDuplicates()
            .assign(to: &$isReadyToSignIn)
    }

    func signIn() -> AnyPublisher<AuthUser, Error> {
        authService.signIn(email: email, password: password)
    }
}
