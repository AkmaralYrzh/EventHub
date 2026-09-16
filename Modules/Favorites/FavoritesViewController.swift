import UIKit
import Combine

final class FavoritesViewController: UIViewController {

    private let favoritesView = FavoritesView()
    private let viewModel: FavoritesViewModel
    private var cancellables = Set<AnyCancellable>()

    var onEventTap: ((EventModel) -> Void)?

    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = favoritesView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        favoritesView.titleLabel.text = L("favorites_title")
        viewModel.refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func bindViewModel() {
        viewModel.$events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] events in
                self?.updateList(events)
            }
            .store(in: &cancellables)
    }

    private func updateList(_ events: [EventModel]) {
        favoritesView.eventsStackView.arrangedSubviews.forEach {
            favoritesView.eventsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        favoritesView.emptyLabel.isHidden = !events.isEmpty
        favoritesView.emptyLabel.text = L("favorites_empty")

        events.forEach { event in
            let card = UiEventCard()
            card.configure(with: event)
            card.setFavorite(true)
            card.heightAnchor.constraint(equalToConstant: 140).isActive = true
            card.tapPublisher
                .sink { [weak self] in
                    self?.onEventTap?(event)
                }
                .store(in: &cancellables)
            card.favoriteTapPublisher
                .sink { [weak self] in
                    self?.viewModel.removeFavorite(eventId: event.id)
                }
                .store(in: &cancellables)
            favoritesView.eventsStackView.addArrangedSubview(card)
        }
    }
}
