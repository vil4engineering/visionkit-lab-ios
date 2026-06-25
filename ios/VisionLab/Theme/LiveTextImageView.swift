import SwiftUI
import UIKit
import VisionKit

struct LiveTextImageView: UIViewRepresentable {
    let image: UIImage
    let analysis: ImageAnalysis?

    func makeUIView(context: Context) -> LiveTextImageContainerView {
        let container = LiveTextImageContainerView()
        container.configure(image: image, analysis: analysis, interaction: context.coordinator.interaction)
        context.coordinator.containerView = container
        return container
    }

    func updateUIView(_ uiView: LiveTextImageContainerView, context: Context) {
        uiView.configure(image: image, analysis: analysis, interaction: context.coordinator.interaction)
    }

    func makeCoordinator() -> Coordinator {
        let interaction = ImageAnalysisInteraction()
        interaction.preferredInteractionTypes = .automatic
        return Coordinator(interaction: interaction)
    }

    final class Coordinator {
        let interaction: ImageAnalysisInteraction
        weak var containerView: LiveTextImageContainerView?

        init(interaction: ImageAnalysisInteraction) {
            self.interaction = interaction
        }
    }
}

final class LiveTextImageContainerView: UIView {
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(image: UIImage, analysis: ImageAnalysis?, interaction: ImageAnalysisInteraction) {
        imageView.image = image
        if imageView.interactions.contains(where: { $0 === interaction }) == false {
            imageView.addInteraction(interaction)
        }
        interaction.analysis = analysis
    }
}

extension UIImage {
    var displayAspectRatio: CGFloat {
        let size = displaySize
        guard size.height > 0 else { return 1 }
        return size.width / size.height
    }

    var displaySize: CGSize {
        switch imageOrientation {
        case .left, .right, .leftMirrored, .rightMirrored:
            return CGSize(width: size.height, height: size.width)
        default:
            return size
        }
    }

    func normalizedUpOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        let targetSize = displaySize
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
