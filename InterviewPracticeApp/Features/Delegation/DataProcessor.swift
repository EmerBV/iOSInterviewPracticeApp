//
//  DataProcessor.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

// MARK: - Data Processor Delegate
protocol DataProcessorDelegate: AnyObject {
    func dataProcessor(_ processor: DataProcessor, didStartProcessing data: String)
    func dataProcessor(_ processor: DataProcessor, didFinishProcessing result: String)
    func dataProcessor(_ processor: DataProcessor, didFailWithError error: Error)
}

// MARK: - Data Processor
final class DataProcessor {
    
    weak var delegate: DataProcessorDelegate?
    
    func processData(_ data: String) {
        delegate?.dataProcessor(self, didStartProcessing: data)
        
        // Simular procesamiento asíncrono
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if data.isEmpty {
                let error = NSError(domain: "DataProcessor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Datos vacíos"])
                
                DispatchQueue.main.async {
                    self.delegate?.dataProcessor(self, didFailWithError: error)
                }
            } else {
                let result = "Procesado: '\(data)' -> \(data.count) caracteres"
                
                DispatchQueue.main.async {
                    self.delegate?.dataProcessor(self, didFinishProcessing: result)
                }
            }
        }
    }
}
