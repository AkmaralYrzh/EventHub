import UIKit

final class ReelBackgroundView: UIView {

    private let ringContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        setupReel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupReel() {
        ringContainer.translatesAutoresizingMaskIntoConstraints = false
        ringContainer.alpha = 0.4
        addSubview(ringContainer)

        NSLayoutConstraint.activate([
            ringContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            ringContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            ringContainer.widthAnchor.constraint(equalToConstant: 300),
            ringContainer.heightAnchor.constraint(equalToConstant: 300)
        ])

        let covers = EventCovers.gradientStyles

        let radius: CGFloat = 135
        let cardCount = 8
        for i in 0..<cardCount {
            let angle = (CGFloat(i) / CGFloat(cardCount)) * 2 * .pi
            let card = UIView()
            card.translatesAutoresizingMaskIntoConstraints = false
            card.layer.cornerRadius = 10
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.4
            card.layer.shadowRadius = 10
            card.layer.shadowOffset = CGSize(width: 0, height: 6)

            let colorPair = covers[i % covers.count]
            let gradient = CAGradientLayer()
            gradient.colors = [colorPair[0].cgColor, colorPair[1].cgColor]
            gradient.frame = CGRect(x: 0, y: 0, width: 60, height: 88)
            gradient.cornerRadius = 10
            card.layer.addSublayer(gradient)

            ringContainer.addSubview(card)
            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 60),
                card.heightAnchor.constraint(equalToConstant: 88),
                card.centerXAnchor.constraint(equalTo: ringContainer.centerXAnchor, constant: radius * cos(angle)),
                card.centerYAnchor.constraint(equalTo: ringContainer.centerYAnchor, constant: radius * sin(angle))
            ])
        }

        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 42
        rotation.repeatCount = .infinity
        ringContainer.layer.add(rotation, forKey: "reelSpin")
    }
}
