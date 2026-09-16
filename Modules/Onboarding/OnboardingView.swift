import UIKit

final class OnboardingView: UIView {

    private let reelBackground = ReelBackgroundView()

    private let walnutGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.49, green: 0.40, blue: 0.35, alpha: 1).cgColor,
            UIColor(red: 0.37, green: 0.29, blue: 0.26, alpha: 1).cgColor,
            UIColor(red: 0.18, green: 0.12, blue: 0.11, alpha: 1).cgColor
        ]
        layer.locations = [0, 0.45, 1]
        layer.startPoint = CGPoint(x: 0.35, y: 0.05)
        layer.endPoint = CGPoint(x: 0.65, y: 0.95)
        return layer
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(red: 0.18, green: 0.12, blue: 0.11, alpha: 1), for: .normal)
        button.backgroundColor = UIColor(red: 0.94, green: 0.90, blue: 0.85, alpha: 1)
        button.layer.cornerRadius = 14
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(walnutGradient, at: 0)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        walnutGradient.frame = bounds
    }

    private func setupViews() {
        reelBackground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(reelBackground)
        NSLayoutConstraint.activate([
            reelBackground.topAnchor.constraint(equalTo: topAnchor),
            reelBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            reelBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            reelBackground.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        [titleLabel, subtitleLabel, continueButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),

            continueButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
