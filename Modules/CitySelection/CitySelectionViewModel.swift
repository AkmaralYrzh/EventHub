import Foundation
import Combine

class CitySelectionViewModel {

    struct CityItem {
        let id: String
        let icon: String
        let name: String
        let count: Int
    }

    @Published private(set) var cities: [CityItem] = []

    private let eventService = EventService()
    private var cancellables = Set<AnyCancellable>()

    private let cityDefinitions: [(id: String, icon: String, nameKey: String)] = [
        ("almaty", "", "city_almaty"),
        ("astana", "", "city_astana"),
        ("shymkent", "", "city_shymkent"),
        ("aktobe", "", "city_aktobe")
    ]

    init() {
        loadCounts()
    }

    private func loadCounts() {
        eventService.fetchEvents()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] events in
                    guard let self else { return }
                    self.cities = self.cityDefinitions.map { def in
                        let count = events.filter { $0.city == def.id }.count
                        return CityItem(id: def.id, icon: def.icon, name: L(def.nameKey), count: count)
                    }
                }
            )
            .store(in: &cancellables)
    }
}
