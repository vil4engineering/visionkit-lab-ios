import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            HomeView()
                .navigationDestination(for: HomeDestination.self) { destination in
                    switch destination {
                    case .documentScanner:
                        DocumentScannerView()
                    case .dataScanner:
                        DataScannerLabView()
                    case .liveText:
                        LiveTextLabView()
                    }
                }
        }
    }
}
