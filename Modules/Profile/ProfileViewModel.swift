import Foundation
import Combine

enum ProfileEventsTab {
    case upcoming
    case past
}

class ProfileViewModel {

    // MARK: - Выходные данные (что вычисляет ViewModel)
    private(set) var userName: String = ""
    private(set) var userRole: UserRole?
    @Published private(set) var events: [EventModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published var selectedTab: ProfileEventsTab = .upcoming

    var visibleEvents: [EventModel] {
        let now = Date()
        switch selectedTab {
        case .upcoming: return events.filter { $0.startDate >= now }
        case .past:     return events.filter { $0.startDate < now }.reversed()
        }
    }

    // MARK: - Внутреннее (сервисы и подписки)
    private let authService = AuthService()
    private let eventService = EventService()
    private var cancellables = Set<AnyCancellable>()
    private var favoriteCancellable: AnyCancellable?

    init() {
        loadProfile()
        fetchEvents()
    }

    func loadProfile() {
        userName = UserDefaults.standard.userName ?? ""
        userRole = UserDefaults.standard.userRole
    }

    func fetchEvents() {
        guard let uid = authService.currentUserId else { return }
        isLoading = true

        if userRole == .organizer {
            eventService.fetchMyEvents(organizerId: uid)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] _ in self?.isLoading = false },
                    receiveValue: { [weak self] events in
                        self?.events = events.sorted { $0.startDate < $1.startDate }
                    }
                )
                .store(in: &cancellables)
        } else {
            authService.fetchUserProfile(uid: uid)
                .flatMap { [eventService] profile -> AnyPublisher<([EventModel], Set<String>), Error> in
                    eventService.fetchEvents()
                        .map { ($0, Set(profile.favoriteEventIds)) }
                        .eraseToAnyPublisher()
                }
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] _ in self?.isLoading = false },
                    receiveValue: { [weak self] events, favoriteIds in
                        self?.events = events
                            .filter { favoriteIds.contains($0.id) }
                            .sorted { $0.startDate < $1.startDate }
                    }
                )
                .store(in: &cancellables)
        }
    }

    func removeFavorite(eventId: String) {
        guard userRole != .organizer, let uid = authService.currentUserId else { return }
        events.removeAll { $0.id == eventId }
        favoriteCancellable = authService.toggleFavorite(uid: uid, eventId: eventId, isFavorite: false)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
