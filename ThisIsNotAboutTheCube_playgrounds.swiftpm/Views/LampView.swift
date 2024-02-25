import SwiftUI
import SceneKit

struct LampView: View {
    @State private var isLightFlashing = false
    @State private var randomOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            Color.black
            // triangle light
                LinearGradient(
                    gradient: Gradient(colors: [.white, .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .mask(TriangleMask())
                .opacity(randomOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                        updateRandomOpacity()
                        isLightFlashing.toggle()
                    }
                }
                .ignoresSafeArea()
        }
    }
    // GENERATES RANDOM VALUES FOR FLASHING LIGHTS
    private func updateRandomOpacity() {
        randomOpacity = Double.random(in: 0.4...0.8)
    }

}

// TRIANGLE MASK FOR LIGHT SHAPE
struct TriangleMask: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: geometry.size.width/2, y: -300))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                path.addLine(to: CGPoint(x: 0, y: geometry.size.height ))
            }
        }
    }
}
