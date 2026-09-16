import Foundation
import Combine

final class EditProfileViewModel {

    // MARK: - Входные данные (что вводит пользователь)
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    // MARK: - Выходные данные (что вычисляет ViewModel)
    @Published private(set) var isReadyToSave: Bool = false
    @Published private(set) var isSaving: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Внутреннее (сервисы и подписки)
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()
    private var original: (firstName: String, lastName: String) = ("", "")

    init() {
        setupSubscription()
        loadProfile()
    }

    /// Сохранять можно только непустые и изменённые данные.
    private func setupSubscription() {
        $firstName.combineLatest($lastName)
            .map { [weak self] firstName, lastName in
                let first = firstName.trimmingCharacters(in: .whitespaces)
                let last = lastName.trimmingCharacters(in: .whitespaces)
                guard !first.isEmpty, !last.isEmpty else { return false }
                return (first, last) != (self?.original.firstName, self?.original.lastName)
            }
            .removeDuplicates()
            .assign(to: &$isReadyToSave)
    }

    private func loadProfile() {
        // Сначала — кэш, чтобы поля не были пустыми, потом — актуальные данные из Firestore.
        let cached = (UserDefaults.standard.userName ?? "").split(separator: " ", maxSplits: 1).map(String.init)
        firstName = cached.first ?? ""
        lastName = cached.count > 1 ? cached[1] : ""
        original = (firstName, lastName)

        guard let uid = authService.currentUserId else { return }
        authService.fetchUserProfile(uid: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] profile in
                    self?.original = (profile.firstName, profile.lastName)
                    self?.firstName = profile.firstName
                    self?.lastName = profile.lastName
                }
            )
            .store(in: &cancellables)
    }

    func save() -> AnyPublisher<Void, Error> {
        guard let uid = authService.currentUserId else {
            return Fail(error: AuthError.userNotFound).eraseToAnyPublisher()
        }
        let first = firstName.trimmingCharacters(in: .whitespaces)
        let last = lastName.trimmingCharacters(in: .whitespaces)
        isSaving = true
        errorMessage = nil
        return authService.updateName(uid: uid, firstName: first, lastName: last)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] in self?.original = (first, last) },
                receiveCompletion: { [weak self] completion in
                    self?.isSaving = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
