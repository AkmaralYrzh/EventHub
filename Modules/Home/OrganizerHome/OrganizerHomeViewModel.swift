import Foundation
import Combine

class OrganizerHomeViewModel {

    // MARK: - Выходные данные (что вычисляет ViewModel)
    @Published private(set) var events: [EventModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Внутреннее (сервисы и подписки)
    private let eventService = EventService()
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    func fetchMyEvents() {
        guard let uid = authService.currentUserId else { return }

        errorMessage = nil
        isLoading = true
        eventService.fetchMyEvents(organizerId: uid)
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
}
