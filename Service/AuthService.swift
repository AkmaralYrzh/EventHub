//
//  AuthService.swift
//  EventHub
//
//  Created by MacBook Air  on 10.07.2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class AuthService {

    private let db = Firestore.firestore()

    // MARK: - Перевод ошибок Firebase в AuthError

    /// Единственное место, где приложение разбирает коды Firebase Auth.
    static func mapError(_ error: Error) -> AuthError {
        if let authError = error as? AuthError { return authError }
        guard let code = AuthErrorCode(rawValue: (error as NSError).code) else { return .unknown }
        switch code {
        case .invalidEmail:                       return .invalidEmail
        case .wrongPassword, .invalidCredential:  return .wrongPassword
        case .userNotFound:                       return .userNotFound
        case .emailAlreadyInUse:                  return .emailAlreadyInUse
        case .weakPassword:                       return .weakPassword
        case .userDisabled:                       return .userDisabled
        case .tooManyRequests:                    return .tooManyRequests
        case .networkError:                       return .network
        default:                                  return .unknown
        }
    }

    var currentUser: AuthUser? {
        Auth.auth().currentUser
    }

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    var authStateDidChangePublisher: AnyPublisher<AuthUser?, Never> {
        let subject = PassthroughSubject<AuthUser?, Never>()

        let handle = Auth.auth().addStateDidChangeListener { _, user in
            subject.send(user)
        }

        return subject
            .handleEvents(receiveCancel: {
                Auth.auth().removeStateDidChangeListener(handle)
            })
            .eraseToAnyPublisher()
    }

    func signIn(email: String, password: String) -> AnyPublisher<AuthUser, Error> {
        Deferred {
            Future { promise in
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        promise(.failure(AuthService.mapError(error)))
                    } else if let user = result?.user {
                        promise(.success(user as AuthUser))
                    } else {
                        promise(.failure(AuthError.unknown))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func signUp(profile: UserProfile, password: String) -> AnyPublisher<AuthUser, Error> {
        Deferred {
            Future { [weak self] promise in
                Auth.auth().createUser(withEmail: profile.email, password: password) { result, error in
                    if let error = error {
                        promise(.failure(AuthService.mapError(error)))
                        return
                    }
                    guard let firebaseUser = result?.user else {
                        promise(.failure(AuthError.unknown))
                        return
                    }

                    let newProfile = UserProfile(
                        uid: firebaseUser.uid,
                        firstName: profile.firstName,
                        lastName: profile.lastName,
                        email: profile.email,
                        role: profile.role
                    )

                    self?.db.collection("users").document(firebaseUser.uid).setData(newProfile.dictionary) { error in
                        if let error = error {
                            promise(.failure(AuthService.mapError(error)))
                        } else {
                            promise(.success(firebaseUser as AuthUser))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchUserProfile(uid: String) -> AnyPublisher<UserProfile, Error> {
        Deferred {
            Future { [weak self] promise in
                self?.db.collection("users").document(uid).getDocument { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let data = snapshot?.data(),
                          let profile = UserProfile(from: data) else {
                        promise(.failure(AuthError.profileNotFound))
                        return
                    }
                    promise(.success(profile))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchAndCacheProfile(uid: String) -> AnyPublisher<UserProfile, Error> {
        fetchUserProfile(uid: uid)
            .handleEvents(receiveOutput: { profile in
                UserDefaults.standard.userRole = profile.role
                UserDefaults.standard.userName = "\(profile.firstName) \(profile.lastName)"
            })
            .eraseToAnyPublisher()
    }

    func toggleFavorite(uid: String, eventId: String, isFavorite: Bool) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                let update: [String: Any] = [
                    "favoriteEventIds": isFavorite
                        ? FieldValue.arrayUnion([eventId])
                        : FieldValue.arrayRemove([eventId])
                ]
                self?.db.collection("users").document(uid).updateData(update) { error in
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

    func logout() throws {
        try Auth.auth().signOut()
    }
}
