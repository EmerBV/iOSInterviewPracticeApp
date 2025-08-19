//
//  DocumentTableViewCell.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class DocumentTableViewCell: UITableViewCell {
    
    static let identifier = "DocumentTableViewCell"
    
    // MARK: - UI Components
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var difficultyLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var readingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tagsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - Setup
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(difficultyLabel)
        contentView.addSubview(readingTimeLabel)
        contentView.addSubview(tagsStackView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            difficultyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            difficultyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            difficultyLabel.widthAnchor.constraint(equalToConstant: 60),
            difficultyLabel.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: difficultyLabel.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            readingTimeLabel.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 4),
            readingTimeLabel.trailingAnchor.constraint(equalTo: difficultyLabel.trailingAnchor),
            
            tagsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            tagsStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            tagsStackView.trailingAnchor.constraint(lessThanOrEqualTo: readingTimeLabel.leadingAnchor, constant: -8),
            tagsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with document: InterviewDocument) {
        iconImageView.image = UIImage(systemName: document.category.icon)
        iconImageView.tintColor = document.category.color
        
        titleLabel.text = document.title
        descriptionLabel.text = document.description
        readingTimeLabel.text = "📖 \(document.estimatedReadingTime)"
        
        // Configure difficulty
        difficultyLabel.text = document.difficulty.rawValue
        difficultyLabel.backgroundColor = document.difficulty.color.withAlphaComponent(0.2)
        difficultyLabel.textColor = document.difficulty.color
        
        // Clear previous tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new tags (limit to 2 for space)
        let tagsToShow = Array(document.tags.prefix(2))
        tagsToShow.forEach { tag in
            let tagLabel = createTagLabel(with: tag, color: document.category.color)
            tagsStackView.addArrangedSubview(tagLabel)
        }
        
        // Configure accessibility
        accessibilityLabel = "\(document.title), \(document.difficulty.rawValue), tiempo de lectura \(document.estimatedReadingTime)"
    }
    
    private func createTagLabel(with text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10)
        label.textColor = color
        label.backgroundColor = color.withAlphaComponent(0.1)
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        
        // Add padding
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            label.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        return label
    }
}
