import UIKit
import Combine

final class CreateEventViewController: UIViewController {

    private let createView = CreateEventView()
    private let viewModel: CreateEventViewModel
    private var cancellables = Set<AnyCancellable>()

    var onEventCreated: (() -> Void)?

    init(viewModel: CreateEventViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = createView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        createView.createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }

    private func setupBindings() {
        viewModel.$isReadyToCreate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReady in
                self?.createView.createButton.isEnabled = isReady
                self?.createView.createButton.alpha = isReady ? 1.0 : 0.5
            }
            .store(in: &cancellables)

        createView.titleField.publisher(for: \.text)
            .compactMap { $0 }
            .assign(to: \.title, on: viewModel)
            .store(in: &cancellables)

        createView.descriptionField.publisher(for: \.text)
            .compactMap { $0 }
            .assign(to: \.description, on: viewModel)
            .store(in: &cancellables)

        createView.locationField.publisher(for: \.text)
            .compactMap { $0 }
            .assign(to: \.location, on: viewModel)
            .store(in: &cancellables)

        createView.priceField.publisher(for: \.text)
            .compactMap { $0 }
            .assign(to: \.price, on: viewModel)
            .store(in: &cancellables)

        createView.freeSwitch.publisher(for: \.isOn)
            .assign(to: \.isFree, on: viewModel)
            .store(in: &cancellables)

        createView.freeSwitch.publisher(for: \.isOn)
            .sink { [weak self] isOn in
                self?.createView.freeLabel.text = isOn ? L("event_free") : L("event_paid")
            }
            .store(in: &cancellables)

        let cities = ["almaty", "astana", "shymkent", "aktobe"]
        createView.cityControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.viewModel.city = cities[self.createView.cityControl.selectedSegmentIndex]
        }, for: .valueChanged)

        let categories = ["music", "art", "sport", "food"]
        createView.categoryControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.viewModel.category = categories[self.createView.categoryControl.selectedSegmentIndex]
        }, for: .valueChanged)

        createView.datePicker.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.viewModel.startDate = self.createView.datePicker.date
        }, for: .valueChanged)

        createView.coverSwatchesStackView.arrangedSubviews
            .compactMap { $0 as? UIControl }
            .forEach { swatch in
                swatch.addAction(UIAction { [weak self] _ in
                    guard let self, let id = swatch.accessibilityIdentifier else { return }
                    self.viewModel.coverImageName = id
                    self.createView.selectCoverSwatch(id: id)
                }, for: .touchUpInside)
            }
    }
    @objc private func createTapped() {
        createView.errorLabel.isHidden = true

        createView.createButton.isEnabled = false
        createView.createButton.alpha = 0.5

        viewModel.createEvent()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.createView.createButton.isEnabled = true
                    self?.createView.createButton.alpha = 1

                    if case .failure(let error) = completion {
                        self?.createView.errorLabel.text = error.localizedDescription
                        self?.createView.errorLabel.isHidden = false
                    }
                },
                receiveValue: { [weak self] in
                    self?.onEventCreated?()
                }
            )
            .store(in: &cancellables)
    }
}
