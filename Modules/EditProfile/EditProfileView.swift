import UIKit

final class EditProfileView: UIView {

    let avatarLabel = UILabel()
    let firstNameField = UITextField()
    let lastNameField = UITextField()
    let saveButton = UIButton(type: .system)
    let errorLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .eventHubBackground
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSaving(_ isSaving: Bool) {
        isSaving ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        saveButton.isEnabled = !isSaving
        saveButton.alpha = isSaving ? 0.5 : 1
    }

    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = 14
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        avatarLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        avatarLabel.textColor = .eventHubTextPrimary
        avatarLabel.textAlignment = .center
        avatarLabel.backgroundColor = .eventHubGlassFill
        avatarLabel.layer.cornerRadius = 40
        avatarLabel.layer.masksToBounds = true
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false

        let avatarRow = UIView()
        avatarRow.addSubview(avatarLabel)

        [firstNameField, lastNameField].forEach { field in
            field.borderStyle = .roundedRect
            field.backgroundColor = .eventHubGlassFill
            field.textColor = .eventHubTextPrimary
            field.autocapitalizationType = .words
            field.returnKeyType = .done
            field.translatesAutoresizingMaskIntoConstraints = false
            field.heightAnchor.constraint(equalToConstant: 46).isActive = true
        }
        firstNameField.placeholder = L("signup_firstname_placeholder")
        lastNameField.placeholder = L("signup_lastname_placeholder")

        saveButton.setTitle(L("editprofile_save"), for: .normal)
        saveButton.setTitleColor(.eventHubOnAccent, for: .normal)
        saveButton.backgroundColor = .eventHubAccent
        saveButton.layer.cornerRadius = 14
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 52).isActive = true

        errorLabel.textColor = .eventHubError
        errorLabel.font = .systemFont(ofSize: 13)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true

        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .eventHubSecondary

        [avatarRow, firstNameField, lastNameField, errorLabel, saveButton, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview($0)
        }
        contentStackView.setCustomSpacing(24, after: avatarRow)

        NSLayoutConstraint.activate([
            avatarLabel.widthAnchor.constraint(equalToConstant: 80),
            avatarLabel.heightAnchor.constraint(equalToConstant: 80),
            avatarLabel.centerXAnchor.constraint(equalTo: avatarRow.centerXAnchor),
            avatarLabel.topAnchor.constraint(equalTo: avatarRow.topAnchor),
            avatarLabel.bottomAnchor.constraint(equalTo: avatarRow.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48)
        ])
    }
}
