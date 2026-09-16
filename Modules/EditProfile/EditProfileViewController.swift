import UIKit
import Combine

final class EditProfileViewController: UIViewController {

    private let editView = EditProfileView()
    private let viewModel: EditProfileViewModel
    private var cancellables = Set<AnyCancellable>()

    var onSaved: (() -> Void)?

    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = editView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L("editprofile_title")
        hideKeyboardWhenTappedAround()
        setupBindings()
        editView.saveButton.addAction(UIAction { [weak self] _ in self?.saveTapped() }, for: .touchUpInside)
    }

    // MARK: - Связывание View и ViewModel
    private func setupBindings() {
        // ViewModel → поля (первичное заполнение и данные из Firestore)
        viewModel.$firstName
            .receive(on: DispatchQueue.main)
            .filter { [weak self] in $0 != self?.editView.firstNameField.text }
            .sink { [weak self] in self?.editView.firstNameField.text = $0 }
            .store(in: &cancellables)

        viewModel.$lastName
            .receive(on: DispatchQueue.main)
            .filter { [weak self] in $0 != self?.editView.lastNameField.text }
            .sink { [weak self] in self?.editView.lastNameField.text = $0 }
            .store(in: &cancellables)

        // Поля → ViewModel
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: editView.firstNameField)
            .compactMap { ($0.object as? UITextField)?.text }
            .assign(to: \.firstName, on: viewModel)
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: editView.lastNameField)
            .compactMap { ($0.object as? UITextField)?.text }
            .assign(to: \.lastName, on: viewModel)
            .store(in: &cancellables)

        // Инициалы в аватаре обновляются по мере ввода
        viewModel.$firstName.combineLatest(viewModel.$lastName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] first, last in
                self?.editView.avatarLabel.text = UserProfile.initials(from: "\(first) \(last)")
            }
            .store(in: &cancellables)

        viewModel.$isReadyToSave
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReady in
                self?.editView.saveButton.isEnabled = isReady
                self?.editView.saveButton.alpha = isReady ? 1 : 0.5
            }
            .store(in: &cancellables)

        viewModel.$isSaving
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.editView.setSaving($0) }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.editView.errorLabel.text = message
                self?.editView.errorLabel.isHidden = (message == nil)
            }
            .store(in: &cancellables)
    }

    private func saveTapped() {
        view.endEditing(true)
        viewModel.save()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.onSaved?() }
            )
            .store(in: &cancellables)
    }
}
