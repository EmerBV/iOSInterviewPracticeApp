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
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
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
        contentView.addSubview(locationIconImageView)
        contentView.addSubview(cityLabel)
        contentView.addSubview(countryLabel)
        
        NSLayoutConstraint.activate([
            locationIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            locationIconImageView.widthAnchor.constraint(equalToConstant: 16),
            locationIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            cityLabel.leadingAnchor.constraint(equalTo: locationIconImageView.trailingAnchor, constant: 12),
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            countryLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),
            countryLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 2),
            countryLabel.trailingAnchor.constraint(equalTo: cityLabel.trailingAnchor),
            countryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with location: Location) {
        cityLabel.text = location.name
        
        var countryText = location.country
        if !location.region.isEmpty && location.region != location.country {
            countryText = "\(location.region), \(location.country)"
        }
        countryLabel.text = countryText
    }
}
