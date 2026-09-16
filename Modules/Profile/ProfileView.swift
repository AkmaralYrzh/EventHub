import UIKit

final class ProfileView: UIView {

    let screenTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .eventHubTextPrimary
        label.textAlignment = .center
        return label
    }()

    let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "gearshape"), for: .normal)
        button.tintColor = .eventHubAccent
        return button
    }()

    let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .eventHubTextPrimary
        label.backgroundColor = .eventHubGlassFill
        label.layer.cornerRadius = 38
        label.layer.masksToBounds = true
        return label
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    let roleBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 11
        label.layer.masksToBounds = true
        return label
    }()

    let tabsControl = UISegmentedControl()

    let eventsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    let emptyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .eventHubSecondary
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.eventHubError, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .eventHubGlassFill
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.eventHubGlassBorder.cgColor
        return button
    }()

    private let scrollView = UIScrollView()
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 22
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

    private func setupViews() {
        let headerStack = UIStackView(arrangedSubviews: [avatarLabel, nameLabel, roleBadge])
        headerStack.axis = .vertical
        headerStack.spacing = 10
        headerStack.alignment = .center

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        addSubview(scrollView)

        let titleSpacer = UIView()
        titleSpacer.translatesAutoresizingMaskIntoConstraints = false

        let titleRow = UIStackView(arrangedSubviews: [titleSpacer, screenTitleLabel, settingsButton])
        titleRow.axis = .horizontal
        titleRow.alignment = .center

        [titleRow, headerStack, tabsControl, emptyLabel, eventsStackView, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview($0)
        }
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),

            settingsButton.widthAnchor.constraint(equalToConstant: 32),
            settingsButton.heightAnchor.constraint(equalToConstant: 32),
            titleSpacer.widthAnchor.constraint(equalTo: settingsButton.widthAnchor),

            avatarLabel.widthAnchor.constraint(equalToConstant: 76),
            avatarLabel.heightAnchor.constraint(equalToConstant: 76),

            roleBadge.heightAnchor.constraint(equalToConstant: 22),
            roleBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),

            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: ProfileView, _: UITraitCollection) in
            view.logoutButton.layer.borderColor = UIColor.eventHubGlassBorder.cgColor
        }
    }
}
