import Foundation
import Combine

final class FavoritesViewModel {

    @Published private(set) var events: [EventModel] = []
    @Published private(set) var state: ListState = .loading

    private let eventService = EventService()
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()
    private var favoriteCancellable: AnyCancellable?

    init() {
        refresh()
    }

    func refresh() {
        guard let uid = authService.currentUserId else { return }
        state = .loading

        authService.fetchUserProfile(uid: uid)
            .flatMap { [eventService] profile -> AnyPublisher<([EventModel], Set<String>), Error> in
                eventService.fetchEvents()
                    .map { ($0, Set(profile.favoriteEventIds)) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.state = .error(message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] events, favoriteIds in
                    let favorites = events
                        .filter { favoriteIds.contains($0.id) }
                        .sorted { $0.startDate < $1.startDate }
                    self?.events = favorites
                    self?.state = ListState.from(favorites, emptyMessage: L("favorites_empty"))
                }
            )
            .store(in: &cancellables)
    }

    func removeFavorite(eventId: String) {
        guard let uid = authService.currentUserId else { return }
        events.removeAll { $0.id == eventId }
        state = ListState.from(events, emptyMessage: L("favorites_empty"))
        favoriteCancellable = authService.toggleFavorite(uid: uid, eventId: eventId, isFavorite: false)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
