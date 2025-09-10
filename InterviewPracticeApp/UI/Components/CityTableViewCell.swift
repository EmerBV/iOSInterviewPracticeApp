//
//  CityTableViewCell.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 20/8/25.
//

import UIKit

final class CityTableViewCell: UITableViewCell {
    
    static let identifier = "CityTableViewCell"
    
    // MARK: - UI Components
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var locationIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "location.fill"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cityLabel, countryLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure cell appearance
        backgroundColor = .systemBackground
        selectionStyle = .default
        
        contentView.addSubview(locationIconImageView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            // Icon constraints
            locationIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            locationIconImageView.widthAnchor.constraint(equalToConstant: 16),
            locationIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            // Stack view constraints
            stackView.leadingAnchor.constraint(equalTo: locationIconImageView.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
        
        // Ensure labels have proper content priorities
        cityLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        countryLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        cityLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        countryLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    // MARK: - Configuration
    func configure(with location: Location) {
        cityLabel.text = location.name
        
        // Build country text with region if available
        var countryText = location.country
        if !location.region.isEmpty && location.region != location.country {
            countryText = "\(location.region), \(location.country)"
        }
        countryLabel.text = countryText
        
        // Set accessibility
        accessibilityLabel = "\(location.name), \(countryText)"
        accessibilityTraits = .button
    }
    
    // MARK: - Cell Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        cityLabel.text = nil
        countryLabel.text = nil
    }
}
