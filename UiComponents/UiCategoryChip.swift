import UIKit
import Combine

final class UiCategoryChip: UIControl {

    let categoryId: String

    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    private let tapSubject = PassthroughSubject<Void, Never>()
    var tapPublisher: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    override var isSelected: Bool {
        didSet { updateStyle() }
    }

    init(categoryId: String, icon: String, title: String) {
        self.categoryId = categoryId
        super.init(frame: .zero)
        iconLabel.text = icon
        titleLabel.text = title
        setupViews()
        updateStyle()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (chip: UiCategoryChip, _: UITraitCollection) in
            chip.updateStyle()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        iconLabel.font = .systemFont(ofSize: 14)
        iconLabel.isHidden = (iconLabel.text ?? "").isEmpty
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)

        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        [iconLabel, titleLabel].forEach { stackView.addArrangedSubview($0) }
        addSubview(stackView)

        layer.cornerRadius = 18
        layer.borderWidth = 1

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14)
        ])
    }

    private func updateStyle() {
        if isSelected {
            backgroundColor = .eventHubAccent
            layer.borderColor = UIColor.eventHubAccent.cgColor
            titleLabel.textColor = .eventHubOnAccent
            iconLabel.textColor = .eventHubOnAccent
        } else {
            backgroundColor = .clear
            layer.borderColor = UIColor.eventHubSecondary.cgColor
            titleLabel.textColor = .eventHubSecondary
            iconLabel.textColor = .eventHubSecondary
        }
    }

    @objc private func handleTap() {
        tapSubject.send()
    }
}
