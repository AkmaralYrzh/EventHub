struct UserProfile {
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    let role: UserRole
    let favoriteEventIds: [String]

    init(uid: String, firstName: String, lastName: String, email: String, role: UserRole, favoriteEventIds: [String] = []) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.role = role
        self.favoriteEventIds = favoriteEventIds
    }

    init?(from dict: [String: Any]) {
        guard
            let uid = dict["uid"] as? String,
            let firstName = dict["firstName"] as? String,
            let lastName = dict["lastName"] as? String,
            let email = dict["email"] as? String,
            let roleRaw = dict["role"] as? String,
            let role = UserRole(rawValue: roleRaw)
        else { return nil }

        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.role = role
        self.favoriteEventIds = dict["favoriteEventIds"] as? [String] ?? []
    }

    static func initials(from fullName: String) -> String {
        fullName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0).uppercased() }
            .joined()
    }

    var dictionary: [String: Any] {
        [
            "uid": uid,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "role": role.rawValue,
            "favoriteEventIds": favoriteEventIds
        ]
    }
}
