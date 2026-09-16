import UIKit

final class EventDetailsView: UIView {

    let coverView = UIView()
    private let coverGradient = CAGradientLayer()
    let titleLabel = UILabel()
    let locationLabel = UILabel()
    let organizerLabel = UILabel()
    let priceLabel = UILabel()
    let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .eventHubBackground
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        coverView.backgroundColor = .clear
        coverView.layer.cornerRadius = 20
        coverView.clipsToBounds = true
        coverView.layer.addSublayer(coverGradient)
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.heightAnchor.constraint(equalToConstant: 220).isActive = true

        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .eventHubTextPrimary
        titleLabel.numberOfLines = 0

        locationLabel.font = .systemFont(ofSize: 15)
        locationLabel.textColor = .eventHubSecondary

        organizerLabel.font = .systemFont(ofSize: 15)
        organizerLabel.textColor = .eventHubSecondary

        priceLabel.font = .systemFont(ofSize: 17, weight: .bold)
        priceLabel.textColor = .eventHubAccent

        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .eventHubTextPrimary
        descriptionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [
            coverView, titleLabel, locationLabel, organizerLabel, priceLabel, descriptionLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        coverGradient.frame = coverView.bounds
    }

    func configure(with event: EventModel) {
        coverGradient.colors = EventCovers.colors(for: event.coverImageName).map { $0.cgColor }
        titleLabel.text = event.title
        locationLabel.text = event.location
        organizerLabel.text = String(format: L("eventdetails_organizer"), event.organizerName)
        priceLabel.text = event.isFree ? L("event_free") : event.price
        descriptionLabel.text = event.description
    }
}
