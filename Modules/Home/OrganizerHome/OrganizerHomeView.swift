import UIKit

final class OrganizerHomeView: UIView {

    let createEventButton = UIButton(type: .system)
    let eventsStackView = UIStackView()
    let stateView = UiStateView()

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .eventHubBackground
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        createEventButton.setTitle(L("createevent_button"), for: .normal)
        createEventButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        createEventButton.setTitleColor(.eventHubOnAccent, for: .normal)
        createEventButton.backgroundColor = .eventHubAccent
        createEventButton.layer.cornerRadius = 14
        createEventButton.translatesAutoresizingMaskIntoConstraints = false

        eventsStackView.axis = .vertical
        eventsStackView.spacing = 10
        eventsStackView.translatesAutoresizingMaskIntoConstraints = false

        stateView.translatesAutoresizingMaskIntoConstraints = false

        [createEventButton, stateView, eventsStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),

            createEventButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
