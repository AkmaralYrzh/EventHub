import Foundation
import Combine

class FavoritesViewModel {

    @Published private(set) var events: [EventModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let eventService = EventService()
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()
    private var favoriteCancellable: AnyCancellable?

    init() {
        refresh()
    }

    func refresh() {
        guard let uid = authService.currentUserId else { return }
        isLoading = true

        authService.fetchUserProfile(uid: uid)
            .flatMap { [eventService] profile -> AnyPublisher<([EventModel], Set<String>), Error> in
                eventService.fetchEvents()
                    .map { ($0, Set(profile.favoriteEventIds)) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] events, favoriteIds in
                    self?.events = events
                        .filter { favoriteIds.contains($0.id) }
                        .sorted { $0.startDate < $1.startDate }
                }
            )
            .store(in: &cancellables)
    }

    func removeFavorite(eventId: String) {
        guard let uid = authService.currentUserId else { return }
        events.removeAll { $0.id == eventId }
        favoriteCancellable = authService.toggleFavorite(uid: uid, eventId: eventId, isFavorite: false)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
