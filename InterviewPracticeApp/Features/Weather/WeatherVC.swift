//
//  WeatherVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 20/8/25.
//

import UIKit
import Combine

/*
 final class WeatherVC: BaseViewController {
 
 // MARK: - Properties
 private var viewModel: WeatherVMProtocol
 private var cancellables = Set<AnyCancellable>()
 
 // MARK: - UI Components
 private lazy var scrollView: UIScrollView = {
 let scrollView = UIScrollView()
 scrollView.translatesAutoresizingMaskIntoConstraints = false
 scrollView.refreshControl = refreshControl
 scrollView.showsVerticalScrollIndicator = false
 return scrollView
 }()
 
 private lazy var contentView: UIView = {
 let view = UIView()
 view.translatesAutoresizingMaskIntoConstraints = false
 return view
 }()
 
 private lazy var refreshControl: UIRefreshControl = {
 let control = UIRefreshControl()
 control.addTarget(self, action: #selector(refreshWeather), for: .valueChanged)
 return control
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
 
 private lazy var searchTextField: UITextField = {
 let textField = UITextField()
 textField.placeholder = "Buscar ciudad..."
 textField.borderStyle = .none
 textField.delegate = self
 textField.clearButtonMode = .whileEditing
 textField.returnKeyType = .search
 textField.autocapitalizationType = .words
 textField.autocorrectionType = .no
 textField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
 textField.translatesAutoresizingMaskIntoConstraints = false
 return textField
 }()
 
 private lazy var searchIconImageView: UIImageView = {
 let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
 imageView.tintColor = .systemGray
 imageView.contentMode = .scaleAspectFit
 imageView.translatesAutoresizingMaskIntoConstraints = false
 return imageView
 }()
 
 private lazy var suggestionsTableView: UITableView = {
 let tableView = UITableView()
 tableView.delegate = self
 tableView.dataSource = self
 tableView.register(CityTableViewCell.self, forCellReuseIdentifier: CityTableViewCell.identifier)
 tableView.layer.cornerRadius = 12
 tableView.layer.masksToBounds = true
 tableView.isHidden = true
 tableView.translatesAutoresizingMaskIntoConstraints = false
 return tableView
 }()
 
 // MARK: - Current Weather Components
 private lazy var currentWeatherCard: UIView = {
 let view = UIView()
 view.backgroundColor = .systemBackground
 view.layer.cornerRadius = 16
 view.layer.shadowColor = UIColor.black.cgColor
 view.layer.shadowOffset = CGSize(width: 0, height: 2)
 view.layer.shadowRadius = 8
 view.layer.shadowOpacity = 0.1
 view.translatesAutoresizingMaskIntoConstraints = false
 return view
 }()
 
 private lazy var locationLabel: UILabel = {
 let label = UILabel()
 label.font = .boldSystemFont(ofSize: 24)
 label.textAlignment = .center
 label.numberOfLines = 2
 label.translatesAutoresizingMaskIntoConstraints = false
 return label
 }()
 
 private lazy var temperatureLabel: UILabel = {
 let label = UILabel()
 label.font = .systemFont(ofSize: 72, weight: .thin)
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
 
 // MARK: - Data
 private var citySuggestions: [Location] = []
 private var suggestionsHeightConstraint: NSLayoutConstraint!
 
 // MARK: - Initialization
 init(viewModel: WeatherVMProtocol = WeatherVM()) {
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
 suggestionsTableView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
 suggestionsTableView.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
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
 temperatureLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor, constant: 8),
 temperatureLabel.centerXAnchor.constraint(equalTo: currentWeatherCard.centerXAnchor),
 
 // Condition label
 conditionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
 conditionLabel.centerXAnchor.constraint(equalTo: currentWeatherCard.centerXAnchor),
 
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
 let humidityView = createDetailView(icon: "humidity.fill", title: "Humedad", value: "--")
 let windView = createDetailView(icon: "wind", title: "Viento", value: "--")
 let uvView = createDetailView(icon: "sun.max.fill", title: "UV", value: "--")
 let pressureView = createDetailView(icon: "barometer", title: "Presión", value: "--")
 
 detailsStackView.addArrangedSubview(humidityView)
 detailsStackView.addArrangedSubview(windView)
 detailsStackView.addArrangedSubview(uvView)
 detailsStackView.addArrangedSubview(pressureView)
 }
 
 private func createDetailView(icon: String, title: String, value: String) -> UIView {
 let containerView = UIView()
 
 let iconImageView = UIImageView(image: UIImage(systemName: icon))
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
 
 // Store reference for updating
 valueLabel.accessibilityIdentifier = title
 
 return containerView
 }
 
 private func setupBindings() {
 // Weather data binding
 viewModel.currentWeatherPublisher
 .receive(on: DispatchQueue.main)
 .sink { [weak self] weather in
 self?.updateWeatherUI(weather)
 self?.refreshControl.endRefreshing()
 }
 .store(in: &cancellables)
 
 // Loading state binding
 viewModel.isLoadingPublisher
 .receive(on: DispatchQueue.main)
 .sink { [weak self] isLoading in
 if isLoading {
 self?.loadingIndicator.startAnimating()
 } else {
 self?.loadingIndicator.stopAnimating()
 self?.refreshControl.endRefreshing()
 }
 }
 .store(in: &cancellables)
 
 // Error handling
 viewModel.errorPublisher
 .receive(on: DispatchQueue.main)
 .sink { [weak self] error in
 self?.showError(error)
 self?.refreshControl.endRefreshing()
 }
 .store(in: &cancellables)
 
 // City suggestions binding
 viewModel.citySuggestionsPublisher
 .receive(on: DispatchQueue.main)
 .sink { [weak self] suggestions in
 self?.updateSuggestions(suggestions)
 }
 .store(in: &cancellables)
 }
 
 private func setupGestures() {
 let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
 tapGesture.cancelsTouchesInView = false
 view.addGestureRecognizer(tapGesture)
 }
 
 // MARK: - Actions
 @objc private func refreshWeather() {
 viewModel.refreshWeather()
 Utils.hapticFeedback(.light)
 }
 
 @objc private func searchTextChanged() {
 guard let text = searchTextField.text else { return }
 viewModel.searchCities(query: text)
 }
 
 @objc private func dismissKeyboard() {
 view.endEditing(true)
 hideSuggestions()
 }
 
 // MARK: - UI Updates
 private func updateWeatherUI(_ weather: WeatherResponse?) {
 guard let weather = weather else {
 resetWeatherUI()
 return
 }
 
 // Update main information
 locationLabel.text = "\(weather.location.name), \(weather.location.country)"
 temperatureLabel.text = "\(Int(weather.current.tempC))°"
 conditionLabel.text = weather.current.condition.text
 
 // Update weather icon
 let iconName = (viewModel as? WeatherVM)?.weatherIcon(for: weather.current.condition) ?? "sun.max.fill"
 weatherIconImageView.image = UIImage(systemName: iconName)
 
 // Update details
 updateDetailValue(for: "Humedad", value: "\(weather.current.humidity)%")
 updateDetailValue(for: "Viento", value: "\(Int(weather.current.windKph)) km/h")
 updateDetailValue(for: "UV", value: "\(Int(weather.current.uv))")
 updateDetailValue(for: "Presión", value: "\(Int(weather.current.pressureMb)) mb")
 
 // Update forecast
 updateForecast(weather.forecast.forecastday)
 
 // Add subtle animation
 UIView.animate(withDuration: 0.3) {
 self.currentWeatherCard.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
 } completion: { _ in
 UIView.animate(withDuration: 0.3) {
 self.currentWeatherCard.transform = .identity
 }
 }
 }
 
 private func resetWeatherUI() {
 locationLabel.text = "Ubicación"
 temperatureLabel.text = "--°"
 conditionLabel.text = "Cargando..."
 weatherIconImageView.image = UIImage(systemName: "cloud.fill")
 
 updateDetailValue(for: "Humedad", value: "--")
 updateDetailValue(for: "Viento", value: "--")
 updateDetailValue(for: "UV", value: "--")
 updateDetailValue(for: "Presión", value: "--")
 
 forecastStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
 }
 
 private func updateDetailValue(for title: String, value: String) {
 detailsStackView.arrangedSubviews.forEach { containerView in
 containerView.subviews.forEach { subview in
 if let label = subview as? UILabel,
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
 
 let dateLabel = UILabel()
 dateLabel.text = (viewModel as? WeatherVM)?.formattedDate(from: day.date) ?? day.date
 dateLabel.font = .boldSystemFont(ofSize: 16)
 dateLabel.translatesAutoresizingMaskIntoConstraints = false
 
 let iconImageView = UIImageView()
 let iconName = (viewModel as? WeatherVM)?.weatherIcon(for: day.day.condition) ?? "sun.max.fill"
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
 temperatureLabel.text = (viewModel as? WeatherVM)?.temperatureRange(for: day) ?? ""
 temperatureLabel.font = .boldSystemFont(ofSize: 16)
 temperatureLabel.textAlignment = .right
 temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
 
 containerView.addSubview(dateLabel)
 containerView.addSubview(iconImageView)
 containerView.addSubview(conditionLabel)
 containerView.addSubview(temperatureLabel)
 
 NSLayoutConstraint.activate([
 containerView.heightAnchor.constraint(equalToConstant: 80),
 
 dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
 dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
 
 iconImageView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 16),
 iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
 iconImageView.widthAnchor.constraint(equalToConstant: 32),
 iconImageView.heightAnchor.constraint(equalToConstant: 32),
 
 conditionLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
 conditionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
 conditionLabel.trailingAnchor.constraint(lessThanOrEqualTo: temperatureLabel.leadingAnchor, constant: -8),
 
 temperatureLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
 temperatureLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
 ])
 
 return containerView
 }
 
 private func updateSuggestions(_ suggestions: [Location]) {
 citySuggestions = suggestions
 suggestionsTableView.reloadData()
 
 let shouldShow = !suggestions.isEmpty && searchTextField.isFirstResponder
 showSuggestions(shouldShow)
 }
 
 private func showSuggestions(_ show: Bool) {
 let height: CGFloat = show ? min(CGFloat(citySuggestions.count * 44), 200) : 0
 
 UIView.animate(withDuration: 0.3) {
 self.suggestionsHeightConstraint.constant = height
 self.suggestionsTableView.isHidden = !show
 self.view.layoutIfNeeded()
 }
 }
 
 private func hideSuggestions() {
 showSuggestions(false)
 }
 }
 
 // MARK: - UITextField Delegate
 extension WeatherVC: UITextFieldDelegate {
 
 func textFieldDidBeginEditing(_ textField: UITextField) {
 if !citySuggestions.isEmpty {
 showSuggestions(true)
 }
 }
 
 func textFieldDidEndEditing(_ textField: UITextField) {
 // Delay hiding suggestions to allow table view selection
 DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
 self.hideSuggestions()
 }
 }
 
 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
 guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
 !text.isEmpty else {
 return false
 }
 
 viewModel.selectCity(text)
 textField.resignFirstResponder()
 textField.text = ""
 hideSuggestions()
 
 return true
 }
 }
 
 // MARK: - UITableView DataSource & Delegate
 extension WeatherVC: UITableViewDataSource, UITableViewDelegate {
 
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return citySuggestions.count
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 guard let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.identifier, for: indexPath) as? CityTableViewCell else {
 return UITableViewCell()
 }
 
 let city = citySuggestions[indexPath.row]
 cell.configure(with: city)
 return cell
 }
 
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 tableView.deselectRow(at: indexPath, animated: true)
 
 let selectedCity = citySuggestions[indexPath.row]
 viewModel.selectCity(selectedCity.name)
 searchTextField.text = ""
 searchTextField.resignFirstResponder()
 hideSuggestions()
 
 Utils.hapticFeedback(.light)
 }
 
 func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 return 44
 }
 }
 */

final class WeatherVC: BaseViewController {
    
    // MARK: - Properties
    private var viewModel: WeatherVM
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.refreshControl = refreshControl
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshWeather), for: .valueChanged)
        return control
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
        textField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var suggestionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 12
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableView.layer.shadowRadius = 4
        tableView.layer.shadowOpacity = 0.1
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")
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
        // Current weather binding
        viewModel.currentWeatherPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weather in
                self?.updateWeatherUI(weather)
            }
            .store(in: &cancellables)
        
        // Loading state binding
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        // City suggestions binding
        viewModel.citySuggestionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] suggestions in
                self?.updateSuggestions(suggestions)
            }
            .store(in: &cancellables)
        
        // Error binding
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 } // Solo procesar errores no nil
            .sink { [weak self] errorMessage in
                self?.showAlert(title: "Error", message: errorMessage)
            }
            .store(in: &cancellables)
        
        // Selected city binding
        viewModel.selectedCityPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] city in
                // Update UI if needed when city changes
            }
            .store(in: &cancellables)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    /*
    @objc private func refreshWeather() {
        Task {
            await viewModel.refreshWeather()
        }
    }
    
    @objc private func searchTextChanged() {
        guard let query = searchTextField.text else { return }
        
        Task {
            await viewModel.searchCities(query: query)
        }
    }
     */
    
    // En WeatherVC, usar solo Combine methods:
    @objc private func refreshWeather() {
        viewModel.fetchForecastWithCombine(for: viewModel.selectedCity)
    }

    @objc private func searchTextChanged() {
        guard let query = searchTextField.text else { return }
        viewModel.searchCitiesWithCombine(query: query)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        suggestionsHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - UI Updates
    private func updateWeatherUI(_ weather: WeatherResponse?) {
        guard let weather = weather else {
            // Reset UI to default state
            locationLabel.text = "Ubicación no disponible"
            temperatureLabel.text = "--°"
            conditionLabel.text = "Sin datos"
            weatherIconImageView.image = UIImage(systemName: "questionmark.circle")
            updateDetailValue(title: "Sensación térmica", value: "--°")
            updateDetailValue(title: "Viento", value: "--")
            updateDetailValue(title: "Humedad", value: "--%")
            updateForecast([])
            return
        }
        
        // Update basic weather info
        locationLabel.text = "\(weather.location.name), \(weather.location.country)"
        temperatureLabel.text = "\(Int(weather.current.tempC ?? 0))°C"
        conditionLabel.text = weather.current.condition.text
        
        // Update weather icon
        let iconName = weatherIcon(for: weather.current.condition)
        weatherIconImageView.image = UIImage(systemName: iconName)
        
        // Update details
        updateDetailValue(title: "Sensación térmica", value: "\(Int(weather.current.feelslikeC ?? 0)) °C")
        updateDetailValue(title: "Viento", value: "\(Int(weather.current.windKph ?? 0)) km/h")
        updateDetailValue(title: "Humedad", value: "\(Int(weather.current.humidity ?? 0)) %")
        
        // Update forecast
        updateForecast(weather.forecastDays)
    }
    
    private func updateSuggestions(_ suggestions: [Location]) {
        let height = min(CGFloat(suggestions.count * 44), 200)
        suggestionsHeightConstraint.constant = height
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        suggestionsTableView.reloadData()
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
    
    // MARK: - UI Reset Method
    private func resetWeatherUI() {
        locationLabel.text = "Ubicación no disponible"
        temperatureLabel.text = "--°"
        conditionLabel.text = "Sin datos"
        weatherIconImageView.image = UIImage(systemName: "questionmark.circle")
        updateDetailValue(title: "Sensación térmica", value: "--°")
        updateDetailValue(title: "Viento", value: "--")
        updateDetailValue(title: "Humedad", value: "--%")
        updateForecast([])
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

// MARK: - UITextFieldDelegate
extension WeatherVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Show suggestions if there's text
        if let text = textField.text, !text.isEmpty {
            Task {
                await viewModel.searchCities(query: text)
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension WeatherVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.citySuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        let location = viewModel.citySuggestions[indexPath.row]
        
        cell.textLabel?.text = "\(location.name), \(location.country)"
        cell.detailTextLabel?.text = location.region
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let location = viewModel.citySuggestions[indexPath.row]
        searchTextField.text = location.name
        searchTextField.resignFirstResponder()
        
        // Hide suggestions
        suggestionsHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        // Fetch weather for selected city
        Task {
            await viewModel.selectCity(location.name)
        }
    }
     */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let location = viewModel.citySuggestions[indexPath.row]
        searchTextField.text = location.name
        searchTextField.resignFirstResponder()
        
        // Hide suggestions
        suggestionsHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        // Fetch weather for selected city using Combine
        viewModel.selectedCity = location.name
        viewModel.fetchForecastWithCombine(for: location.name)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
