import UIKit
import VisionKit

enum ImageAnalyzerService {
    private static let analyzer = ImageAnalyzer()

    @MainActor
    static var isSupported: Bool {
        ImageAnalyzer.isSupported
    }

    static func analyze(image: UIImage) async throws -> ImageAnalysis {
        let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
        return try await analyzer.analyze(image, configuration: configuration)
    }
}
