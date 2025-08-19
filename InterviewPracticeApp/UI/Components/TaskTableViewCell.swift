//
//  TaskTableViewCell.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class TaskTableViewCell: UITableViewCell {
    
    static let identifier = "TaskTableViewCell"
    
    // MARK: - Properties
    var onToggleCompletion: ((TaskEntity) -> Void)?
    private var task: TaskEntity?
    
    // MARK: - UI Components
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
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        task = nil
        onToggleCompletion = nil
        titleLabel.attributedText = nil
        descriptionLabel.text = nil
        checkboxButton.isSelected = false
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(priorityLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            priorityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            priorityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priorityLabel.widthAnchor.constraint(equalToConstant: 60),
            priorityLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: priorityLabel.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Actions
    @objc private func checkboxTapped() {
        guard let task = task else { return }
        onToggleCompletion?(task)
    }
    
    // MARK: - Configuration
    func configure(with task: TaskEntity) {
        self.task = task
        
        // Configure checkbox
        checkboxButton.isSelected = task.isCompleted
        
        // Configure title with strikethrough if completed
        if task.isCompleted {
            let attributedString = NSAttributedString(
                string: task.title ?? "Sin título",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
            titleLabel.attributedText = attributedString
        } else {
            titleLabel.text = task.title
            titleLabel.textColor = .label
        }
        
        // Configure description
        if let description = task.taskDescription, !description.isEmpty {
            descriptionLabel.text = description
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        
        // Configure priority
        let priority = TaskEntityPriority(rawValue: task.priority) ?? .medium
        priorityLabel.text = priority.title
        priorityLabel.backgroundColor = priority.color.withAlphaComponent(0.2)
        priorityLabel.textColor = priority.color
        
        // Configure date
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        dateLabel.text = "Creada: \(formatter.string(from: task.createdAt ?? Date()))"
        
        // Configure accessibility
        accessibilityLabel = "\(task.title), \(task.isCompleted ? "completada" : "pendiente"), prioridad \(priority.title)"
    }
}
