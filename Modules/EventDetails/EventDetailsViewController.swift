import UIKit
import Combine

final class EventDetailsViewController: UIViewController {

    private let detailsView = EventDetailsView()
    private let viewModel: EventDetailsViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: EventDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = detailsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        detailsView.joinButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.toggleJoin()
        }, for: .touchUpInside)
    }

    // MARK: - Связывание View и ViewModel
    private func bindViewModel() {
        viewModel.$event
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.detailsView.configure(with: event)
                self?.updateJoinControls()
            }
            .store(in: &cancellables)

        viewModel.$isJoined.combineLatest(viewModel.$isBusy)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateJoinControls() }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.detailsView.errorLabel.text = message
                self?.detailsView.errorLabel.isHidden = (message == nil)
            }
            .store(in: &cancellables)
    }

    private func updateJoinControls() {
        if viewModel.canJoin, viewModel.event.isFull, !viewModel.isJoined {
            detailsView.setStatus(L("eventdetails_full"))
        } else if viewModel.canJoin {
            detailsView.setJoinState(isJoined: viewModel.isJoined, isBusy: viewModel.isBusy)
        } else if !viewModel.event.isUpcoming() {
            detailsView.setStatus(L("eventdetails_past"))
        } else if UserDefaults.standard.userRole == .organizer {
            // Организатору показываем только счётчик участников — он уже есть в списке информации.
            detailsView.setStatus(nil)
        } else {
            detailsView.setStatus(nil)
        }
    }
}
