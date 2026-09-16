import Foundation
import Combine

final class OrganizerHomeViewModel {

    // MARK: - Выходные данные (что вычисляет ViewModel)
    @Published private(set) var events: [EventModel] = []
    @Published private(set) var state: ListState = .loading

    // MARK: - Внутреннее (сервисы и подписки)
    private let eventService = EventService()
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    func fetchMyEvents() {
        guard let uid = authService.currentUserId else { return }

        state = .loading
        eventService.fetchMyEvents(organizerId: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.state = .error(message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] events in
                    let sorted = events.sorted { $0.startDate < $1.startDate }
                    self?.events = sorted
                    self?.state = ListState.from(sorted, emptyMessage: L("organizer_empty"))
                }
            )
            .store(in: &cancellables)
    }
}
