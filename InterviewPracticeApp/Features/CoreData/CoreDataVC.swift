//
//  CoreDataVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit
import Combine

final class CoreDataVC: BaseViewController {
    
    // MARK: - Properties
    private var viewModel: CoreDataVMProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskTapped)
        )
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No hay tareas\nToca + para agregar una nueva"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    init(viewModel: CoreDataVMProtocol = CoreDataVM()) {
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
        viewModel.loadTasks()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Core Data CRUD"
        navigationItem.rightBarButtonItem = addButton
        
        emptyStateView.addSubview(emptyStateLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupBindings() {
        viewModel.tasksPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks in
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.numberOfTasks() == 0
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    @objc private func addTaskTapped() {
        presentCreateTaskAlert()
    }
    
    private func presentCreateTaskAlert() {
        let alert = UIAlertController(
            title: "Nueva Tarea",
            message: "Ingresa los detalles de la tarea",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Título de la tarea"
            textField.autocapitalizationType = .sentences
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Descripción (opcional)"
            textField.autocapitalizationType = .sentences
        }
        
        let createAction = UIAlertAction(title: "Crear", style: .default) { [weak self] _ in
            guard let titleField = alert.textFields?[0],
                  let descriptionField = alert.textFields?[1],
                  let title = titleField.text, !title.isEmpty else {
                self?.showAlert(title: "Error", message: "El título es obligatorio")
                return
            }
            
            let description = descriptionField.text?.isEmpty == false ? descriptionField.text : nil
            self?.viewModel.createTask(title: title, description: description, dueDate: nil, priority: .medium)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension CoreDataVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTasks()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        
        let task = viewModel.task(at: indexPath.row)
        cell.configure(with: task)
        cell.onToggleCompletion = { [weak self] task in
            self?.viewModel.toggleTaskCompletion(task)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = viewModel.task(at: indexPath.row)
            viewModel.deleteTask(task)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
