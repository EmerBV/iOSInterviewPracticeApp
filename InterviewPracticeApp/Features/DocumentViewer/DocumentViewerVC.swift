//
//  DocumentViewerVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit
import PDFKit
import Combine

final class DocumentViewerVC: BaseViewController {
    
    // MARK: - Properties
    private var viewModel: DocumentViewerVMProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DocumentTableViewCell.self, forCellReuseIdentifier: DocumentTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Buscar documentos..."
        return controller
    }()
    
    // MARK: - Initialization
    init(viewModel: DocumentViewerVMProtocol = DocumentViewerVM()) {
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
        viewModel.loadDocuments()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Documentos"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.documentsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - TableView DataSource & Delegate
extension DocumentViewerVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return DocumentCategory.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = DocumentCategory.allCases[section]
        return viewModel.numberOfDocuments(in: category)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DocumentCategory.allCases[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DocumentTableViewCell.identifier, for: indexPath) as? DocumentTableViewCell else {
            return UITableViewCell()
        }
        
        let category = DocumentCategory.allCases[indexPath.section]
        let document = viewModel.document(at: indexPath.row, in: category)
        cell.configure(with: document)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = DocumentCategory.allCases[indexPath.section]
        let document = viewModel.document(at: indexPath.row, in: category)
        
        let pdfViewController = PDFViewerVC(document: document)
        navigationController?.pushViewController(pdfViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Search Results Updating
extension DocumentViewerVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.searchDocuments(with: searchText)
    }
}
