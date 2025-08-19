//
//  Utils.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

struct Utils {
    
    // MARK: - Device Information
    static var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var hasNotch: Bool {
        guard let window = UIApplication.shared.windows.first else { return false }
        return window.safeAreaInsets.top > 20
    }
    
    // MARK: - Screen Dimensions
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    // MARK: - Haptic Feedback
    static func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func notificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    // MARK: - Date Formatting
    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    static func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    // MARK: - Validation Helpers
    static func isValidText(_ text: String?, minLength: Int = 1) -> Bool {
        guard let text = text?.trimmed, !text.isEmpty else { return false }
        return text.count >= minLength
    }
    
    static func isValidURL(_ urlString: String?) -> Bool {
        guard let urlString = urlString, let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    // MARK: - UI Helpers
    static func showAlert(
        on viewController: UIViewController,
        title: String,
        message: String,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        viewController.present(alert, animated: true)
    }
    
    static func showConfirmationAlert(
        on viewController: UIViewController,
        title: String,
        message: String,
        confirmTitle: String = "Confirmar",
        cancelTitle: String = "Cancelar",
        onConfirm: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive) { _ in
            onConfirm()
        })
        
        viewController.present(alert, animated: true)
    }
}
