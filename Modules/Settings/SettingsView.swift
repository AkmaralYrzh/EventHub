import UIKit

final class SettingsView: UIView {

    let profileHeaderControl = UIControl()
    let profileAvatarLabel = UILabel()
    let profileNameLabel = UILabel()
    let profileSubtitleLabel = UILabel()

    let editProfileRow = UIControl()
    let editProfileLabel = UILabel()

    let changePasswordRow = UIControl()
    let changePasswordLabel = UILabel()
    let deleteAccountRow = UIControl()
    let deleteAccountLabel = UILabel()

    let notificationsLabel = UILabel()
    let notificationsSwitch = UISwitch()
    let permissionsRow = UIControl()
    let permissionsLabel = UILabel()
    let languageRow = UIControl()
    let languageLabel = UILabel()
    let languageValueLabel = UILabel()
    let darkThemeLabel = UILabel()
    let darkThemeSwitch = UISwitch()

    let supportRow = UIControl()
    let supportLabel = UILabel()
    let rateAppRow = UIControl()
    let rateAppLabel = UILabel()

    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.eventHubError, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.contentHorizontalAlignment = .center
        return button
    }()

    let accountSectionLabel = UILabel()
    let settingsSectionLabel = UILabel()
    let resourcesSectionLabel = UILabel()

    private var borderedViews: [UIView] = []

    private let scrollView = UIScrollView()
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .eventHubBackground
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func styleSectionLabel(_ label: UILabel) {
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .eventHubSecondary
    }

    private func styleRowLabel(_ label: UILabel) {
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
    }

    private func makeChevron() -> UIImageView {
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .eventHubSecondary
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.widthAnchor.constraint(equalToConstant: 12).isActive = true
        return chevron
    }

    private func fillRow(_ row: UIView, label: UILabel, accessory: UIView) {
        styleRowLabel(label)

        [label, accessory].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview($0)
        }

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 50),

            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            accessory.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            accessory.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            accessory.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 8)
        ])
    }

    /// Строка «подпись + переключатель» — без UIControl, чтобы тап не перехватывал свитч.
    private func makeSwitchRow(label: UILabel, toggle: UISwitch) -> UIView {
        styleRowLabel(label)
        let row = UIView()
        [label, toggle].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview($0)
        }
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 50),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .eventHubGlassBorder
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    private func makeCard(rows: [UIView]) -> UIView {
        let card = UIView()
        card.backgroundColor = .eventHubGlassFill
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.eventHubGlassBorder.cgColor
        borderedViews.append(card)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false

        rows.enumerated().forEach { index, row in
            stack.addArrangedSubview(row)
            if index < rows.count - 1 {
                stack.addArrangedSubview(makeDivider())
            }
        }

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        return card
    }

    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        profileAvatarLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        profileAvatarLabel.textColor = .eventHubTextPrimary
        profileAvatarLabel.textAlignment = .center
        profileAvatarLabel.backgroundColor = .eventHubGlassFill
        profileAvatarLabel.layer.cornerRadius = 24
        profileAvatarLabel.layer.masksToBounds = true
        profileAvatarLabel.translatesAutoresizingMaskIntoConstraints = false
        profileAvatarLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileAvatarLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true

        profileNameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        profileNameLabel.textColor = .label

        profileSubtitleLabel.font = .systemFont(ofSize: 12)
        profileSubtitleLabel.textColor = .eventHubSecondary
        profileSubtitleLabel.text = L("settings_view_profile")

        let nameStack = UIStackView(arrangedSubviews: [profileNameLabel, profileSubtitleLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2
        nameStack.translatesAutoresizingMaskIntoConstraints = false

        let profileChevron = makeChevron()

        profileHeaderControl.backgroundColor = .eventHubGlassFill
        profileHeaderControl.layer.cornerRadius = 16
        profileHeaderControl.layer.borderWidth = 1
        profileHeaderControl.layer.borderColor = UIColor.eventHubGlassBorder.cgColor
        borderedViews.append(profileHeaderControl)
        profileHeaderControl.translatesAutoresizingMaskIntoConstraints = false
        [profileAvatarLabel, nameStack, profileChevron].forEach { profileHeaderControl.addSubview($0) }

        NSLayoutConstraint.activate([
            profileHeaderControl.heightAnchor.constraint(equalToConstant: 72),
            profileAvatarLabel.leadingAnchor.constraint(equalTo: profileHeaderControl.leadingAnchor, constant: 14),
            profileAvatarLabel.centerYAnchor.constraint(equalTo: profileHeaderControl.centerYAnchor),

            nameStack.leadingAnchor.constraint(equalTo: profileAvatarLabel.trailingAnchor, constant: 12),
            nameStack.centerYAnchor.constraint(equalTo: profileHeaderControl.centerYAnchor),

            profileChevron.trailingAnchor.constraint(equalTo: profileHeaderControl.trailingAnchor, constant: -16),
            profileChevron.centerYAnchor.constraint(equalTo: profileHeaderControl.centerYAnchor),
            profileChevron.leadingAnchor.constraint(greaterThanOrEqualTo: nameStack.trailingAnchor, constant: 8)
        ])

        fillRow(editProfileRow, label: editProfileLabel, accessory: makeChevron())
        let editProfileCard = makeCard(rows: [editProfileRow])

        styleSectionLabel(accountSectionLabel)
        accountSectionLabel.text = L("settings_section_account")
        fillRow(changePasswordRow, label: changePasswordLabel, accessory: makeChevron())
        fillRow(deleteAccountRow, label: deleteAccountLabel, accessory: makeChevron())
        deleteAccountLabel.textColor = .eventHubError
        let accountCard = makeCard(rows: [changePasswordRow, deleteAccountRow])

        styleSectionLabel(settingsSectionLabel)
        settingsSectionLabel.text = L("settings_section_settings")
        let notificationsRow = makeSwitchRow(label: notificationsLabel, toggle: notificationsSwitch)
        fillRow(permissionsRow, label: permissionsLabel, accessory: makeChevron())

        // Язык: справа — текущее значение и шеврон
        languageValueLabel.font = .systemFont(ofSize: 15)
        languageValueLabel.textColor = .eventHubSecondary
        let languageAccessory = UIStackView(arrangedSubviews: [languageValueLabel, makeChevron()])
        languageAccessory.axis = .horizontal
        languageAccessory.spacing = 8
        languageAccessory.alignment = .center
        fillRow(languageRow, label: languageLabel, accessory: languageAccessory)

        let themeRow = makeSwitchRow(label: darkThemeLabel, toggle: darkThemeSwitch)

        let settingsCard = makeCard(rows: [notificationsRow, permissionsRow, languageRow, themeRow])

        styleSectionLabel(resourcesSectionLabel)
        resourcesSectionLabel.text = L("settings_section_resources")
        fillRow(supportRow, label: supportLabel, accessory: makeChevron())
        fillRow(rateAppRow, label: rateAppLabel, accessory: makeChevron())
        let resourcesCard = makeCard(rows: [supportRow, rateAppRow])

        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        let logoutRow = UIView()
        logoutRow.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutRow.heightAnchor.constraint(equalToConstant: 50),
            logoutButton.centerXAnchor.constraint(equalTo: logoutRow.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: logoutRow.centerYAnchor)
        ])
        let logoutCard = makeCard(rows: [logoutRow])

        [profileHeaderControl, editProfileCard,
         accountSectionLabel, accountCard,
         settingsSectionLabel, settingsCard,
         resourcesSectionLabel, resourcesCard,
         logoutCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview($0)
        }

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: SettingsView, _: UITraitCollection) in
            view.borderedViews.forEach {
                $0.layer.borderColor = UIColor.eventHubGlassBorder.cgColor
            }
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
}
