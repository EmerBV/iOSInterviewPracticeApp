//
//  NetworkRequestVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit
import Combine

final class NetworkRequestVC: BaseViewController {
    
    // MARK: - Properties
    private var viewModel: NetworkVMProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Posts", "Users"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPostTapped)
        )
    }()
    
    // MARK: - Data
    private var posts: [Post] = []
    private var users: [User] = []
    private var isShowingPosts = true
    
    // MARK: - Initialization
    init(viewModel: NetworkVMProtocol = NetworkVM()) {
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
        viewModel.fetchPosts()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Network Requests"
        navigationItem.rightBarButtonItem = addButton
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.posts = posts
                if self?.isShowingPosts == true {
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.usersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.users = users
                if self?.isShowingPosts == false {
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
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
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        isShowingPosts = segmentedControl.selectedSegmentIndex == 0
        addButton.isEnabled = isShowingPosts
        
        if isShowingPosts && posts.isEmpty {
            viewModel.fetchPosts()
        } else if !isShowingPosts && users.isEmpty {
            viewModel.fetchUsers()
        }
        
        tableView.reloadData()
    }
    
    @objc private func refreshData() {
        if isShowingPosts {
            viewModel.fetchPosts()
        } else {
            viewModel.fetchUsers()
        }
    }
    
    @objc private func addPostTapped() {
        presentCreatePostAlert()
    }
    
    private func presentCreatePostAlert() {
        let alert = UIAlertController(
            title: "Crear Post",
            message: "Ingresa los datos del nuevo post",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Título"
            textField.autocapitalizationType = .sentences
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Contenido"
            textField.autocapitalizationType = .sentences
        }
        
        let createAction = UIAlertAction(title: "Crear", style: .default) { [weak self] _ in
            guard let titleField = alert.textFields?[0],
                  let bodyField = alert.textFields?[1],
                  let title = titleField.text, !title.isEmpty,
                  let body = bodyField.text, !body.isEmpty else {
                self?.showAlert(title: "Error", message: "Por favor completa todos los campos")
                return
            }
            
            self?.viewModel.createPost(title: title, body: body, userId: 1)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension NetworkRequestVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isShowingPosts ? posts.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowingPosts {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
                return UITableViewCell()
            }
            
            let post = posts[indexPath.row]
            cell.configure(with: post)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as? UserTableViewCell else {
                return UITableViewCell()
            }
            
            let user = users[indexPath.row]
            cell.configure(with: user)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isShowingPosts {
            let post = posts[indexPath.row]
            showAlert(title: post.title, message: post.body)
        } else {
            let user = users[indexPath.row]
            showAlert(title: user.name, message: "Email: \(user.email)\nTeléfono: \(user.phone)")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
