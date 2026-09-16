import Foundation

struct EventModel {
    let id: String
    let title: String
    let description: String
    let startDate: Date
    let location: String
    let city: String
    let organizerId: String
    let organizerName: String
    let category: String
    let price: String
    let isFree: Bool
    let coverImageName: String

    init(id: String, title: String, description: String, startDate: Date, location: String, city: String,
         organizerId: String, organizerName: String, category: String, price: String,
         isFree: Bool, coverImageName: String) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.location = location
        self.city = city
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.category = category
        self.price = price
        self.isFree = isFree
        self.coverImageName = coverImageName
    }

    init?(id: String, from dict: [String: Any]) {
        guard
            let title = dict["title"] as? String,
            let description = dict["description"] as? String,
            let timestamp = dict["startDate"] as? TimeInterval,
            let location = dict["location"] as? String,
            let organizerId = dict["organizerId"] as? String,
            let organizerName = dict["organizerName"] as? String,
            let category = dict["category"] as? String,
            let price = dict["price"] as? String,
            let isFree = dict["isFree"] as? Bool,
            let coverImageName = dict["coverImageName"] as? String
        else { return nil }

        self.id = id
        self.title = title
        self.description = description
        self.startDate = Date(timeIntervalSince1970: timestamp)
        self.location = location
        self.city = dict["city"] as? String ?? "almaty"
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.category = category
        self.price = price
        self.isFree = isFree
        self.coverImageName = coverImageName
    }

    var dictionary: [String: Any] {
        [
            "title": title,
            "description": description,
            "startDate": startDate.timeIntervalSince1970,
            "location": location,
            "city": city,
            "organizerId": organizerId,
            "organizerName": organizerName,
            "category": category,
            "price": price,
            "isFree": isFree,
            "coverImageName": coverImageName
        ]
    }
}
