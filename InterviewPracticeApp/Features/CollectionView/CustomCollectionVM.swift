//
//  CustomCollectionVM.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import UIKit

// MARK: - ViewModel Protocol
protocol CustomCollectionVMProtocol: AnyObject {
    var photosPublisher: Published<[Photo]>.Publisher { get }
    var selectedLayoutPublisher: Published<LayoutType>.Publisher { get }
    
    func loadPhotos()
    func changeLayout(to type: LayoutType)
    func numberOfPhotos() -> Int
    func photo(at index: Int) -> Photo
}

enum LayoutType: String, CaseIterable {
    case grid = "Grid"
    case list = "List"
    case waterfall = "Waterfall"
    
    var title: String {
        return rawValue
    }
}

// MARK: - ViewModel Implementation
final class CustomCollectionVM: CustomCollectionVMProtocol {
    
    @Published private var photos: [Photo] = []
    @Published private var selectedLayout: LayoutType = .grid
    
    var photosPublisher: Published<[Photo]>.Publisher { $photos }
    var selectedLayoutPublisher: Published<LayoutType>.Publisher { $selectedLayout }
    
    func loadPhotos() {
        // Generate mock photos with random colors and sizes
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemOrange,
            .systemPurple, .systemPink, .systemTeal, .systemIndigo,
            .systemBrown, .systemCyan, .systemMint, .systemYellow
        ]
        
        photos = (1...50).map { index in
            let randomColor = colors.randomElement() ?? .systemBlue
            let randomHeight = CGFloat.random(in: 150...300)
            let size = CGSize(width: 200, height: randomHeight)
            
            return Photo(
                title: "Foto \(index)",
                color: randomColor,
                size: size
            )
        }
    }
    
    func changeLayout(to type: LayoutType) {
        selectedLayout = type
    }
    
    func numberOfPhotos() -> Int {
        return photos.count
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
}
