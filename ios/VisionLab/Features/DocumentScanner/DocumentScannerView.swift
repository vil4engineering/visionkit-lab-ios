import Photos
import SwiftUI
import UIKit
import VisionKit

struct DocumentScannerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showScanner = false
    @State private var scannedPages: [UIImage] = []
    @State private var selectedPageIndex = 0
    @State private var errorMessage: String?
    @State private var saveStatusMessage: String?
    @State private var didAttemptInitialScan = false

    private var isScannerSupported: Bool {
        VNDocumentCameraViewController.isSupported
    }

    var body: some View {
        Group {
            if !scannedPages.isEmpty {
                resultsContent
            } else if !isScannerSupported {
                unsupportedContent
            } else {
                Color.clear
            }
        }
        .navigationTitle("Document Camera")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !scannedPages.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Scan Again") {
                        showScanner = true
                    }
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            DocumentCameraRepresentable { pages in
                showScanner = false
                scannedPages = pages
                selectedPageIndex = 0
                saveStatusMessage = nil
            } onCancel: {
                showScanner = false
                if scannedPages.isEmpty {
                    dismiss()
                }
            }
        }
        .onAppear {
            presentScannerIfNeeded()
        }
    }

    private var unsupportedContent: some View {
        ContentUnavailableView(
            "Document Camera Unavailable",
            systemImage: "doc.viewfinder",
            description: Text("Document scanning is not supported on this device.")
        )
        .padding(Theme.Spacing.md)
    }

    private var resultsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                if scannedPages.count > 1 {
                    Picker("Page", selection: $selectedPageIndex) {
                        ForEach(scannedPages.indices, id: \.self) { index in
                            Text("Page \(index + 1)").tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Image(uiImage: scannedPages[selectedPageIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 420)
                    .accessibilityLabel("Scanned document page \(selectedPageIndex + 1)")
                Text("\(scannedPages.count) page\(scannedPages.count == 1 ? "" : "s") scanned")
                    .font(Theme.FontRole.caption)
                    .foregroundStyle(.secondary)
                Button("Save Current Page") {
                    saveCurrentPage()
                }
                .buttonStyle(.bordered)
                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }
                if let saveStatusMessage {
                    Text(saveStatusMessage)
                        .font(Theme.FontRole.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(Theme.Spacing.md)
        }
    }

    private func presentScannerIfNeeded() {
        guard !didAttemptInitialScan, scannedPages.isEmpty, isScannerSupported else { return }
        didAttemptInitialScan = true
        showScanner = true
    }

    private func saveCurrentPage() {
        guard scannedPages.indices.contains(selectedPageIndex) else { return }
        let image = scannedPages[selectedPageIndex]
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            Task { @MainActor in
                guard status == .authorized || status == .limited else {
                    errorMessage = "Photo library access is required to save scans."
                    return
                }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                saveStatusMessage = "Saved page \(selectedPageIndex + 1) to Photos."
            }
        }
    }
}

private struct DocumentCameraRepresentable: UIViewControllerRepresentable {
    let onScan: ([UIImage]) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan, onCancel: onCancel)
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onScan: ([UIImage]) -> Void
        let onCancel: () -> Void

        init(onScan: @escaping ([UIImage]) -> Void, onCancel: @escaping () -> Void) {
            self.onScan = onScan
            self.onCancel = onCancel
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            onCancel()
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            guard scan.pageCount > 0 else {
                onCancel()
                return
            }
            let pages = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
            onScan(pages)
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            onCancel()
        }
    }
}
