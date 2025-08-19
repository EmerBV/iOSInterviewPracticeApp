//
//  BaseViewController.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
    }
    
    private func setupBaseUI() {
        view.backgroundColor = .systemBackground
        
        // Add back button behavior
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showError(_ error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
}
