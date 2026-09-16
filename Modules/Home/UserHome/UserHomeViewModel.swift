import Foundation
import Combine

class UserHomeViewModel {

    // MARK: - Выходные данные (что вычисляет ViewModel)
    @Published private(set) var events: [EventModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var favoriteEventIds: Set<String> = []

    // MARK: - Внутреннее (сервисы и подписки)
    private let eventService = EventService()
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()
    private var favoriteCancellable: AnyCancellable?

    init() {
        fetchEvents()
        loadFavorites()
    }

    func fetchEvents() {
        isLoading = true
        eventService.fetchEvents()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] events in
                    self?.events = events.sorted { $0.startDate < $1.startDate }
                }
            )
            .store(in: &cancellables)
    }

    private func loadFavorites() {
        guard let uid = authService.currentUserId else { return }
        authService.fetchUserProfile(uid: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] profile in
                    self?.favoriteEventIds = Set(profile.favoriteEventIds)
                }
            )
            .store(in: &cancellables)
    }

    func toggleFavorite(eventId: String) {
        guard let uid = authService.currentUserId else { return }
        let isFavorite = !favoriteEventIds.contains(eventId)

        if isFavorite {
            favoriteEventIds.insert(eventId)
        } else {
            favoriteEventIds.remove(eventId)
        }

        favoriteCancellable = authService.toggleFavorite(uid: uid, eventId: eventId, isFavorite: isFavorite)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        if isFavorite {
                            self?.favoriteEventIds.remove(eventId)
                        } else {
                            self?.favoriteEventIds.insert(eventId)
                        }
                    }
                },
                receiveValue: { _ in }
            )
    }
}
