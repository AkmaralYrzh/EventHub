import UIKit
import Combine

/// Индикатор загрузки / пустое состояние / ошибка с кнопкой «Повторить».
/// Один компонент на все списки, чтобы экраны не дублировали эту логику.
final class UiStateView: UIView {

    private let indicator = UIActivityIndicatorView(style: .medium)
    private let iconView = UIImageView()
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let stack = UIStackView()

    private let retrySubject = PassthroughSubject<Void, Never>()
    var retryPublisher: AnyPublisher<Void, Never> { retrySubject.eraseToAnyPublisher() }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(_ state: ListState) {
        switch state {
        case .loading:
            isHidden = false
            indicator.startAnimating()
            iconView.isHidden = true
            messageLabel.isHidden = true
            retryButton.isHidden = true

        case .loaded:
            isHidden = true
            indicator.stopAnimating()

        case .empty(let message):
            isHidden = false
            indicator.stopAnimating()
            iconView.image = UIImage(systemName: "calendar.badge.exclamationmark")
            iconView.tintColor = .eventHubSecondary
            iconView.isHidden = false
            messageLabel.text = message
            messageLabel.textColor = .eventHubSecondary
            messageLabel.isHidden = false
            retryButton.isHidden = true

        case .error(let message):
            isHidden = false
            indicator.stopAnimating()
            iconView.image = UIImage(systemName: "wifi.exclamationmark")
            iconView.tintColor = .eventHubError
            iconView.isHidden = false
            messageLabel.text = message
            messageLabel.textColor = .eventHubError
            messageLabel.isHidden = false
            retryButton.isHidden = false
        }
    }

    private func setupViews() {
        isHidden = true

        indicator.hidesWhenStopped = true
        indicator.color = .eventHubSecondary

        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)

        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        var config = UIButton.Configuration.filled()
        config.title = L("common_retry")
        config.baseBackgroundColor = .eventHubAccent
        config.baseForegroundColor = .eventHubOnAccent
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 22, bottom: 10, trailing: 22)
        retryButton.configuration = config
        retryButton.addAction(UIAction { [weak self] _ in self?.retrySubject.send() }, for: .touchUpInside)

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        [indicator, iconView, messageLabel, retryButton].forEach { stack.addArrangedSubview($0) }
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
