//
//  SearchableTableVM.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

// MARK: - ViewModel Protocol
protocol SearchableTableVMProtocol: AnyObject {
    var filteredPeoplePublisher: Published<[Person]>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    
    func loadData()
    func searchPeople(with query: String)
    func numberOfPeople() -> Int
    func person(at index: Int) -> Person
}

// MARK: - ViewModel Implementation
final class SearchableTableVM: SearchableTableVMProtocol {
    
    @Published private var allPeople: [Person] = []
    @Published private var filteredPeople: [Person] = []
    @Published private var isLoading: Bool = false
    
    var filteredPeoplePublisher: Published<[Person]>.Publisher { $filteredPeople }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    
    func loadData() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let mockData = self?.generateMockData() ?? []
            
            DispatchQueue.main.async {
                self?.allPeople = mockData
                self?.filteredPeople = mockData
                self?.isLoading = false
            }
        }
    }
    
    func searchPeople(with query: String) {
        if query.isEmpty {
            filteredPeople = allPeople
        } else {
            filteredPeople = allPeople.filter { person in
                person.name.localizedCaseInsensitiveContains(query) ||
                person.email.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    func numberOfPeople() -> Int {
        return filteredPeople.count
    }
    
    func person(at index: Int) -> Person {
        return filteredPeople[index]
    }
    
    private func generateMockData() -> [Person] {
        let names = [
            "Juan Pérez", "María García", "Carlos López", "Ana Martínez",
            "Pedro Rodríguez", "Laura Hernández", "Miguel González", "Isabel Díaz",
            "Francisco Ruiz", "Carmen Moreno", "Antonio Jiménez", "Dolores Álvarez",
            "José Romero", "Pilar Navarro", "Manuel Torres", "Rosa Domínguez"
        ]
        
        return names.enumerated().map { index, name in
            let emailName = name.lowercased()
                .replacingOccurrences(of: " ", with: ".")
                .folding(options: .diacriticInsensitive, locale: .current)
            
            return Person(
                name: name,
                email: "\(emailName)@email.com",
                age: 25 + (index * 3) % 40
            )
        }
    }
}
