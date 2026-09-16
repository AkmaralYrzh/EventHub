import Foundation
import Combine

enum ProfileEventsTab {
    case upcoming
    case past
}

final class ProfileViewModel {

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
            // Посетитель видит в профиле мероприятия, на которые записался (избранное — на своей вкладке).
            eventService.fetchJoinedEvents(uid: uid)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] _ in self?.isLoading = false },
                    receiveValue: { [weak self] events in
                        self?.events = events.sorted { $0.startDate < $1.startDate }
                    }
                )
                .store(in: &cancellables)
        }
    }
}
