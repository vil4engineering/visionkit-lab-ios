import PhotosUI
import SwiftUI
import UIKit
import VisionKit

struct LiveTextLabView: View {
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var analysis: ImageAnalysis?
    @State private var isAnalyzing = false
    @State private var errorMessage: String?

    @MainActor
    private var isLiveTextSupported: Bool {
        ImageAnalyzerService.isSupported
    }

    var body: some View {
        Group {
            if isLiveTextSupported {
                content
            } else {
                ContentUnavailableView(
                    "Live Text Unavailable",
                    systemImage: "text.viewfinder",
                    description: Text("Live Text requires a device with an A12 Bionic chip or later.")
                )
                .padding(Theme.Spacing.md)
            }
        }
        .navigationTitle("Live Text")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: photoItem) { _, newItem in
            Task {
                await loadAndAnalyze(newItem)
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                Label("Photo Library", systemImage: "photo")
            }
            .buttonStyle(.bordered)
            if isAnalyzing {
                ProgressView("Analyzing image…")
            }
            if let errorMessage {
                ErrorBanner(message: errorMessage)
            }
            if let selectedImage {
                LiveTextImageView(image: selectedImage, analysis: analysis)
                    .aspectRatio(selectedImage.displayAspectRatio, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 480)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text("Tap the Live Text button, then select text or long-press QR codes and links.")
                    .font(Theme.FontRole.caption)
                    .foregroundStyle(.secondary)
            } else {
                ContentUnavailableView(
                    "Choose a Photo",
                    systemImage: "photo.on.rectangle.angled",
                    description: Text("VisionKit analyzes the image for text and machine-readable codes.")
                )
                .frame(maxHeight: 280)
            }
        }
        .padding(Theme.Spacing.md)
    }

    @MainActor
    private func loadAndAnalyze(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        errorMessage = nil
        analysis = nil
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data)?.normalizedUpOrientation() else {
                errorMessage = "Could not load the selected photo."
                return
            }
            selectedImage = image
            isAnalyzing = true
            analysis = try await ImageAnalyzerService.analyze(image: image)
            isAnalyzing = false
        } catch {
            isAnalyzing = false
            errorMessage = error.localizedDescription
        }
    }
}
