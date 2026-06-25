import SwiftUI
import UIKit
import VisionKit

struct DataScannerLabView: View {
    @State private var recognizedItems: [RecognizedItem] = []
    @State private var scanErrorMessage: String?
    @State private var tappedPayload: String?

    @MainActor
    private var availability: DataScannerAvailability {
        guard DataScannerViewController.isSupported else { return .unsupportedDevice }
        guard DataScannerViewController.isAvailable else { return .unavailable }
        return .available
    }

    var body: some View {
        Group {
            switch availability {
            case .available:
                scannerContent
            case .unsupportedDevice, .unavailable:
                unavailableContent
            }
        }
        .navigationTitle("Data Scanner")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var scannerContent: some View {
        VStack(spacing: 0) {
            DataScannerRepresentable(
                recognizedItems: $recognizedItems,
                scanErrorMessage: $scanErrorMessage,
                tappedPayload: $tappedPayload
            )
            .ignoresSafeArea(edges: .horizontal)
            listPanel
        }
    }

    private var barcodeItems: [RecognizedItem] {
        recognizedItems.filter { item in
            if case .barcode = item { return true }
            return false
        }
    }

    private var textRegionCount: Int {
        recognizedItems.reduce(into: 0) { count, item in
            if case .text = item { count += 1 }
        }
    }

    private var listPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                if let scanErrorMessage {
                    ErrorBanner(message: scanErrorMessage)
                }
                if let tappedPayload {
                    Text("Last tap: \(tappedPayload)")
                        .font(Theme.FontRole.caption)
                        .foregroundStyle(.secondary)
                }
                recognizedList
            }
        }
        .frame(maxHeight: 220)
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }

    private var unavailableContent: some View {
        ContentUnavailableView(
            "Data Scanner Unavailable",
            systemImage: "barcode.viewfinder",
            description: Text(availability.userMessage)
        )
        .padding(Theme.Spacing.md)
    }

    @ViewBuilder
    private var recognizedList: some View {
        if recognizedItems.isEmpty {
            Text("Point the camera at printed text or a machine-readable code.")
                .font(Theme.FontRole.caption)
                .foregroundStyle(.secondary)
        } else {
            if textRegionCount > 0 {
                Text("Text regions (\(textRegionCount))")
                    .font(Theme.FontRole.cardTitle)
                Text("Tap a highlight in the camera view to select or copy text.")
                    .font(Theme.FontRole.caption)
                    .foregroundStyle(.secondary)
            }
            if !barcodeItems.isEmpty {
                Text("Barcodes (\(barcodeItems.count))")
                    .font(Theme.FontRole.cardTitle)
                    .padding(.top, textRegionCount > 0 ? Theme.Spacing.xs : 0)
                ForEach(barcodeItems) { item in
                    recognizedRow(item)
                }
            }
        }
    }

    @ViewBuilder
    private func recognizedRow(_ item: RecognizedItem) -> some View {
        switch item {
        case .barcode(let barcode):
            HStack {
                Text(barcode.payloadStringValue ?? "Machine-readable code")
                    .font(Theme.FontRole.body)
                Spacer()
                Button("Copy") {
                    UIPasteboard.general.string = barcode.payloadStringValue
                }
                .buttonStyle(.bordered)
            }
        case .text:
            EmptyView()
        @unknown default:
            EmptyView()
        }
    }
}

private enum DataScannerAvailability {
    case available
    case unsupportedDevice
    case unavailable

    var userMessage: String {
        switch self {
        case .available:
            return ""
        case .unsupportedDevice:
            return "This device does not support data scanning."
        case .unavailable:
            return "Allow camera access and ensure no camera restrictions (such as Screen Time) are active."
        }
    }
}

private struct DataScannerRepresentable: UIViewControllerRepresentable {
    @Binding var recognizedItems: [RecognizedItem]
    @Binding var scanErrorMessage: String?
    @Binding var tappedPayload: String?

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.text(), .barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        guard !context.coordinator.didStartScanning else { return }
        context.coordinator.didStartScanning = true
        do {
            try uiViewController.startScanning()
            Task { @MainActor in
                scanErrorMessage = nil
            }
        } catch {
            Task { @MainActor in
                scanErrorMessage = error.localizedDescription
            }
        }
    }

    func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            recognizedItems: $recognizedItems,
            tappedPayload: $tappedPayload
        )
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var recognizedItems: [RecognizedItem]
        @Binding var tappedPayload: String?
        var didStartScanning = false

        init(
            recognizedItems: Binding<[RecognizedItem]>,
            tappedPayload: Binding<String?>
        ) {
            _recognizedItems = recognizedItems
            _tappedPayload = tappedPayload
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            Task { @MainActor in
                recognizedItems = allItems
            }
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didRemove removedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            Task { @MainActor in
                recognizedItems = allItems
            }
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didUpdate updatedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            Task { @MainActor in
                recognizedItems = allItems
            }
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didTapOn item: RecognizedItem
        ) {
            Task { @MainActor in
                switch item {
                case .barcode(let barcode):
                    tappedPayload = barcode.payloadStringValue
                case .text(let text):
                    tappedPayload = text.transcript
                @unknown default:
                    tappedPayload = nil
                }
            }
        }
    }
}
