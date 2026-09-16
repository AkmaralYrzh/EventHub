import UIKit
final class SignUpView:UIView {
    
    let firstNameField = UITextField()
    let lastNameField = UITextField()
    let emailField = UITextField()
    let passwordField = UITextField()
    let confirmPasswordField = UITextField()
    let roleControl = UISegmentedControl()
    let errorLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize:13)
        label.textColor = .eventHubError
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
        
    }()
    
    let signUpButton = UIButton(type:.system)
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .eventHubBackground
        setupFields()
        setupLayout()
        
    }
    required init?(coder:NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupFields () {
        firstNameField.placeholder = L("signup_firstname_placeholder")
        firstNameField.borderStyle = .roundedRect
        
        lastNameField.placeholder = L("signup_lastname_placeholder")
        lastNameField.borderStyle = .roundedRect
        
        emailField.placeholder = L("signup_email_placeholder")
        emailField.borderStyle = .roundedRect
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        
        passwordField.placeholder = L("signup_password_placeholder")
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .newPassword

        confirmPasswordField.placeholder = L("signup_confirm_password_placeholder")
        confirmPasswordField.borderStyle = .roundedRect
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.textContentType = .newPassword
        
        roleControl.insertSegment(withTitle: L("signup_role_user"), at: 0, animated: false)
        roleControl.insertSegment(withTitle: L("signup_role_organizer"), at: 1, animated: false)
        roleControl.selectedSegmentIndex = 0
        
        signUpButton.setTitle(L("signup_button"), for:.normal)
        signUpButton.backgroundColor = .eventHubAccent
        signUpButton.setTitleColor(.eventHubOnAccent, for:.normal)
        signUpButton.layer.cornerRadius = 12
        signUpButton.isEnabled = false
    }
    
    private func setupLayout () {
        let stack = UIStackView(arrangedSubviews: [firstNameField, lastNameField, emailField, passwordField, confirmPasswordField, roleControl,errorLabel, signUpButton
                                                  ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate ([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor,constant:20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -20),
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,constant:40),
            signUpButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
