import Foundation

enum HomeDestination: Hashable, Identifiable {
    case documentScanner
    case dataScanner
    case liveText

    var id: String {
        switch self {
        case .documentScanner: "documentScanner"
        case .dataScanner: "dataScanner"
        case .liveText: "liveText"
        }
    }

    var title: String {
        switch self {
        case .documentScanner: "Document Camera"
        case .dataScanner: "Data Scanner"
        case .liveText: "Live Text"
        }
    }

    var subtitle: String {
        switch self {
        case .documentScanner: "Scan physical documents page by page"
        case .dataScanner: "Text and machine-readable codes in the viewfinder"
        case .liveText: "Interact with text and QR codes in photos"
        }
    }

    var iconName: String {
        switch self {
        case .documentScanner: "doc.viewfinder"
        case .dataScanner: "barcode.viewfinder"
        case .liveText: "text.viewfinder"
        }
    }

    static let allFeatures: [HomeDestination] = [.liveText, .dataScanner, .documentScanner]
}
