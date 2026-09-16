import Foundation
import Combine

final class EventDetailsViewModel {

    // MARK: - Выходные данные (что вычисляет ViewModel)
    @Published private(set) var event: EventModel
    @Published private(set) var isJoined: Bool = false
    @Published private(set) var isBusy: Bool = false
    @Published private(set) var errorMessage: String?

    /// Записываться могут только посетители, только на будущие события и не на свои.
    var canJoin: Bool {
        guard let uid = authService.currentUserId else { return false }
        return UserDefaults.standard.userRole == .user
            && event.isUpcoming()
            && event.organizerId != uid
    }

    // MARK: - Внутреннее (сервисы и подписки)
    private let eventService = EventService()
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    init(event: EventModel) {
        self.event = event
        self.isJoined = event.isJoined(by: authService.currentUserId)
        refresh()
    }

    /// Событие приходит из списка уже готовым; здесь только обновляем список участников.
    func refresh() {
        eventService.fetchEvent(id: event.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] fresh in
                    guard let self else { return }
                    self.event = fresh
                    self.isJoined = fresh.isJoined(by: self.authService.currentUserId)
                }
            )
            .store(in: &cancellables)
    }

    /// Оптимистичное обновление: кнопка и счётчик меняются сразу, при ошибке откатываются.
    func toggleJoin() {
        guard canJoin, !isBusy, let uid = authService.currentUserId else { return }
        let newValue = !isJoined
        let previous = event

        isJoined = newValue
        event = event.withParticipation(uid: uid, isJoined: newValue)
        isBusy = true
        errorMessage = nil

        eventService.setParticipation(eventId: event.id, uid: uid, isJoined: newValue)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isBusy = false
                    if case .failure(let error) = completion {
                        self?.event = previous
                        self?.isJoined = !newValue
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
