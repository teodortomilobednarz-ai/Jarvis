import SwiftUI
import UIKit
#if canImport(VisionKit)
import VisionKit
#endif

/// Caméra de scan de code-barres (VisionKit DataScanner). Aucune pub ici.
struct BarcodeScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    #if canImport(VisionKit)
    func makeUIViewController(context: Context) -> UIViewController {
        guard DataScannerViewController.isSupported, DataScannerViewController.isAvailable else {
            return UnsupportedScannerController()
        }
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan) }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        init(onScan: @escaping (String) -> Void) { self.onScan = onScan }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addedItems {
                if case let .barcode(barcode) = item, let value = barcode.payloadStringValue {
                    onScan(value)
                    break
                }
            }
        }
    }
    #else
    func makeUIViewController(context: Context) -> UIViewController { UnsupportedScannerController() }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    #endif
}

/// Affiché quand le scan n'est pas supporté (simulateur, iPad sans caméra).
final class UnsupportedScannerController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Scan indisponible sur cet appareil."
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
