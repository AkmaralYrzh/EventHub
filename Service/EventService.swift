import Foundation
import Combine
import FirebaseFirestore

class EventService {

    private let db = Firestore.firestore()

    func fetchEvents() -> AnyPublisher<[EventModel], Error> {
        Deferred {
            Future { [weak self] promise in
                self?.db.collection("events").getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    let events = snapshot?.documents.compactMap { doc in
                        EventModel(id: doc.documentID, from: doc.data())
                    } ?? []
                    promise(.success(events))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchMyEvents(organizerId: String) -> AnyPublisher<[EventModel], Error> {
        Deferred {
            Future { [weak self] promise in
                self?.db.collection("events")
                    .whereField("organizerId", isEqualTo: organizerId)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            promise(.failure(error))
                            return
                        }
                        let events = snapshot?.documents.compactMap { doc in
                            EventModel(id: doc.documentID, from: doc.data())
                        } ?? []
                        promise(.success(events))
                    }
            }
        }
        .eraseToAnyPublisher()
    }

    func createEvent(_ event: EventModel) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                self?.db.collection("events").addDocument(data: event.dictionary) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
