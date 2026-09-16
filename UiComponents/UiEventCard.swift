import UIKit
import Combine

final class UiEventCard: UIControl {

    private let coverView = UIView()
    private let coverGradient = CAGradientLayer()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let priceLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)

    private let tapSubject = PassthroughSubject<Void, Never>()
    var tapPublisher: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private let favoriteTapSubject = PassthroughSubject<Void, Never>()
    var favoriteTapPublisher: AnyPublisher<Void, Never> {
        favoriteTapSubject.eraseToAnyPublisher()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(handleFavoriteTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        layer.cornerRadius = 20
        clipsToBounds = true
        backgroundColor = .eventHubMuted

        coverView.backgroundColor = .eventHubAccent
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.isUserInteractionEnabled = false
        coverView.layer.addSublayer(coverGradient)

        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = UIColor.white.withAlphaComponent(0.8)

        priceLabel.font = .systemFont(ofSize: 12, weight: .bold)
        priceLabel.textColor = .white
        priceLabel.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        priceLabel.layer.cornerRadius = 10
        priceLabel.clipsToBounds = true
        priceLabel.textAlignment = .center

        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .white
        favoriteButton.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        favoriteButton.layer.cornerRadius = 14

        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaLabel, priceLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        [coverView, textStack, favoriteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            coverView.topAnchor.constraint(equalTo: topAnchor),
            coverView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverView.bottomAnchor.constraint(equalTo: bottomAnchor),

            favoriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),

            textStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            priceLabel.heightAnchor.constraint(equalToConstant: 20),
            priceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }

    func configure(with event: EventModel) {
        titleLabel.text = event.title
        metaLabel.text = [event.location, event.startDate.eventHubFormatted]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
        priceLabel.text = event.isFree ? "  \(L("event_free"))  " : "  \(event.price)  "

        let colors = EventCovers.colors(for: event.coverImageName)
        coverGradient.colors = colors.map { $0.cgColor }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        coverGradient.frame = coverView.bounds
    }

    func setFavorite(_ isFavorite: Bool) {
        favoriteButton.setImage(UIImage(systemName: isFavorite ? "heart.fill" : "heart"), for: .normal)
    }

    func setFavoriteButtonHidden(_ isHidden: Bool) {
        favoriteButton.isHidden = isHidden
    }

    @objc private func handleTap() {
        tapSubject.send()
    }

    @objc private func handleFavoriteTap() {
        favoriteTapSubject.send()
    }
}
