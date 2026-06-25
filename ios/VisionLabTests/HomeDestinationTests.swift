import Testing
@testable import VisionLab

@Suite("HomeDestination")
struct HomeDestinationTests {
    @Test func destinations_areStable() {
        #expect(HomeDestination.documentScanner.id == "documentScanner")
        #expect(HomeDestination.dataScanner.id == "dataScanner")
        #expect(HomeDestination.liveText.id == "liveText")
        #expect(HomeDestination.allFeatures.count == 3)
        #expect(HomeDestination.liveText.title == "Live Text")
    }
}
