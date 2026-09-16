import UIKit
import Combine

final class UiCityCard: UIControl {

    private let iconLabel = UILabel()
    private let nameLabel = UILabel()
    private let countLabel = UILabel()

    private let tapSubject = PassthroughSubject<Void, Never>()
    var tapPublisher: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        layer.cornerRadius = 16
        clipsToBounds = true
        backgroundColor = .eventHubMuted
        heightAnchor.constraint(equalToConstant: 100).isActive = true

        iconLabel.font = .systemFont(ofSize: 24)

        nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        nameLabel.textColor = .eventHubTextPrimary

        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textColor = .eventHubSecondary

        let stack = UIStackView(arrangedSubviews: [iconLabel, nameLabel, countLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    func configure(icon: String, name: String, count: Int) {
        iconLabel.text = icon
        iconLabel.isHidden = icon.isEmpty
        nameLabel.text = name
        countLabel.text = "\(count) \(L("city_events_suffix"))"
    }

    @objc private func handleTap() {
        tapSubject.send()
    }
}
