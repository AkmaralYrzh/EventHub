import UIKit

final class CreateEventView: UIView {
    let titleField = UITextField()
    let descriptionField = UITextField()
    let locationField = UITextField()
    let cityControl = UISegmentedControl()
    let categoryControl = UISegmentedControl()
    let priceField = UITextField()
    let freeSwitch = UISwitch()
    let freeLabel = UILabel()
    let createButton = UIButton(type: .system)
    let errorLabel = UILabel()

    let coverPreviewView = UIView()
    private let coverPreviewGradient = CAGradientLayer()
    let coverPreviewLabel = UILabel()
    let coverSwatchesStackView = UIStackView()

    let dateLabel = UILabel()
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        picker.minimumDate = Date()
        picker.minuteInterval = 5
        return picker
    }()

    private let scrollView = UIScrollView()
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .eventHubBackground
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        coverPreviewGradient.frame = coverPreviewView.bounds
    }

    func selectCoverSwatch(id: String) {
        coverSwatchesStackView.arrangedSubviews
            .compactMap { $0 as? UIControl }
            .forEach { $0.layer.borderWidth = ($0.accessibilityIdentifier == id) ? 3 : 0 }

        let colors = EventCovers.colors(for: id)
        coverPreviewGradient.colors = colors.map { $0.cgColor }
        coverPreviewLabel.text = EventCovers.templates.first(where: { $0.id == id })?.label ?? ""
    }

    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        addSubview(scrollView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        coverPreviewView.layer.cornerRadius = 20
        coverPreviewView.clipsToBounds = true
        coverPreviewView.layer.addSublayer(coverPreviewGradient)
        coverPreviewView.translatesAutoresizingMaskIntoConstraints = false
        coverPreviewView.heightAnchor.constraint(equalToConstant: 130).isActive = true

        coverPreviewLabel.font = .systemFont(ofSize: 15, weight: .bold)
        coverPreviewLabel.textColor = .white
        coverPreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        coverPreviewView.addSubview(coverPreviewLabel)
        NSLayoutConstraint.activate([
            coverPreviewLabel.leadingAnchor.constraint(equalTo: coverPreviewView.leadingAnchor, constant: 14),
            coverPreviewLabel.bottomAnchor.constraint(equalTo: coverPreviewView.bottomAnchor, constant: -12)
        ])

        coverSwatchesStackView.axis = .horizontal
        coverSwatchesStackView.spacing = 8
        EventCovers.templates.forEach { template in
            let swatch = UIControl()
            swatch.accessibilityIdentifier = template.id
            swatch.layer.cornerRadius = 10
            swatch.layer.borderColor = UIColor.white.cgColor
            swatch.translatesAutoresizingMaskIntoConstraints = false
            swatch.widthAnchor.constraint(equalToConstant: 52).isActive = true
            swatch.heightAnchor.constraint(equalToConstant: 52).isActive = true

            let gradient = CAGradientLayer()
            gradient.colors = template.colors.map { $0.cgColor }
            gradient.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
            gradient.cornerRadius = 10
            swatch.layer.addSublayer(gradient)

            coverSwatchesStackView.addArrangedSubview(swatch)
        }
        let swatchesScroll = UIScrollView()
        swatchesScroll.showsHorizontalScrollIndicator = false
        swatchesScroll.translatesAutoresizingMaskIntoConstraints = false
        swatchesScroll.heightAnchor.constraint(equalToConstant: 52).isActive = true
        coverSwatchesStackView.translatesAutoresizingMaskIntoConstraints = false
        swatchesScroll.addSubview(coverSwatchesStackView)
        NSLayoutConstraint.activate([
            coverSwatchesStackView.topAnchor.constraint(equalTo: swatchesScroll.topAnchor),
            coverSwatchesStackView.bottomAnchor.constraint(equalTo: swatchesScroll.bottomAnchor),
            coverSwatchesStackView.leadingAnchor.constraint(equalTo: swatchesScroll.leadingAnchor),
            coverSwatchesStackView.trailingAnchor.constraint(equalTo: swatchesScroll.trailingAnchor),
            coverSwatchesStackView.heightAnchor.constraint(equalTo: swatchesScroll.heightAnchor)
        ])

        dateLabel.text = L("createevent_start_date")
        dateLabel.textColor = .eventHubTextPrimary
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        let dateRow = UIStackView(arrangedSubviews: [dateLabel, datePicker])
        dateRow.axis = .horizontal
        dateRow.distribution = .equalSpacing

        [titleField, descriptionField, locationField, priceField].forEach { field in
            field.borderStyle = .roundedRect
            field.backgroundColor = .eventHubGlassFill
            field.textColor = .eventHubTextPrimary
            field.translatesAutoresizingMaskIntoConstraints = false
            field.heightAnchor.constraint(equalToConstant: 46).isActive = true
        }

        titleField.placeholder = L("createevent_title_placeholder")
        descriptionField.placeholder = L("createevent_description_placeholder")
        locationField.placeholder = L("createevent_location_placeholder")
        priceField.placeholder = L("createevent_price_placeholder")
        priceField.keyboardType = .decimalPad
        [titleField, descriptionField, locationField].forEach { $0.returnKeyType = .done }

        cityControl.insertSegment(withTitle: L("city_almaty"), at: 0, animated: false)
        cityControl.insertSegment(withTitle: L("city_astana"), at: 1, animated: false)
        cityControl.insertSegment(withTitle: L("city_shymkent"), at: 2, animated: false)
        cityControl.insertSegment(withTitle: L("city_aktobe"), at: 3, animated: false)
        cityControl.selectedSegmentIndex = 0

        categoryControl.insertSegment(withTitle: L("category_music"), at: 0, animated: false)
        categoryControl.insertSegment(withTitle: L("category_art"), at: 1, animated: false)
        categoryControl.insertSegment(withTitle: L("category_sport"), at: 2, animated: false)
        categoryControl.insertSegment(withTitle: L("category_food"), at: 3, animated: false)
        categoryControl.selectedSegmentIndex = 0

        freeLabel.text = L("event_free")
        freeLabel.textColor = .eventHubTextPrimary

        let freeStack = UIStackView(arrangedSubviews: [freeLabel, freeSwitch])
        freeStack.axis = .horizontal
        freeStack.spacing = 10

        createButton.setTitle(L("createevent_submit_button"), for: .normal)
        createButton.setTitleColor(.eventHubOnAccent, for: .normal)
        createButton.backgroundColor = .eventHubAccent
        createButton.layer.cornerRadius = 14
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.heightAnchor.constraint(equalToConstant: 52).isActive = true

        errorLabel.textColor = .eventHubError
        errorLabel.font = .systemFont(ofSize: 13)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        [coverPreviewView, swatchesScroll, dateRow, titleField, descriptionField, locationField,
         cityControl, categoryControl, priceField, freeStack, errorLabel, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48)
        ])

        selectCoverSwatch(id: EventCovers.templates[0].id)
    }
}
