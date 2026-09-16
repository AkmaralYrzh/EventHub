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
                        promise(.failure(EventError.notFound))
                        return
                    }
                    promise(.success(event))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Запись идёт через транзакцию: читаем актуальный список, проверяем лимит, пишем.
    /// Так два человека не займут последнее место одновременно. Отмена — просто arrayRemove.
    func setParticipation(eventId: String, uid: String, isJoined: Bool) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self else { return }
                let ref = self.db.collection("events").document(eventId)

                guard isJoined else {
                    ref.updateData(["participantIds": FieldValue.arrayRemove([uid])]) { error in
                        error.map { promise(.failure($0)) } ?? promise(.success(()))
                    }
                    return
                }

                self.db.runTransaction({ transaction, errorPointer in
                    do {
                        let snapshot = try transaction.getDocument(ref)
                        let ids = snapshot.data()?["participantIds"] as? [String] ?? []
                        let capacity = snapshot.data()?["capacity"] as? Int
                        if ids.contains(uid) { return nil }
                        if let capacity, ids.count >= capacity {
                            errorPointer?.pointee = EventError.full as NSError
                            return nil
                        }
                        transaction.updateData(["participantIds": FieldValue.arrayUnion([uid])], forDocument: ref)
                    } catch let error as NSError {
                        errorPointer?.pointee = error
                    }
                    return nil
                }) { _, error in
                    if let error {
                        promise(.failure(EventError.full.matches(error) ? EventError.full : error))
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
