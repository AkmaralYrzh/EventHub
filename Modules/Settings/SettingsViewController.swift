import UIKit

final class SettingsViewController: UIViewController {

    private let settingsView = SettingsView()
    private let viewModel: SettingsViewModel

    var onLogout: (() -> Void)?
    var onProfileTap: (() -> Void)?

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
        settingsView.darkThemeSwitch.isOn = viewModel.isDarkThemeOn

        settingsView.profileHeaderControl.addAction(UIAction { [weak self] _ in
            self?.onProfileTap?()
        }, for: .touchUpInside)

        settingsView.darkThemeSwitch.addAction(UIAction { [weak self] _ in
            self?.darkThemeChanged()
        }, for: .valueChanged)

        settingsView.logoutButton.addAction(UIAction { [weak self] _ in
            self?.onLogout?()
        }, for: .touchUpInside)
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
        settingsView.accountSettingsLabel.text = L("settings_account_settings")
        settingsView.paymentLabel.text = L("settings_payment")
        settingsView.notificationsLabel.text = L("settings_notifications")
        settingsView.permissionsLabel.text = L("settings_permissions")
        settingsView.darkThemeLabel.text = L("settings_dark_theme")
        settingsView.supportLabel.text = L("settings_support")
        settingsView.rateAppLabel.text = L("settings_rate_app")
        settingsView.logoutButton.setTitle(L("settings_logout"), for: .normal)
    }

    private func darkThemeChanged() {
        let isOn = settingsView.darkThemeSwitch.isOn
        viewModel.setDarkTheme(isOn)
        view.window?.overrideUserInterfaceStyle = isOn ? .dark : .unspecified
    }
}
