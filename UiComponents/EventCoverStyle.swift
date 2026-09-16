import UIKit

struct EventCoverTemplate {
    let id: String
    let label: String
    let colors: [UIColor]
}

enum EventCovers {

    private static let gradientStyles: [[UIColor]] = [
        [UIColor(red: 0.85, green: 0.77, blue: 0.63, alpha: 1), UIColor(red: 0.23, green: 0.16, blue: 0.09, alpha: 1)],
        [UIColor(red: 0.95, green: 0.65, blue: 0.35, alpha: 1), UIColor(red: 0.76, green: 0.34, blue: 0.23, alpha: 1)],
        [UIColor(red: 0.88, green: 0.48, blue: 0.37, alpha: 1), UIColor(red: 0.51, green: 0.35, blue: 0.56, alpha: 1)],
        [UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1), UIColor(red: 0.75, green: 0.51, blue: 0.53, alpha: 1)],
        [UIColor(red: 1.00, green: 0.84, blue: 0.65, alpha: 1), UIColor(red: 0.98, green: 0.55, blue: 0.14, alpha: 1)]
    ]

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
