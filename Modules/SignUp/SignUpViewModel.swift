import Foundation
import Combine

class SignUpViewModel {
    
    @Published var firstName:String = ""
    @Published var lastName:String = ""
    @Published var email:String = ""
    @Published var password:String = ""
    @Published var confirmPassword:String = ""
    @Published var role:UserRole = .user
    
    @Published  private(set) var isReadyToSignUp:Bool = false
    
    private  let authService = AuthService ()
    private var cancellables = Set <AnyCancellable> ()
    
    init () {
        setupSubscription()
    }
    private func setupSubscription () {
        Publishers.CombineLatest4($firstName, $lastName, $email, $password)
            .combineLatest($confirmPassword)
            .map {first, second in
                let (firstName, lastName, email, password ) = first
                let confirmPassword = second
                return  !firstName.isEmpty
                && !lastName.isEmpty
                && email.contains ("@")
                && password.count >= 6
                && password == confirmPassword
                
            }
            .removeDuplicates()
            .assign(to: &$isReadyToSignUp)
    }
    func signUp () -> AnyPublisher <AuthUser, Error> {
        let profile = UserProfile (
            uid:"",
            firstName:firstName,
            lastName:lastName,
            email:email,
            role:role
        )
        return authService.signUp(profile:profile, password:password)
    }
}
