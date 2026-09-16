
import Foundation
import Combine

final class CreateEventViewModel {

    // MARK: - Входные данные (что вводит пользователь)
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var location: String = ""
    @Published var city: String = "almaty"
    @Published var category: String = "music"
    @Published var price: String = ""
    @Published var isFree: Bool = false
    @Published var startDate: Date = CreateEventViewModel.defaultStartDate()
    @Published var coverImageName: String = EventCovers.templates[0].id

    // MARK: - Выходные данные (что вычисляет ViewModel)
    @Published private(set) var isReadyToCreate: Bool = false
    @Published private(set) var isDateValid: Bool = true
    @Published private(set) var errorMessage: String?

    // MARK: - Внутреннее (сервисы и подписки)
    private let eventService = EventService()
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscription()
    }

    private func setupSubscription() {
        $startDate
            .map { Self.isValidStartDate($0) }
            .removeDuplicates()
            .assign(to: &$isDateValid)

        Publishers.CombineLatest4($title, $description, $location, $isDateValid)
            .map { title, description, location, isDateValid in
                !title.isEmpty && !description.isEmpty && !location.isEmpty && isDateValid
            }
            .removeDuplicates()
            .assign(to: &$isReadyToCreate)
    }

    // MARK: - Дата

    /// По умолчанию — через час, чтобы форма сразу была валидной.
    static func defaultStartDate(now: Date = Date()) -> Date {
        now.addingTimeInterval(60 * 60)
    }

    /// Мероприятие можно создать только на будущее время.
    static func isValidStartDate(_ date: Date, now: Date = Date()) -> Bool {
        date > now
    }

    func createEvent() -> AnyPublisher<Void, Error> {
        guard let uid = authService.currentUserId else {
            return Fail(error: NSError(domain: "CreateEvent", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден"]))
                .eraseToAnyPublisher()
        }

        guard Self.isValidStartDate(startDate) else {
            return Fail(error: NSError(domain: "CreateEvent", code: 1,
                                        userInfo: [NSLocalizedDescriptionKey: L("createevent_error_past_date")]))
                .eraseToAnyPublisher()
        }

        let organizerName = UserDefaults.standard.userName ?? ""

        let event = EventModel(
            id: "",
            title: title,
            description: description,
            startDate: startDate,
            location: location,
            city: city,
            organizerId: uid,
            organizerName: organizerName,
            category: category,
            price: price,
            isFree: isFree,
            coverImageName: coverImageName
        )

        return eventService.createEvent(event)
    }
}
