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
        label.numberOfLines = 0 // Permitir múltiples líneas
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0 // Cambiar de 0 a ilimitado para mejor adaptación
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
        // Añadir resistencia a la compresión para evitar que se corte
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var tagsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillProportionally
        stackView.alignment = .leading
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
        // Limpiar tags anteriores
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - Setup
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(difficultyLabel)
        contentView.addSubview(tagsStackView)
        
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: difficultyLabel.leadingAnchor, constant: -12),
            
            // Difficulty label constraints - posición fija en la esquina superior derecha
            difficultyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            difficultyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -44), // Espacio para disclosure indicator
            difficultyLabel.widthAnchor.constraint(equalToConstant: 60),
            difficultyLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Description label constraints
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -44), // Espacio para disclosure indicator
            
            // Tags stack view constraints
            tagsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            tagsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagsStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -44),
            tagsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        // Configurar prioridades de content hugging y compression resistance
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        tagsStackView.setContentHuggingPriority(.required, for: .vertical)
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        tagsStackView.setContentCompressionResistancePriority(.required, for: .vertical)
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
        
        // Add new tags (limit to 3 for space but make them more compact)
        let tagsToShow = Array(exercise.tags.prefix(3))
        tagsToShow.forEach { tag in
            let tagLabel = createTagLabel(with: tag)
            tagsStackView.addArrangedSubview(tagLabel)
        }
        
        // Si hay más tags, añadir indicador
        if exercise.tags.count > 3 {
            let moreLabel = createMoreTagsLabel(count: exercise.tags.count - 3)
            tagsStackView.addArrangedSubview(moreLabel)
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
        
        // Configurar padding interno usando attributed string para un mejor control
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Configurar prioridades para que se mantenga compacto
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 20),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 35)
        ])
        
        return label
    }
    
    private func createMoreTagsLabel(count: Int) -> UILabel {
        let label = UILabel()
        label.text = "+\(count)"
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .tertiaryLabel
        label.backgroundColor = .systemGray5
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 20),
            label.widthAnchor.constraint(equalToConstant: 25)
        ])
        
        return label
    }
}
