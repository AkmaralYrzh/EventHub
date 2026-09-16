import UIKit

final class OnboardingViewController: UIViewController {

    var onContinue: (() -> Void)?

    private let viewModel: OnboardingViewModel
    private let onboardingView = OnboardingView()

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = onboardingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        onboardingView.titleLabel.text = viewModel.title
        onboardingView.subtitleLabel.text = viewModel.subtitle
        onboardingView.continueButton.setTitle(viewModel.continueButtonTitle, for: .normal)

        onboardingView.continueButton.addAction(UIAction { [weak self] _ in
            self?.onContinue?()
        }, for: .touchUpInside)
    }
}
