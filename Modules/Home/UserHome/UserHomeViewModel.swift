import Foundation
import Combine

final class UserHomeViewModel {

    static let allFilterId = "all"

    /// Результат последней загрузки — внутреннее, наружу уходит только `state`.
    private enum LoadResult: Equatable {
        case loading
        case loaded
        case failed(message: String)
    }

    // MARK: - Входные данные (что выбирает пользователь)
    @Published var selectedCategoryId: String = UserHomeViewModel.allFilterId
    @Published var selectedCityId: String = UserHomeViewModel.allFilterId

    // MARK: - Выходные данные (что вычисляет ViewModel)
    @Published private(set) var events: [EventModel] = []
    @Published private(set) var filteredEvents: [EventModel] = []
    @Published private(set) var favoriteEventIds: Set<String> = []
    @Published private(set) var state: ListState = .loading

    // MARK: - Внутреннее (сервисы и подписки)
    @Published private var loadResult: LoadResult = .loading
    private let eventService = EventService()
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()
    private var favoriteCancellable: AnyCancellable?

    init() {
        setupFiltering()
        setupState()
        fetchEvents()
        loadFavorites()
    }

    // MARK: - Фильтрация и состояние

    /// Фильтр пересчитывается сам при смене категории, города или данных.
    private func setupFiltering() {
        Publishers.CombineLatest3($events, $selectedCategoryId, $selectedCityId)
            .map { events, categoryId, cityId in
                Self.filter(events, categoryId: categoryId, cityId: cityId)
            }
            .assign(to: &$filteredEvents)
    }

    /// Состояние экрана зависит и от загрузки, и от фильтра:
    /// «событий нет вообще» и «по фильтру ничего нет» — разные сообщения.
    private func setupState() {
        Publishers.CombineLatest3($loadResult, $events, $filteredEvents)
            .map { result, events, filtered -> ListState in
                switch result {
                case .loading:                 return .loading
                case .failed(let message):     return .error(message: message)
                case .loaded:
                    if events.isEmpty || !events.contains(where: { $0.isUpcoming() }) {
                        return .empty(message: L("home_empty"))
                    }
                    if filtered.isEmpty { return .empty(message: L("home_empty_filtered")) }
                    return .loaded
                }
            }
            .removeDuplicates()
            .assign(to: &$state)
    }

    /// В ленте только предстоящие события; прошедшие остаются в профиле («Прошедшие»).
    static func filter(_ events: [EventModel], categoryId: String, cityId: String, now: Date = Date()) -> [EventModel] {
        events.filter { event in
            event.isUpcoming(now: now) &&
            (categoryId == allFilterId || event.category == categoryId) &&
            (cityId == allFilterId || event.city == cityId)
        }
    }

    // MARK: - Загрузка

    func fetchEvents() {
        loadResult = .loading
        eventService.fetchEvents()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.loadResult = .failed(message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] events in
                    self?.events = events.sorted { $0.startDate < $1.startDate }
                    self?.loadResult = .loaded
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

    // MARK: - Избранное (оптимистичное обновление)

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
