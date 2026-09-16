import UIKit
import Combine

final class UserHomeViewController: UIViewController {

    private let homeView = UserHomeView()
    private let viewModel: UserHomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private var miniListCancellables = Set<AnyCancellable>()

    var onEventTap: ((EventModel) -> Void)?

    private let categories: [(id: String, icon: String, title: String)] = [
        ("all", "", L("category_all")),
        ("music", "", L("category_music")),
        ("art", "", L("category_art")),
        ("sport", "", L("category_sport")),
        ("food", "", L("category_food"))
    ]

    private var filteredEvents: [EventModel] = []

    init(viewModel: UserHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCategoryChips()
        setupCollectionView()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        homeView.titleLabel.text = L("home_title")
        homeView.avatarLabel.text = UserProfile.initials(from: UserDefaults.standard.userName ?? "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupCategoryChips() {
        categories.forEach { category in
            let chip = UiCategoryChip(categoryId: category.id, icon: category.icon, title: category.title)
            chip.isSelected = category.id == viewModel.selectedCategoryId
            chip.tapPublisher
                .sink { [weak self] in
                    self?.selectCategory(category.id)
                }
                .store(in: &cancellables)
            homeView.categoryStackView.addArrangedSubview(chip)
        }
    }

    func setSelectedCity(_ id: String) {
        viewModel.selectedCityId = id
    }

    private func selectCategory(_ id: String) {
        viewModel.selectedCategoryId = id
        homeView.categoryStackView.arrangedSubviews
            .compactMap { $0 as? UiCategoryChip }
            .forEach { $0.isSelected = $0.categoryId == id }
    }

    private func setupCollectionView() {
        homeView.eventsCollectionView.dataSource = self
        homeView.eventsCollectionView.delegate = self
    }

    private func bindViewModel() {
        viewModel.$filteredEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] events in
                self?.filteredEvents = events
                self?.homeView.eventsCollectionView.reloadData()
                self?.updateMiniList()
            }
            .store(in: &cancellables)

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.homeView.stateView.render(state)
                self?.homeView.eventsCollectionView.isHidden = (state != .loaded)
            }
            .store(in: &cancellables)

        homeView.stateView.retryPublisher
            .sink { [weak self] in self?.viewModel.fetchEvents() }
            .store(in: &cancellables)

        viewModel.$favoriteEventIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.homeView.eventsCollectionView.reloadData()
                self?.updateMiniList()
            }
            .store(in: &cancellables)
    }

    private func updateMiniList() {
        miniListCancellables.removeAll()
        homeView.miniListStackView.arrangedSubviews.forEach {
            homeView.miniListStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        filteredEvents.forEach { event in
            let card = UiEventCard()
            card.configure(with: event)
            card.setFavorite(viewModel.favoriteEventIds.contains(event.id))
            card.heightAnchor.constraint(equalToConstant: 140).isActive = true
            card.tapPublisher
                .sink { [weak self] in
                    self?.onEventTap?(event)
                }
                .store(in: &miniListCancellables)
            card.favoriteTapPublisher
                .sink { [weak self] in
                    self?.viewModel.toggleFavorite(eventId: event.id)
                }
                .store(in: &miniListCancellables)
            homeView.miniListStackView.addArrangedSubview(card)
        }
    }
}

extension UserHomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredEvents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EventCardCell.reuseId, for: indexPath) as? EventCardCell else {
            return UICollectionViewCell()
        }
        let event = filteredEvents[indexPath.item]
        cell.card.configure(with: event)
        cell.card.setFavorite(viewModel.favoriteEventIds.contains(event.id))
        cell.card.tapPublisher
            .sink { [weak self] in
                self?.onEventTap?(event)
            }
            .store(in: &cell.cancellables)
        cell.card.favoriteTapPublisher
            .sink { [weak self] in
                self?.viewModel.toggleFavorite(eventId: event.id)
            }
            .store(in: &cell.cancellables)
        return cell
    }
}

extension UserHomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 60
        return CGSize(width: width, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                         insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = (collectionView.bounds.width - (collectionView.bounds.width - 60)) / 2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === homeView.eventsCollectionView else { return }

        let center = CGPoint(x: scrollView.contentOffset.x + scrollView.bounds.width / 2,
                              y: scrollView.bounds.height / 2)

        for cell in homeView.eventsCollectionView.visibleCells {
            let distance = abs(cell.center.x - center.x)
            let maxDistance = scrollView.bounds.width / 2 + cell.bounds.width / 2
            let ratio = max(0, 1 - distance / maxDistance)
            let scale = 0.85 + 0.15 * ratio

            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            cell.alpha = 0.5 + 0.5 * ratio
        }
    }
}
