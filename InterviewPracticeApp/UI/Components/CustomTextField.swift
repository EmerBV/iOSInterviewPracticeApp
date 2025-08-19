//
//  CustomTextField.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

// MARK: - Custom TextField Delegate
protocol CustomTextFieldDelegate: AnyObject {
    func textFieldDidStartEditing(_ textField: CustomTextField)
    func textFieldDidChange(_ textField: CustomTextField, text: String)
    func textFieldDidEndEditing(_ textField: CustomTextField)
    func textFieldShouldReturn(_ textField: CustomTextField) -> Bool
}

// MARK: - Custom TextField
final class CustomTextField: UITextField {
    
    weak var customDelegate: CustomTextFieldDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    private func setupTextField() {
        delegate = self
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        customDelegate?.textFieldDidChange(self, text: text ?? "")
    }
}

// MARK: - UITextField Delegate
extension CustomTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        customDelegate?.textFieldDidStartEditing(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        customDelegate?.textFieldDidEndEditing(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return customDelegate?.textFieldShouldReturn(self) ?? true
    }
}
