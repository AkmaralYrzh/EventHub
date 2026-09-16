import UIKit

struct EventCoverTemplate {
    let id: String
    let label: String
    let colors: [UIColor]
}

enum EventCovers {

    static let gradientStyles: [[UIColor]] = UIColor.eventHubCoverGradients

    static let templates: [EventCoverTemplate] = [
        EventCoverTemplate(id: "c1", label: "Неон", colors: gradientStyles[3]),
        EventCoverTemplate(id: "c2", label: "Диджей-сет", colors: gradientStyles[1]),
        EventCoverTemplate(id: "c3", label: "Хакатон", colors: gradientStyles[0]),
        EventCoverTemplate(id: "c4", label: "Стартап", colors: gradientStyles[2]),
        EventCoverTemplate(id: "c5", label: "Крипто-саммит", colors: gradientStyles[4]),
        EventCoverTemplate(id: "c6", label: "Матч", colors: gradientStyles[3]),
        EventCoverTemplate(id: "c7", label: "Марафон", colors: gradientStyles[0]),
        EventCoverTemplate(id: "c8", label: "Градиент", colors: gradientStyles[2]),
        EventCoverTemplate(id: "c9", label: "Волны", colors: gradientStyles[4]),
        EventCoverTemplate(id: "c10", label: "Конференция", colors: gradientStyles[1])
    ]

    static func colors(for id: String) -> [UIColor] {
        templates.first(where: { $0.id == id })?.colors ?? gradientStyles[0]
    }
}
