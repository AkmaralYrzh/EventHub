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
        case .requiresRecentLogin:                return .requiresRecentLogin
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

    // MARK: - Профиль и аккаунт

    /// Обновляет имя и фамилию в Firestore и в локальном кэше.
    func updateName(uid: String, firstName: String, lastName: String) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                let update: [String: Any] = ["firstName": firstName, "lastName": lastName]
                self?.db.collection("users").document(uid).updateData(update) { error in
                    if let error = error {
                        promise(.failure(AuthService.mapError(error)))
                    } else {
                        UserDefaults.standard.userName = "\(firstName) \(lastName)"
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Firebase присылает письмо со ссылкой на смену пароля.
    func sendPasswordReset(email: String) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { promise in
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        promise(.failure(AuthService.mapError(error)))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Удаляет документ профиля, затем сам аккаунт Firebase Auth.
    /// Firebase может потребовать недавний вход (requiresRecentLogin) — тогда вернётся ошибка.
    func deleteAccount() -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let user = Auth.auth().currentUser else {
                    promise(.failure(AuthError.userNotFound))
                    return
                }
                self?.db.collection("users").document(user.uid).delete { error in
                    if let error = error {
                        promise(.failure(AuthService.mapError(error)))
                        return
                    }
                    user.delete { error in
                        if let error = error {
                            promise(.failure(AuthService.mapError(error)))
                        } else {
                            promise(.success(()))
                        }
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
