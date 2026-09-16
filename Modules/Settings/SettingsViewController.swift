import UIKit
import Combine
import StoreKit

final class SettingsViewController: UIViewController {

    private let settingsView = SettingsView()
    private let viewModel: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    var onLogout: (() -> Void)?
    var onProfileTap: (() -> Void)?
    var onEditProfileTap: (() -> Void)?
    var onLanguageChanged: (() -> Void)?
    var onAccountDeleted: (() -> Void)?

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = settingsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L("settings_title")
        updateTexts()
        setupActions()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let name = UserDefaults.standard.userName ?? ""
        settingsView.profileNameLabel.text = name
        settingsView.profileAvatarLabel.text = UserProfile.initials(from: name)
    }

    private func updateTexts() {
        settingsView.profileSubtitleLabel.text = L("settings_view_profile")
        settingsView.editProfileLabel.text = L("settings_edit_profile")
        settingsView.changePasswordLabel.text = L("settings_change_password")
        settingsView.deleteAccountLabel.text = L("settings_delete_account")
        settingsView.notificationsLabel.text = L("settings_notifications")
        settingsView.permissionsLabel.text = L("settings_permissions")
        settingsView.languageLabel.text = L("settings_language")
        settingsView.languageValueLabel.text = viewModel.currentLanguageTitle
        settingsView.darkThemeLabel.text = L("settings_dark_theme")
        settingsView.supportLabel.text = L("settings_support")
        settingsView.rateAppLabel.text = L("settings_rate_app")
        settingsView.logoutButton.setTitle(L("settings_logout"), for: .normal)
    }

    // MARK: - Действия по нажатию
    private func setupActions() {
        settingsView.profileHeaderControl.addAction(UIAction { [weak self] _ in
            self?.onProfileTap?()
        }, for: .touchUpInside)

        settingsView.editProfileRow.addAction(UIAction { [weak self] _ in
            self?.onEditProfileTap?()
        }, for: .touchUpInside)

        settingsView.changePasswordRow.addAction(UIAction { [weak self] _ in
            self?.changePasswordTapped()
        }, for: .touchUpInside)

        settingsView.deleteAccountRow.addAction(UIAction { [weak self] _ in
            self?.deleteAccountTapped()
        }, for: .touchUpInside)

        settingsView.notificationsSwitch.addAction(UIAction { [weak self] _ in
            self?.notificationsChanged()
        }, for: .valueChanged)

        settingsView.permissionsRow.addAction(UIAction { _ in
            Self.openSystemSettings()
        }, for: .touchUpInside)

        settingsView.languageRow.addAction(UIAction { [weak self] _ in
            self?.languageTapped()
        }, for: .touchUpInside)

        settingsView.darkThemeSwitch.addAction(UIAction { [weak self] _ in
            self?.darkThemeChanged()
        }, for: .valueChanged)

        settingsView.supportRow.addAction(UIAction { [weak self] _ in
            self?.supportTapped()
        }, for: .touchUpInside)

        settingsView.rateAppRow.addAction(UIAction { [weak self] _ in
            self?.rateAppTapped()
        }, for: .touchUpInside)

        settingsView.logoutButton.addAction(UIAction { [weak self] _ in
            self?.onLogout?()
        }, for: .touchUpInside)
    }

    // MARK: - Связывание View и ViewModel
    private func setupBindings() {
        viewModel.$isDarkThemeOn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.settingsView.darkThemeSwitch.isOn = $0 }
            .store(in: &cancellables)

        viewModel.$notificationsEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.settingsView.notificationsSwitch.setOn($0, animated: true) }
            .store(in: &cancellables)

        viewModel.$isBusy
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isBusy in
                self?.view.isUserInteractionEnabled = !isBusy
                self?.view.alpha = isBusy ? 0.6 : 1
            }
            .store(in: &cancellables)
    }

    // MARK: - Тема и язык

    private func darkThemeChanged() {
        let isOn = settingsView.darkThemeSwitch.isOn
        viewModel.setDarkTheme(isOn)
        view.window?.overrideUserInterfaceStyle = isOn ? .dark : .unspecified
    }

    private func languageTapped() {
        let sheet = UIAlertController(title: L("settings_language"), message: nil, preferredStyle: .actionSheet)
        SettingsViewModel.languages.forEach { language in
            let isCurrent = language.code == viewModel.currentLanguageCode
            let action = UIAlertAction(title: L(language.titleKey), style: .default) { [weak self] _ in
                guard !isCurrent else { return }
                self?.viewModel.setLanguage(language.code)
                self?.onLanguageChanged?()
            }
            if isCurrent { action.setValue(true, forKey: "checked") }
            sheet.addAction(action)
        }
        sheet.addAction(UIAlertAction(title: L("common_cancel"), style: .cancel))
        sheet.popoverPresentationController?.sourceView = settingsView.languageRow
        present(sheet, animated: true)
    }

    // MARK: - Уведомления и разрешения

    private func notificationsChanged() {
        let isOn = settingsView.notificationsSwitch.isOn
        viewModel.setNotifications(isOn)
            .sink { [weak self] granted in
                if isOn, !granted {
                    self?.showAlert(message: L("settings_notifications_denied"),
                                    extraAction: (L("common_open_settings"), { Self.openSystemSettings() }))
                }
            }
            .store(in: &cancellables)
    }

    private static func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Аккаунт

    private func changePasswordTapped() {
        let email = viewModel.userEmail ?? ""
        viewModel.sendPasswordReset()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.showAlert(message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] in
                    self?.showAlert(message: String(format: L("settings_change_password_sent"), email))
                }
            )
            .store(in: &cancellables)
    }

    private func deleteAccountTapped() {
        let alert = UIAlertController(title: L("settings_delete_account"),
                                      message: L("settings_delete_confirm"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L("common_cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L("settings_delete_account"), style: .destructive) { [weak self] _ in
            self?.deleteAccount()
        })
        present(alert, animated: true)
    }

    private func deleteAccount() {
        viewModel.deleteAccount()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.showAlert(message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] in self?.onAccountDeleted?() }
            )
            .store(in: &cancellables)
    }

    // MARK: - Ресурсы

    private func supportTapped() {
        let email = SettingsViewModel.supportEmail
        if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showAlert(message: String(format: L("settings_support_no_mail"), email))
        }
    }

    private func rateAppTapped() {
        guard let scene = view.window?.windowScene else { return }
        AppStore.requestReview(in: scene)
    }

    // MARK: - Вспомогательное

    private func showAlert(message: String, extraAction: (title: String, handler: () -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if let extraAction {
            alert.addAction(UIAlertAction(title: extraAction.title, style: .default) { _ in extraAction.handler() })
        }
        alert.addAction(UIAlertAction(title: L("common_ok"), style: .default))
        present(alert, animated: true)
    }
}
