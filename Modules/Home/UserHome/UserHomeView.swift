import UIKit

final class UserHomeView: UIView {

    let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .eventHubTextPrimary
        label.backgroundColor = .eventHubGlassFill
        label.layer.cornerRadius = 19
        label.layer.masksToBounds = true
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .eventHubTextPrimary
        label.textAlignment = .center
        label.text = L("home_title")
        return label
    }()

    let categoryScrollView = UIScrollView()
    let categoryStackView = UIStackView()

    let eventsCollectionView: UICollectionView

    let miniListStackView = UIStackView()

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        eventsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

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
        scrollView.contentInsetAdjustmentBehavior = .never
        addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.showsHorizontalScrollIndicator = false

        categoryStackView.axis = .horizontal
        categoryStackView.spacing = 8
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.addSubview(categoryStackView)

        eventsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        eventsCollectionView.backgroundColor = .clear
        eventsCollectionView.showsHorizontalScrollIndicator = false
        eventsCollectionView.decelerationRate = .fast
        eventsCollectionView.register(EventCardCell.self, forCellWithReuseIdentifier: EventCardCell.reuseId)

        miniListStackView.axis = .vertical
        miniListStackView.spacing = 10
        miniListStackView.translatesAutoresizingMaskIntoConstraints = false

        let headerSpacer = UIView()
        headerSpacer.translatesAutoresizingMaskIntoConstraints = false

        let headerStack = UIStackView(arrangedSubviews: [avatarLabel, titleLabel, headerSpacer])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.isLayoutMarginsRelativeArrangement = true
        headerStack.directionalLayoutMargins = .init(top: 0, leading: 20, bottom: 0, trailing: 20)

        [headerStack, categoryScrollView, eventsCollectionView, miniListStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            avatarLabel.widthAnchor.constraint(equalToConstant: 38),
            avatarLabel.heightAnchor.constraint(equalToConstant: 38),
            headerSpacer.widthAnchor.constraint(equalTo: avatarLabel.widthAnchor),

            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            categoryScrollView.heightAnchor.constraint(equalToConstant: 40),
            categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
            categoryStackView.bottomAnchor.constraint(equalTo: categoryScrollView.bottomAnchor),
            categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor, constant: 20),
            categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor, constant: -20),
            categoryStackView.heightAnchor.constraint(equalTo: categoryScrollView.heightAnchor),

            eventsCollectionView.heightAnchor.constraint(equalToConstant: 340),

            miniListStackView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: 20),
            miniListStackView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -20)
        ])
    }
}
