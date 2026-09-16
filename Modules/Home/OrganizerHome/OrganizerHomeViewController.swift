import UIKit
import Combine

final class OrganizerHomeViewController: UIViewController {

    private let organizerView = OrganizerHomeView()
    private let viewModel: OrganizerHomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private var cardCancellables = Set<AnyCancellable>()

    var onCreateEventTap: (() -> Void)?
    var onEventTap: ((EventModel) -> Void)?

    init(viewModel: OrganizerHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = organizerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        organizerView.createEventButton.addTarget(self, action: #selector(createEventTapped), for: .touchUpInside)
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchMyEvents()
    }

    private func bindViewModel() {
        viewModel.$events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] events in
                self?.updateEventsList(events)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading
                    ? self?.organizerView.loadingIndicator.startAnimating()
                    : self?.organizerView.loadingIndicator.stopAnimating()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.organizerView.errorLabel.text = message
                self?.organizerView.errorLabel.isHidden = (message == nil)
            }
            .store(in: &cancellables)
    }

    private func updateEventsList(_ events: [EventModel]) {
        cardCancellables.removeAll()
        organizerView.eventsStackView.arrangedSubviews.forEach {
            organizerView.eventsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        events.forEach { event in
            let card = UiEventCard()
            card.configure(with: event)
            card.setFavoriteButtonHidden(true)
            card.heightAnchor.constraint(equalToConstant: 140).isActive = true
            card.tapPublisher
                .sink { [weak self] in
                    self?.onEventTap?(event)
                }
                .store(in: &cardCancellables)
            organizerView.eventsStackView.addArrangedSubview(card)
        }
    }

    @objc private func createEventTapped() {
        onCreateEventTap?()
    }
}
