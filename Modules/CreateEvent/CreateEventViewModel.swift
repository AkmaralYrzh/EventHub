
import Foundation
import Combine

class CreateEventViewModel {

    // MARK: - Входные данные (что вводит пользователь)
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var location: String = ""
    @Published var city: String = "almaty"
    @Published var category: String = "music"
    @Published var price: String = ""
    @Published var isFree: Bool = false
    @Published var startDate: Date = Date()
    @Published var coverImageName: String = EventCovers.templates[0].id

    // MARK: - Выходные данные (что вычисляет ViewModel)
    @Published private(set) var isReadyToCreate: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Внутреннее (сервисы и подписки)
    private let eventService = EventService()
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscription()
    }

    private func setupSubscription() {
        Publishers.CombineLatest3($title, $description, $location)
            .map { title, description, location in
                !title.isEmpty && !description.isEmpty && !location.isEmpty
            }
            .removeDuplicates()
            .assign(to: &$isReadyToCreate)
    }

    func createEvent() -> AnyPublisher<Void, Error> {
        guard let uid = authService.currentUserId else {
            return Fail(error: NSError(domain: "CreateEvent", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден"]))
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
