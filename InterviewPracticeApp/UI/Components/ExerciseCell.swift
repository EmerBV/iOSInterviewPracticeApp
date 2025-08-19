//
//  ExerciseCell.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class ExerciseCell: UITableViewCell {
    
    static let identifier = "ExerciseCell"
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
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
    
    // MARK: - Setup
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(difficultyLabel)
        contentView.addSubview(tagsStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: difficultyLabel.leadingAnchor, constant: -8),
            
            difficultyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            difficultyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            difficultyLabel.widthAnchor.constraint(equalToConstant: 60),
            difficultyLabel.heightAnchor.constraint(equalToConstant: 24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            tagsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            tagsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagsStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -32),
            tagsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with exercise: Exercise) {
        titleLabel.text = exercise.title
        descriptionLabel.text = exercise.description
        
        difficultyLabel.text = exercise.difficulty.rawValue
        difficultyLabel.backgroundColor = exercise.difficulty.color.withAlphaComponent(0.2)
        difficultyLabel.textColor = exercise.difficulty.color
        
        // Clear previous tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new tags (limit to 3 for space)
        let tagsToShow = Array(exercise.tags.prefix(3))
        tagsToShow.forEach { tag in
            let tagLabel = createTagLabel(with: tag)
            tagsStackView.addArrangedSubview(tagLabel)
        }
    }
    
    private func createTagLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10)
        label.textColor = .systemBlue
        label.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        
        // Add padding
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            label.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return label
    }
}
