import Foundation
import Combine
import FirebaseFirestore

final class EventService {

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

    // MARK: - Участие в мероприятии

    /// Актуальная версия одного события — чтобы на экране деталей был свежий список участников.
    func fetchEvent(id: String) -> AnyPublisher<EventModel, Error> {
        Deferred {
            Future { [weak self] promise in
                self?.db.collection("events").document(id).getDocument { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let data = snapshot?.data(), let event = EventModel(id: id, from: data) else {
                        promise(.failure(AuthError.unknown))
                        return
                    }
                    promise(.success(event))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// arrayUnion / arrayRemove — атомарно, как и для избранного.
    func setParticipation(eventId: String, uid: String, isJoined: Bool) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                let update: [String: Any] = [
                    "participantIds": isJoined
                        ? FieldValue.arrayUnion([uid])
                        : FieldValue.arrayRemove([uid])
                ]
                self?.db.collection("events").document(eventId).updateData(update) { error in
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

    /// Мероприятия, на которые записан пользователь — фильтр на сервере через arrayContains.
    func fetchJoinedEvents(uid: String) -> AnyPublisher<[EventModel], Error> {
        Deferred {
            Future { [weak self] promise in
                self?.db.collection("events")
                    .whereField("participantIds", arrayContains: uid)
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
}
