import UIKit
import Combine

final class ProfileViewController: UIViewController {

    private let profileView = ProfileView()
    private let viewModel: ProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    private var cardCancellables = Set<AnyCancellable>()

    var onSettingsTap: (() -> Void)?
    var onEventTap: ((EventModel) -> Void)?
    var onLogout: (() -> Void)?

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = profileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.settingsButton.addAction(UIAction { [weak self] _ in
            self?.onSettingsTap?()
        }, for: .touchUpInside)

        setupHeader()
        setupTabsControl()
        setupLogoutButton()
        bindViewModel()
    }

    private func setupLogoutButton() {
        profileView.logoutButton.setTitle(L("profile_logout"), for: .normal)
        profileView.logoutButton.addAction(UIAction { [weak self] _ in
            self?.onLogout?()
        }, for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.loadProfile()
        viewModel.fetchEvents()
        setupHeader()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupHeader() {
        profileView.screenTitleLabel.text = L("tab_profile")
        profileView.nameLabel.text = viewModel.userName
        profileView.avatarLabel.text = UserProfile.initials(from: viewModel.userName)

        let isOrganizer = viewModel.userRole == .organizer
        profileView.roleBadge.text = "  \(isOrganizer ? L("profile_role_organizer") : L("profile_role_user"))  "
        profileView.roleBadge.backgroundColor = isOrganizer ? .eventHubRoleOrganizerBackground : .eventHubRoleUserBackground
        profileView.roleBadge.textColor = isOrganizer ? .eventHubRoleOrganizerText : .eventHubRoleUserText
    }

    private func setupTabsControl() {
        profileView.tabsControl.removeAllSegments()
        profileView.tabsControl.insertSegment(withTitle: L("profile_tab_upcoming"), at: 0, animated: false)
        profileView.tabsControl.insertSegment(withTitle: L("profile_tab_past"), at: 1, animated: false)
        profileView.tabsControl.selectedSegmentIndex = 0
        profileView.tabsControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.viewModel.selectedTab = self.profileView.tabsControl.selectedSegmentIndex == 0 ? .upcoming : .past
            self.updateList()
        }, for: .valueChanged)
    }

    private func bindViewModel() {
        viewModel.$events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateList() }
            .store(in: &cancellables)
    }

    private func updateList() {
        cardCancellables.removeAll()
        profileView.eventsStackView.arrangedSubviews.forEach {
            profileView.eventsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let events = viewModel.visibleEvents
        profileView.emptyLabel.isHidden = !events.isEmpty
        profileView.emptyLabel.text = viewModel.userRole == .organizer ? L("organizer_empty") : L("profile_events_empty")

        events.forEach { event in
            let card = UiEventCard()
            card.configure(with: event)
            card.heightAnchor.constraint(equalToConstant: 140).isActive = true
            card.tapPublisher
                .sink { [weak self] in self?.onEventTap?(event) }
                .store(in: &cardCancellables)
            // В профиле — свои события (организатор) или свои записи (посетитель); сердечко здесь не нужно.
            card.setFavoriteButtonHidden(true)
            profileView.eventsStackView.addArrangedSubview(card)
        }
    }
}
