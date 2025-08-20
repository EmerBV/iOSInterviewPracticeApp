//
//  MainVM.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine

protocol MainVMProtocol: AnyObject {
    var exercisesPublisher: Published<[Exercise]>.Publisher { get }
    func loadExercises()
    func numberOfExercises() -> Int
    func exercise(at index: Int) -> Exercise
}

final class MainVM: MainVMProtocol {
    
    // MARK: - Published Properties
    @Published private var exercises: [Exercise] = []
    
    var exercisesPublisher: Published<[Exercise]>.Publisher { $exercises }
    
    // MARK: - Methods
    func loadExercises() {
        exercises = [
            Exercise(
                title: "TableView with Search",
                description: "Implementar TableView con barra de búsqueda",
                difficulty: .medium,
                tags: ["TableView", "SearchBar", "Filtering"],
                createViewController: { SearchableTableVC() }
            ),
            Exercise(
                title: "Custom Collection View",
                description: "CollectionView con layout personalizado",
                difficulty: .medium,
                tags: ["CollectionView", "Custom Layout", "Grid"],
                createViewController: { CustomCollectionVC() }
            ),
            Exercise(
                title: "Network Request",
                description: "Realizar peticiones HTTP con URLSession",
                difficulty: .easy,
                tags: ["Networking", "URLSession", "JSON"],
                createViewController: { NetworkRequestVC() }
            ),
            Exercise(
                title: "Weather API with Combine",
                description: "App del clima usando URLSession y Combine. Implementa llamadas a API, manejo de errores, búsqueda de ciudades, pronóstico y UI reactiva con Publishers.",
                difficulty: .hard,
                tags: ["Combine", "URLSession", "API", "Weather", "Publishers", "MVVM"],
                createViewController: { WeatherVC() }
            ),
            Exercise(
                title: "Core Data CRUD",
                description: "Operaciones básicas con Core Data",
                difficulty: .hard,
                tags: ["Core Data", "CRUD", "Persistence"],
                createViewController: { CoreDataVC() }
            ),
            Exercise(
                title: "Custom Views",
                description: "Crear vistas personalizadas programáticamente",
                difficulty: .medium,
                tags: ["Custom Views", "Drawing", "Animation"],
                createViewController: { CustomViewsVC() }
            ),
            Exercise(
                title: "Memory Management",
                description: "Demostrar conocimiento de ARC y retain cycles",
                difficulty: .hard,
                tags: ["ARC", "Memory", "Retain Cycles"],
                createViewController: { MemoryManagementVC() }
            ),
            Exercise(
                title: "Multithreading",
                description: "GCD, Operation Queues y concurrencia",
                difficulty: .hard,
                tags: ["GCD", "Threading", "Concurrency"],
                createViewController: { MultithreadingVC() }
            ),
            Exercise(
                title: "Delegation Pattern",
                description: "Implementar patrón delegate",
                difficulty: .easy,
                tags: ["Delegate", "Pattern", "Communication"],
                createViewController: { DelegationVC() }
            ),
            Exercise(
                title: "SwiftUI Integration",
                description: "Integrar SwiftUI en proyecto UIKit con llamadas a API. Demuestra el uso completo de SwiftUI con su propia navegación.",
                difficulty: .medium,
                tags: ["SwiftUI", "UIKit", "Integration", "API", "Navigation"],
                createViewController: { SwiftUIIntegrationVC() }
            ),
            Exercise(
                title: "SwiftUI + Custom Nav",
                description: "Integración híbrida SwiftUI + UIKit con navegación personalizada. Controles UIKit en navigation bar, contenido SwiftUI, comunicación bidireccional.",
                difficulty: .hard,
                tags: ["SwiftUI", "UIKit", "Hybrid", "Custom Nav", "Advanced"],
                createViewController: { SwiftUIIntegrationWithNavVC() }
            ),
            Exercise(
                title: "Documentos de Entrevista",
                description: "Visualizar PDFs con preguntas y respuestas para entrevistas iOS. Incluye contenido para desarrolladores junior y senior, con búsqueda avanzada y categorización por temas.",
                difficulty: .medium,
                tags: ["PDF", "Documentos", "Entrevistas", "Swift", "PDFKit"],
                createViewController: { DocumentViewerVC() }
            )
        ]
    }
    
    func numberOfExercises() -> Int {
        return exercises.count
    }
    
    func exercise(at index: Int) -> Exercise {
        return exercises[index]
    }
}
