//
//  PDFContentGenerator.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import PDFKit
import UIKit

final class PDFContentGenerator {
    
    static func generatePDF(for document: InterviewDocument) -> PDFDocument? {
        let pdfDocument = PDFDocument()
        let pageSize = CGSize(width: 612, height: 792) // Letter size
        
        let content = getContentForDocument(document)
        let pages = createPagesFromContent(content, pageSize: pageSize)
        
        for (index, page) in pages.enumerated() {
            pdfDocument.insert(page, at: index)
        }
        
        return pdfDocument
    }
    
    private static func getContentForDocument(_ document: InterviewDocument) -> String {
        switch document.fileName {
        case "swift_senior_interview_questions_2025.pdf":
            return swiftSeniorContent
        case "swift_junior_interview_questions_2025.pdf":
            return swiftJuniorContent
        default:
            return defaultContent(for: document)
        }
    }
    
    private static func createPagesFromContent(_ content: String, pageSize: CGSize) -> [PDFPage] {
        var pages: [PDFPage] = []
        
        // Split content into chunks that fit on one page
        let chunks = splitContentIntoChunks(content)
        
        for chunk in chunks {
            if let page = createPDFPage(with: chunk, pageSize: pageSize) {
                pages.append(page)
            }
        }
        
        return pages
    }
    
    private static func splitContentIntoChunks(_ content: String) -> [String] {
        // Simple chunking - in a real app, you'd want more sophisticated pagination
        let maxChunkSize = 2000
        var chunks: [String] = []
        
        if content.count <= maxChunkSize {
            return [content]
        }
        
        let sentences = content.components(separatedBy: ". ")
        var currentChunk = ""
        
        for sentence in sentences {
            if currentChunk.count + sentence.count > maxChunkSize {
                chunks.append(currentChunk)
                currentChunk = sentence + ". "
            } else {
                currentChunk += sentence + ". "
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }
        
        return chunks
    }
    
    private static func createPDFPage(with content: String, pageSize: CGSize) -> PDFPage? {
        let page = PDFPage()
        
        // Create graphics context
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(origin: .zero, size: pageSize), nil)
        UIGraphicsBeginPDFPage()
        
        let context = UIGraphicsGetCurrentContext()!
        
        // Set up text attributes
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        // Calculate text area
        let margin: CGFloat = 50
        let textRect = CGRect(
            x: margin,
            y: margin,
            width: pageSize.width - (margin * 2),
            height: pageSize.height - (margin * 2)
        )
        
        // Draw text
        let attributedString = NSAttributedString(string: content, attributes: textAttributes)
        attributedString.draw(in: textRect)
        
        UIGraphicsEndPDFContext()
        
        // Create PDFPage from data
        if let pdfDocument = PDFDocument(data: pdfData as Data),
           let firstPage = pdfDocument.page(at: 0) {
            return firstPage
        }
        
        return nil
    }
    
    private static func defaultContent(for document: InterviewDocument) -> String {
        return """
        \(document.title)
        
        \(document.description)
        
        Categoría: \(document.category.title)
        Dificultad: \(document.difficulty.rawValue)
        Tiempo estimado: \(document.estimatedReadingTime)
        
        Tags: \(document.tags.joined(separator: ", "))
        
        Este es un documento de muestra generado automáticamente.
        
        Para cargar el contenido real del PDF, añade el archivo:
        \(document.fileName)
        
        al bundle de la aplicación en la carpeta Resources.
        
        La aplicación está configurada para:
        1. Buscar primero el PDF en el bundle
        2. Si no lo encuentra, generar este contenido de muestra
        3. Mostrar el PDF usando PDFKit
        4. Permitir compartir el documento
        
        Características implementadas:
        • Visualización de PDF con PDFKit
        • Navegación por páginas
        • Zoom automático
        • Funcionalidad de compartir
        • Búsqueda de documentos
        • Categorización por temas
        """
    }
    
    // MARK: - Sample Content
    private static let swiftSeniorContent = """
    PREGUNTAS DE ENTREVISTA SWIFT PARA DESARROLLADORES SENIOR
    
    1. Diferencias entre class, struct y actor en Swift
    
    class (Tipo de referencia):
    • Almacenado en el heap
    • Paso por referencia
    • Admite herencia
    • Mutable incluso con let
    
    struct (Tipo de valor):
    • Almacenado en el stack
    • Paso por valor
    • Sin herencia
    • Control de mutabilidad con mutating
    
    actor (Tipo de referencia con concurrencia):
    • Garantiza thread safety
    • Acceso secuencial
    • Protege de race conditions
    
    2. Property Wrappers en Swift
    
    Los property wrappers permiten lógica reutilizable para propiedades.
    
    @propertyWrapper
    struct Capitalized {
        private var value: String = ""
        var wrappedValue: String {
            get { value }
            set { value = newValue.capitalized }
        }
    }
    
    3. @autoclosure y su uso
    
    Permite que las expresiones se conviertan automáticamente en closures.
    
    func logIfTrue(_ condition: @autoclosure () -> Bool) {
        if condition() {
            print("Condición cumplida")
        }
    }
    
    4. Gestión de memoria y ARC
    
    ARC (Automatic Reference Counting) rastrea referencias a instancias de clase.
    Los objetos se desasignan cuando el reference count = 0.
    
    5. Retain cycles y prevención
    
    Un retain cycle ocurre cuando dos objetos tienen referencias fuertes entre sí.
    Solución: usar weak o unowned references.
    
    6. Parámetros inout
    
    Permite modificar parámetros de función directamente:
    
    func doubleValue(_ number: inout Int) {
        number *= 2
    }
    
    7. Codable y JSON personalizado
    
    Swift puede codificar/decodificar JSON usando Codable.
    Para mapeo personalizado, usar CodingKeys.
    
    8. Escaping vs Non-Escaping Closures
    
    Non-escaping (default): se ejecuta inmediatamente
    Escaping (@escaping): se ejecuta después del return
    
    9. Function Builders en Swift
    
    Usado en SwiftUI para construir estructuras complejas.
    @resultBuilder permite crear DSLs.
    
    10. Any vs AnyObject vs AnyHashable
    
    • Any: cualquier tipo
    • AnyObject: solo tipos de clase
    • AnyHashable: cualquier tipo Hashable
    """
    
    private static let swiftJuniorContent = """
    PREGUNTAS DE ENTREVISTA SWIFT PARA DESARROLLADORES JUNIOR
    
    1. ¿Qué son los opcionales en Swift?
    
    Los opcionales permiten que una variable tenga un valor o sea nil.
    
    var name: String? = "John"
    name = nil
    
    Manejo seguro:
    • Optional binding (if let)
    • Guard statements
    • Nil coalescing (??)
    
    2. Diferencia entre var y let
    
    • var: mutable, permite cambios
    • let: inmutable, valor constante
    
    3. Diferencia entre struct y class
    
    struct (value type):
    • Stack storage
    • Copy by value
    • No inheritance
    
    class (reference type):
    • Heap storage
    • Copy by reference
    • Supports inheritance
    
    4. Propiedades calculadas vs almacenadas
    
    • Stored property: almacena un valor
    • Computed property: calcula dinámicamente
    
    struct Rectangle {
        var width: Double
        var height: Double
        
        var area: Double {
            return width * height
        }
    }
    
    5. Inferencia de tipos
    
    Swift determina automáticamente el tipo:
    
    let x = 10 // Int
    let y = "Hello" // String
    
    6. Funciones mutating
    
    Necesarias para modificar propiedades en structs:
    
    struct Car {
        var speed = 0
        
        mutating func accelerate() {
            speed += 10
        }
    }
    
    7. Extensiones en Swift
    
    Agregan funcionalidad a tipos existentes:
    
    extension Int {
        func square() -> Int {
            return self * self
        }
    }
    
    8. Protocolos
    
    Definen un blueprint de métodos y propiedades:
    
    protocol Vehicle {
        var speed: Int { get set }
        func accelerate()
    }
    
    9. Codable para JSON
    
    struct User: Codable {
        var name: String
        var age: Int
    }
    
    10. Niveles de control de acceso
    
    • open: accesible en cualquier lugar
    • public: accesible pero no subclasificable
    • internal: dentro del mismo módulo
    • fileprivate: dentro del mismo archivo
    • private: dentro del mismo scope
    """
}
