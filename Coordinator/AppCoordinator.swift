import UIKit
import Combine

final class AppCoordinator: Coordinator {

    // MARK: Свойства
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let authService = AuthService()

    private weak var homeNavigationController: UINavigationController?
    private weak var tabBarController: UITabBarController?
    private weak var userHomeVC: UserHomeViewController?
    private weak var profileNavigationController: UINavigationController?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Создание
    private init(windowScene: UIWindowScene) {
        self.window = UIWindow(windowScene: windowScene)
        self.navigationController = UINavigationController()
    }

    static func start(windowScene: UIWindowScene) -> AppCoordinator {
        let coordinator = AppCoordinator(windowScene: windowScene)
        coordinator.start()
        return coordinator
    }

    // MARK: Точка входа: решает, какой сценарий запуска показать
    func start() {
        navigationController.isNavigationBarHidden = true
        window.rootViewController = navigationController
        window.overrideUserInterfaceStyle = UserDefaults.standard.forceDarkTheme ? .dark : .unspecified
        window.makeKeyAndVisible()

        authService.authStateDidChangePublisher
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self else { return }
                if !UserDefaults.standard.hasSeenOnboarding {
                    self.showOnboarding()
                } else if let user = user {
                    self.fetchProfileAndRoute(user: user)
                } else {
                    self.showLogin()
                }
            }
            .store(in: &cancellables)
    }

    private func fetchProfileAndRoute(user: AuthUser) {
        authService.fetchAndCacheProfile(uid: user.uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.routeByRole()
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.routeByRole()
                }
            )
            .store(in: &cancellables)
    }

    private func routeByRole() {
        switch UserDefaults.standard.userRole {
        case .user:        showUserHome()
        case .organizer:   showOrganizerHome()
        case .none:        showLogin()
        }
    }

    private func showUserHome() {
        let homeVC = UserHomeViewController(viewModel: UserHomeViewModel())
        homeVC.onEventTap = { [weak self] event in self?.showEventDetails(event: event) }
        homeVC.tabBarItem = UITabBarItem(title: L("tab_feed"), image: UIImage(systemName: "list.bullet"), tag: 0)
        userHomeVC = homeVC

        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNavigationController = homeNav
        navigationController.setViewControllers([makeTabBar(homeNav: homeNav)], animated: true)
    }

    private func showOrganizerHome() {
        let homeVC = OrganizerHomeViewController(viewModel: OrganizerHomeViewModel())
        homeVC.onCreateEventTap = { [weak self] in self?.showCreateEvent() }
        homeVC.onEventTap       = { [weak self] event in self?.showEventDetails(event: event) }
        homeVC.tabBarItem = UITabBarItem(title: L("tab_events"), image: UIImage(systemName: "calendar"), tag: 0)
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNavigationController = homeNav
        navigationController.setViewControllers([makeTabBar(homeNav: homeNav)], animated: true)
    }

    private func makeTabBar(homeNav: UINavigationController) -> UITabBarController {
        let cityVC = CitySelectionViewController(viewModel: CitySelectionViewModel())
        cityVC.onCitySelected = { [weak self] cityId in
            self?.userHomeVC?.setSelectedCity(cityId)
            self?.tabBarController?.selectedIndex = 0
        }
        cityVC.tabBarItem = UITabBarItem(title: L("tab_map"), image: UIImage(systemName: "map"), tag: 1)
        let cityNav = UINavigationController(rootViewController: cityVC)

        let favoritesVC = FavoritesViewController(viewModel: FavoritesViewModel())
        favoritesVC.onEventTap = { [weak self] event in self?.showEventDetails(event: event) }
        favoritesVC.tabBarItem = UITabBarItem(title: L("tab_favorites"), image: UIImage(systemName: "heart"), tag: 2)
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)

        let profileVC = ProfileViewController(viewModel: ProfileViewModel())
        profileVC.onEventTap    = { [weak self] event in self?.showEventDetails(event: event) }
        profileVC.onSettingsTap = { [weak self] in self?.showSettings() }
        profileVC.onLogout      = { [weak self] in self?.handleLogout() }
        profileVC.tabBarItem = UITabBarItem(title: L("tab_profile"), image: UIImage(systemName: "person"), tag: 3)
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNavigationController = profileNav

        let tabBar = UITabBarController()
        tabBar.viewControllers = [homeNav, cityNav, favoritesNav, profileNav]
        tabBar.tabBar.tintColor = .eventHubAccent
        tabBarController = tabBar
        return tabBar
    }

    private func showCreateEvent() {
        let vc = CreateEventViewController(viewModel: CreateEventViewModel())
        vc.onEventCreated = { [weak self] in
            self?.homeNavigationController?.popViewController(animated: true)
        }
        homeNavigationController?.pushViewController(vc, animated: true)
    }

    private func showEventDetails(event: EventModel) {
        let vc = EventDetailsViewController(viewModel: EventDetailsViewModel(event: event))
        let activeNav = (tabBarController?.selectedViewController as? UINavigationController) ?? homeNavigationController
        activeNav?.pushViewController(vc, animated: true)
    }

    private func showSettings() {
        let vc = SettingsViewController(viewModel: SettingsViewModel())
        vc.onLogout = { [weak self] in self?.handleLogout() }
        vc.onProfileTap = { [weak self] in
            self?.profileNavigationController?.popViewController(animated: true)
        }
        profileNavigationController?.pushViewController(vc, animated: true)
    }

    private func showLogin() {
        let vc = LoginViewController(viewModel: LoginViewModel())
        vc.onLoginSuccess = { [weak self] user in self?.fetchProfileAndRoute(user: user) }
        vc.onSignUpTap    = { [weak self] in self?.showSignUp() }
        navigationController.setViewControllers([vc], animated: true)
    }

    private func showSignUp() {
        let vc = SignUpViewController(viewModel: SignUpViewModel())
        vc.onSignUpSuccess = { [weak self] in self?.routeByRole() }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showOnboarding() {
        let vc = OnboardingViewController(viewModel: OnboardingViewModel())
        vc.onContinue = { [weak self] in
            UserDefaults.standard.hasSeenOnboarding = true
            self?.showLogin()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    private func handleLogout() {
        try? authService.logout()
        UserDefaults.standard.userRole = nil
        UserDefaults.standard.userName = nil
        showLogin()
    }
}
