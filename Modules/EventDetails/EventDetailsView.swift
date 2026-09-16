import UIKit

final class EventDetailsView: UIView {

    let coverView = UIView()
    private let coverGradient = CAGradientLayer()
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let locationLabel = UILabel()
    let organizerLabel = UILabel()
    let participantsLabel = UILabel()
    let priceLabel = UILabel()
    let descriptionLabel = UILabel()
    let errorLabel = UILabel()
    let statusLabel = UILabel()
    let joinButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .eventHubBackground
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Строка «иконка + текст» для даты, места, организатора и участников.
    private func makeInfoRow(icon: String, label: UILabel) -> UIStackView {
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .eventHubSecondary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true

        label.font = .systemFont(ofSize: 15)
        label.textColor = .eventHubSecondary
        label.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [iconView, label])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .top
        return row
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

        let dateRow = makeInfoRow(icon: "calendar", label: dateLabel)
        let locationRow = makeInfoRow(icon: "mappin.and.ellipse", label: locationLabel)
        let organizerRow = makeInfoRow(icon: "person.crop.circle", label: organizerLabel)
        let participantsRow = makeInfoRow(icon: "person.2", label: participantsLabel)

        let infoStack = UIStackView(arrangedSubviews: [dateRow, locationRow, organizerRow, participantsRow])
        infoStack.axis = .vertical
        infoStack.spacing = 8

        priceLabel.font = .systemFont(ofSize: 17, weight: .bold)
        priceLabel.textColor = .eventHubAccent

        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .eventHubTextPrimary
        descriptionLabel.numberOfLines = 0

        errorLabel.font = .systemFont(ofSize: 13)
        errorLabel.textColor = .eventHubError
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true

        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = .eventHubSecondary
        statusLabel.textAlignment = .center
        statusLabel.isHidden = true

        joinButton.layer.cornerRadius = 14
        joinButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        joinButton.isHidden = true

        let stack = UIStackView(arrangedSubviews: [
            coverView, titleLabel, infoStack, priceLabel, descriptionLabel, errorLabel, statusLabel, joinButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(20, after: descriptionLabel)
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
        dateLabel.text = event.startDate.eventHubFormatted
        locationLabel.text = event.location
        organizerLabel.text = String(format: L("eventdetails_organizer"), event.organizerName)
        if let capacity = event.capacity {
            participantsLabel.text = String(format: L("eventdetails_participants_of"), event.participantsCount, capacity)
        } else {
            participantsLabel.text = String(format: L("eventdetails_participants"), event.participantsCount)
        }
        priceLabel.text = event.isFree ? L("event_free") : event.price
        descriptionLabel.text = event.description
    }

    /// Кнопка записи: закрашенная «Записаться» или контурная «Отменить запись».
    func setJoinState(isJoined: Bool, isBusy: Bool) {
        joinButton.isHidden = false
        statusLabel.isHidden = true
        joinButton.setTitle(isJoined ? L("eventdetails_leave") : L("eventdetails_join"), for: .normal)
        joinButton.backgroundColor = isJoined ? .clear : .eventHubAccent
        joinButton.setTitleColor(isJoined ? .eventHubAccent : .eventHubOnAccent, for: .normal)
        joinButton.layer.borderWidth = isJoined ? 1.5 : 0
        joinButton.layer.borderColor = UIColor.eventHubAccent.cgColor
        joinButton.isEnabled = !isBusy
        joinButton.alpha = isBusy ? 0.5 : 1
    }

    /// Вместо кнопки — пояснение, почему записаться нельзя (событие прошло / своё событие).
    func setStatus(_ text: String?) {
        joinButton.isHidden = true
        statusLabel.text = text
        statusLabel.isHidden = (text == nil)
    }
}
