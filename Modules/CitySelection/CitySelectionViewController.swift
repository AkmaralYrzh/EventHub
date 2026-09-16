import UIKit
import Combine

final class CitySelectionViewController: UIViewController {

    private let citySelectionView = CitySelectionView()
    private let viewModel: CitySelectionViewModel
    private var cancellables = Set<AnyCancellable>()

    var onCitySelected: ((String) -> Void)?

    init(viewModel: CitySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = citySelectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        citySelectionView.titleLabel.text = L("city_selection_title")
        citySelectionView.subtitleLabel.text = L("city_subtitle")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func bindViewModel() {
        viewModel.$cities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cities in
                self?.updateGrid(cities)
            }
            .store(in: &cancellables)
    }

    private func updateGrid(_ cities: [CitySelectionViewModel.CityItem]) {
        citySelectionView.gridStackView.arrangedSubviews.forEach {
            citySelectionView.gridStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let allCard = UiCityCard()
        allCard.configure(icon: "", name: L("city_all"), count: cities.reduce(0) { $0 + $1.count })
        allCard.tapPublisher
            .sink { [weak self] in
                self?.onCitySelected?("all")
            }
            .store(in: &cancellables)

        var rowCards: [UIView] = [allCard]

        for city in cities {
            let card = UiCityCard()
            card.configure(icon: city.icon, name: city.name, count: city.count)
            card.tapPublisher
                .sink { [weak self] in
                    self?.onCitySelected?(city.id)
                }
                .store(in: &cancellables)
            rowCards.append(card)
        }

        for pair in stride(from: 0, to: rowCards.count, by: 2) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 12
            row.distribution = .fillEqually

            row.addArrangedSubview(rowCards[pair])
            if pair + 1 < rowCards.count {
                row.addArrangedSubview(rowCards[pair + 1])
            } else {
                row.addArrangedSubview(UIView())
            }

            citySelectionView.gridStackView.addArrangedSubview(row)
        }
    }
}
