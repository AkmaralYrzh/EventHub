
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
    /// Текст поля «Количество мест»; пусто — без ограничения.
    @Published var capacityText: String = ""

    // MARK: - Выходные данные (что вычисляет ViewModel)
    @Published private(set) var isReadyToCreate: Bool = false
    @Published private(set) var isDateValid: Bool = true
    @Published private(set) var isCapacityValid: Bool = true
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

        $capacityText
            .map { Self.parseCapacity($0) != nil }
            .removeDuplicates()
            .assign(to: &$isCapacityValid)

        Publishers.CombineLatest4($title, $description, $location, $isDateValid)
            .combineLatest($isCapacityValid)
            .map { fields, isCapacityValid in
                let (title, description, location, isDateValid) = fields
                return !title.isEmpty && !description.isEmpty && !location.isEmpty && isDateValid && isCapacityValid
            }
            .removeDuplicates()
            .assign(to: &$isReadyToCreate)
    }

    // MARK: - Количество мест

    /// Пустая строка → .some(nil) (без лимита); положительное число → .some(n); иначе nil (ошибка ввода).
    static func parseCapacity(_ text: String) -> Int?? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return .some(nil) }
        guard let value = Int(trimmed), value > 0 else { return nil }
        return .some(value)
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
            coverImageName: coverImageName,
            capacity: Self.parseCapacity(capacityText) ?? nil
        )

        return eventService.createEvent(event)
    }
}
