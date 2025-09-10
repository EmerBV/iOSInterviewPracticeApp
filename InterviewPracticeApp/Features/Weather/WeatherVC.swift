//
//  WeatherVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 20/8/25.
//

import UIKit
import Combine

final class WeatherVC: BaseViewController {
    
    // MARK: - Properties
    private var viewModel: WeatherVM
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWeatherWithCombine), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: - Search Components
    private lazy var searchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Buscar ciudad..."
        textField.borderStyle = .none
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(searchTextChangedWithCombine), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var suggestionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CityTableViewCell.self, forCellReuseIdentifier: CityTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 12
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableView.layer.shadowRadius = 4
        tableView.layer.shadowOpacity = 0.1
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        
        // Configuración para altura automática
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Current Weather Components
    private lazy var currentWeatherCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48, weight: .thin)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var conditionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Details Components
    private lazy var detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Forecast Components
    private lazy var forecastLabel: UILabel = {
        let label = UILabel()
        label.text = "Pronóstico de 3 días"
        label.font = .boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var forecastStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Loading Components
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Data Properties
    private var debounceTimer: Timer?
    private var suggestionsHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    init(viewModel: WeatherVM = WeatherVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupGestures()
        setupScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add subtle animation on appear
        currentWeatherCard.alpha = 0.8
        UIView.animate(withDuration: 0.3) {
            self.currentWeatherCard.alpha = 1.0
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Clima"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add search components
        contentView.addSubview(searchContainerView)
        searchContainerView.addSubview(searchIconImageView)
        searchContainerView.addSubview(searchTextField)
        contentView.addSubview(suggestionsTableView)
        
        // Add current weather components
        contentView.addSubview(currentWeatherCard)
        currentWeatherCard.addSubview(locationLabel)
        currentWeatherCard.addSubview(weatherIconImageView)
        currentWeatherCard.addSubview(temperatureLabel)
        currentWeatherCard.addSubview(conditionLabel)
        currentWeatherCard.addSubview(detailsStackView)
        
        // Add forecast components
        contentView.addSubview(forecastLabel)
        contentView.addSubview(forecastStackView)
        
        // Add loading indicator
        view.addSubview(loadingIndicator)
        
        setupConstraints()
        setupDetailsView()
    }
    
    private func setupConstraints() {
        suggestionsHeightConstraint = suggestionsTableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Search container
            searchContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            searchContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            searchContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Search icon
            searchIconImageView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 16),
            searchIconImageView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Search text field
            searchTextField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 12),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -16),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            
            // Suggestions table view
            suggestionsTableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 8),
            suggestionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            suggestionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            suggestionsHeightConstraint,
            
            // Current weather card
            currentWeatherCard.topAnchor.constraint(equalTo: suggestionsTableView.bottomAnchor, constant: 24),
            currentWeatherCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            currentWeatherCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Location label
            locationLabel.topAnchor.constraint(equalTo: currentWeatherCard.topAnchor, constant: 24),
            locationLabel.leadingAnchor.constraint(equalTo: currentWeatherCard.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: currentWeatherCard.trailingAnchor, constant: -16),
            
            // Weather icon
            weatherIconImageView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            weatherIconImageView.centerXAnchor.constraint(equalTo: currentWeatherCard.centerXAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 80),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Temperature label
            temperatureLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor, constant: 16),
            temperatureLabel.leadingAnchor.constraint(equalTo: currentWeatherCard.leadingAnchor, constant: 16),
            temperatureLabel.trailingAnchor.constraint(equalTo: currentWeatherCard.trailingAnchor, constant: -16),
            
            // Condition label
            conditionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
            conditionLabel.leadingAnchor.constraint(equalTo: currentWeatherCard.leadingAnchor, constant: 16),
            conditionLabel.trailingAnchor.constraint(equalTo: currentWeatherCard.trailingAnchor, constant: -16),
            
            // Details stack view
            detailsStackView.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 24),
            detailsStackView.leadingAnchor.constraint(equalTo: currentWeatherCard.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: currentWeatherCard.trailingAnchor, constant: -16),
            detailsStackView.bottomAnchor.constraint(equalTo: currentWeatherCard.bottomAnchor, constant: -24),
            
            // Forecast label
            forecastLabel.topAnchor.constraint(equalTo: currentWeatherCard.bottomAnchor, constant: 32),
            forecastLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            forecastLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Forecast stack view
            forecastStackView.topAnchor.constraint(equalTo: forecastLabel.bottomAnchor, constant: 16),
            forecastStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            forecastStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            forecastStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupDetailsView() {
        let feelsLikeView = createDetailView(title: "Sensación térmica", value: "--°", icon: "thermometer")
        let windView = createDetailView(title: "Viento", value: "--", icon: "wind")
        let humidityView = createDetailView(title: "Humedad", value: "--%", icon: "humidity")
        
        detailsStackView.addArrangedSubview(feelsLikeView)
        detailsStackView.addArrangedSubview(windView)
        detailsStackView.addArrangedSubview(humidityView)
    }
    
    private func createDetailView(title: String, value: String, icon: String) -> UIView {
        let containerView = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: 16)
        valueLabel.textAlignment = .center
        valueLabel.accessibilityIdentifier = title
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func setupBindings() {
        print("🔗 Setting up bindings...")
        
        // Current weather binding - ENHANCED
        viewModel.currentWeatherPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weather in
                print("🌤️ Weather data received in binding: \(weather?.location.name ?? "nil")")
                self?.updateWeatherUI(weather)
                self?.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        // Loading state binding
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                print("⏳ Loading state changed: \(isLoading)")
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        // Error binding
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                print("❌ Error received: \(errorMessage)")
                self?.handleError(errorMessage)
            }
            .store(in: &cancellables)
        
        // City suggestions binding
        viewModel.citySuggestionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] suggestions in
                print("📝 Suggestions updated: \(suggestions.count) items")
                self?.updateSuggestions(suggestions)
            }
            .store(in: &cancellables)
        
        // Selected city binding - ENHANCED
        viewModel.selectedCityPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] city in
                print("🏙️ Selected city changed in VM: \(city)")
                self?.handleCitySelection(city)
            }
            .store(in: &cancellables)
        
        print("✅ All bindings set up successfully")
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup methods need to include refresh control
    private func setupScrollView() {
        // Add refresh control to scroll view
        scrollView.refreshControl = refreshControl
        
        // Configure scroll view
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        hideSuggestions()
    }
    
    private func hideSuggestions() {
        showSuggestions(false)
    }
    
    private func updateSuggestions(_ suggestions: [Location]) {
        print("📝 Updating suggestions with \(suggestions.count) items")
        suggestionsTableView.reloadData()
        
        let shouldShow = !suggestions.isEmpty && searchTextField.isFirstResponder
        showSuggestions(shouldShow)
    }
    
    private func showSuggestions(_ show: Bool) {
        let suggestions = viewModel.citySuggestions.count
        
        var height: CGFloat = 0
        if show && suggestions > 0 {
            // Calcular altura basada en el contenido estimado por celda
            let estimatedCellHeight: CGFloat = 60
            let maxVisibleCells = 4 // Máximo de celdas visibles sin scroll
            let visibleCells = min(suggestions, maxVisibleCells)
            height = CGFloat(visibleCells) * estimatedCellHeight
            
            // Altura máxima para evitar que ocupe toda la pantalla
            let maxHeight: CGFloat = 240
            height = min(height, maxHeight)
            
            // Habilitar scroll si hay más elementos de los visibles
            suggestionsTableView.isScrollEnabled = suggestions > maxVisibleCells
        } else {
            suggestionsTableView.isScrollEnabled = false
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.suggestionsHeightConstraint.constant = height
            self.suggestionsTableView.isHidden = !show
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateDetailValue(title: String, value: String) {
        for subview in detailsStackView.arrangedSubviews {
            for view in subview.subviews {
                if let label = view as? UILabel,
                   label.accessibilityIdentifier == title {
                    label.text = value
                }
            }
        }
    }
    
    private func updateForecast(_ forecastDays: [ForecastDay]) {
        // Clear existing forecast views
        forecastStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for day in forecastDays {
            let forecastView = createForecastView(for: day)
            forecastStackView.addArrangedSubview(forecastView)
        }
    }
    
    private func createForecastView(for day: ForecastDay) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOpacity = 0.1
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        dateLabel.text = formattedDate(from: day.date)
        dateLabel.font = .boldSystemFont(ofSize: 16)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        let iconName = weatherIcon(for: day.day.condition)
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let conditionLabel = UILabel()
        conditionLabel.text = day.day.condition.text
        conditionLabel.font = .systemFont(ofSize: 14)
        conditionLabel.textColor = .secondaryLabel
        conditionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let temperatureLabel = UILabel()
        temperatureLabel.text = temperatureRange(for: day)
        temperatureLabel.font = .boldSystemFont(ofSize: 18)
        temperatureLabel.textAlignment = .right
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(dateLabel)
        containerView.addSubview(iconImageView)
        containerView.addSubview(conditionLabel)
        containerView.addSubview(temperatureLabel)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 80),
            
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            dateLabel.widthAnchor.constraint(equalToConstant: 100),
            
            iconImageView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            conditionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            conditionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            conditionLabel.trailingAnchor.constraint(lessThanOrEqualTo: temperatureLabel.leadingAnchor, constant: -16),
            
            temperatureLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            temperatureLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            temperatureLabel.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        return containerView
    }
    
    // MARK: - Helper Methods
    private func weatherIcon(for condition: WeatherCondition) -> String {
        switch condition.code {
        case 1000: // Clear/Sunny
            return "sun.max.fill"
        case 1003: // Partly cloudy
            return "cloud.sun.fill"
        case 1006, 1009: // Cloudy/Overcast
            return "cloud.fill"
        case 1030, 1135, 1147: // Fog/Mist
            return "cloud.fog.fill"
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246: // Rain
            return "cloud.rain.fill"
        case 1066, 1069, 1072, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1237, 1249, 1252, 1255, 1258, 1261, 1264: // Snow
            return "cloud.snow.fill"
        case 1087, 1273, 1276, 1279, 1282: // Thunder
            return "cloud.bolt.rain.fill"
        default:
            return "cloud.fill"
        }
    }
    
    private func formattedDate(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "EEEE"
            dateFormatter.locale = Locale(identifier: "es_ES")
            return dateFormatter.string(from: date).capitalized
        }
        
        return dateString
    }
    
    private func temperatureRange(for day: ForecastDay) -> String {
        return "\(Int(day.day.maxtempC ?? 0))° / \(Int(day.day.mintempC ?? 0))°"
    }
}

extension WeatherVC {
    // MARK: - Actions Async/Await
    @objc private func refreshWeather() {
        Task {
            await viewModel.refreshWeather()
        }
        Utils.hapticFeedback(.light)
    }
    
    @objc private func searchTextChanged() {
        guard let query = searchTextField.text else { return }
        
        Task {
            await viewModel.searchCities(query: query)
        }
    }
}

extension WeatherVC {
    // En WeatherVC, usar solo Combine methods:
    @objc private func refreshWeatherWithCombine() {
        print("🔄 Manual refresh triggered")
        Utils.hapticFeedback(.light)
        
        // Ensure we have a city to refresh
        let cityToRefresh = viewModel.selectedCity
        print("🏙️ Refreshing weather for: \(cityToRefresh)")
        
        // Call the refresh method
        viewModel.refreshWeatherWithCombine()
    }
    
    /*
     @objc private func searchTextChangedWithCombine() {
     guard let query = searchTextField.text else { return }
     viewModel.searchCitiesWithCombine(query: query)
     }
     */
    
    @objc private func searchTextChangedWithCombine() {
        guard let query = searchTextField.text else { return }
        
        // Cancelar timer anterior
        debounceTimer?.invalidate()
        
        // Crear nuevo timer con debounce
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.viewModel.searchCitiesWithCombine(query: query)
        }
    }
}

extension WeatherVC {
    // MARK: - Helper Methods for Better Organization
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
        }
    }
    
    private func handleError(_ errorMessage: String) {
        showAlert(title: "Error", message: errorMessage)
        refreshControl.endRefreshing()
    }
    
    private func handleCitySelection(_ city: String) {
        // Only update search field if it's not already updated
        if searchTextField.text != city {
            searchTextField.text = city
        }
        
        // Always hide suggestions when city is selected
        hideSuggestions()
        
        // Log for debugging
        print("🏙️ Ciudad seleccionada y actualizada en VM: \(city)")
        
        // Force UI refresh if needed - this ensures the weather data updates
        if let currentWeather = viewModel.currentWeather {
            print("🔄 Forcing UI update with current weather data")
            updateWeatherUI(currentWeather)
        }
    }
    
    // MARK: - UI Updates
    private func updateWeatherUI(_ weather: WeatherResponse?) {
        print("🎨 Updating weather UI...")
        
        guard let weather = weather else {
            print("⚠️ No weather data available, resetting UI")
            resetWeatherUI()
            return
        }
        
        // Log the data we're about to display
        print("📍 Location: \(weather.location.name), \(weather.location.country)")
        print("🌡️ Temperature: \(weather.current.tempC?.description ?? "nil")°C")
        print("☁️ Condition: \(weather.current.condition.text)")
        
        // Update basic weather info
        locationLabel.text = "\(weather.location.name), \(weather.location.country)"
        
        // Ensure temperature display is correct
        if let tempC = weather.current.tempC {
            temperatureLabel.text = "\(Int(tempC))°C"
        } else {
            temperatureLabel.text = "--°C"
        }
        
        conditionLabel.text = weather.current.condition.text
        
        // Update weather icon
        let iconName = weatherIcon(for: weather.current.condition)
        weatherIconImageView.image = UIImage(systemName: iconName)
        
        // Update details with null safety
        updateDetailValue(title: "Sensación térmica", value: "\(Int(weather.current.feelslikeC ?? 0))°C")
        updateDetailValue(title: "Viento", value: "\(Int(weather.current.windKph ?? 0)) km/h")
        updateDetailValue(title: "Humedad", value: "\(weather.current.humidity)%")
        
        // Update forecast
        updateForecast(weather.forecastDays)
        
        print("✅ Weather UI updated successfully")
    }
    
    // MARK: - UI Reset Method
    private func resetWeatherUI() {
        print("🔄 Resetting weather UI to default state")
        locationLabel.text = "Ubicación no disponible"
        temperatureLabel.text = "--°"
        conditionLabel.text = "Sin datos"
        weatherIconImageView.image = UIImage(systemName: "questionmark.circle")
        updateDetailValue(title: "Sensación térmica", value: "--°")
        updateDetailValue(title: "Viento", value: "--")
        updateDetailValue(title: "Humedad", value: "--%")
        updateForecast([])
    }
}

extension WeatherVC: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // This helps with refresh control responsiveness
        if refreshControl.isRefreshing {
            print("🔄 Refresh control is active")
        }
    }
}

// MARK: - UITextFieldDelegate
extension WeatherVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // If there's text, search for the first suggestion or fetch directly
        if let text = textField.text, !text.isEmpty {
            if !viewModel.citySuggestions.isEmpty {
                // Select first suggestion
                let firstCity = viewModel.citySuggestions[0]
                viewModel.selectCityAndFetchWeather(firstCity.name)
            } else {
                // Try to fetch directly
                viewModel.selectCityAndFetchWeather(text)
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Show suggestions if there's existing text
        if let text = textField.text, !text.isEmpty {
            viewModel.searchCitiesWithCombine(query: text)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Auto-hide suggestions when editing ends
        hideSuggestions()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension WeatherVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.citySuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CityTableViewCell.identifier,
            for: indexPath
        ) as? CityTableViewCell else {
            return UITableViewCell()
        }
        
        let location = viewModel.citySuggestions[indexPath.row]
        cell.configure(with: location)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let location = viewModel.citySuggestions[indexPath.row]
        
        // Dismiss keyboard immediately
        searchTextField.resignFirstResponder()
        
        // FIXED: Use the full location name for better results
        // Create a more complete query that includes the location info
        let fullLocationName = "\(location.name), \(location.region), \(location.country)"
        
        // Update search field immediately to show selection
        searchTextField.text = location.name
        
        // Hide suggestions immediately
        hideSuggestions()
        
        // Use the location name for the API call (this is what the API expects)
        viewModel.selectCityAndFetchWeather(location.name)
        
        // Provide haptic feedback
        Utils.hapticFeedback(.light)
        
        // Add logging for debugging
        print("🏙️ Selected location: \(location.name)")
        print("📍 Full location details: \(fullLocationName)")
        print("🌐 Coordinates: \(location.lat), \(location.lon)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Cambiar de altura fija a altura automática
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Proporcionar una estimación para mejor rendimiento
        return 60
    }
}
