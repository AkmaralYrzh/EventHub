import UIKit

final class EventDetailsViewController: UIViewController {

    private let detailsView = EventDetailsView()
    private let viewModel: EventDetailsViewModel

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
        detailsView.configure(with: viewModel.event)
    }
}
