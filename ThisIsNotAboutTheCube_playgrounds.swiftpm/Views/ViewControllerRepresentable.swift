import SwiftUI

// UIViewController Representable to bring the View Controller to SwiftUI
struct CubeView: UIViewControllerRepresentable {
    @ObservedObject var viewController: ViewController

    func makeUIViewController(context: Context) -> ViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
